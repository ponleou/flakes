{
  config,
  constants,
  pkgs,
  ...
}:
let
  forgejoSrv = config.services.forgejo.settings.server;

  drive = constants.alcyone.drive;
  var = constants.alcyone.forgejo;
in
{
  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  services = {
    cloudflared = {
      enable = true;

    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts.${forgejoSrv.DOMAIN} = {
        # cloudflares gonna do TLS
        listen = [
          {
            addr = "localhost";
            port = 80;
          }
        ];
        locations."/" = {
          proxyPass = "http://localhost:${toString var.anubisPort}";
        };
      };
    };

    anubis = {
      instances.forgejo = {
        enable = true;
        settings = {
          BIND_NETWORK = "tcp";
          BIND = "localhost:${toString var.anubisPort}";
          TARGET = "http://localhost:${toString forgejoSrv.HTTP_PORT}";
          CUSTOM_REAL_IP_HEADER = "CF-Connecting-IP"; # using with cloudflare tunnel
        };
        policy = {
          extraBots = [
            {
              name = "allow-git-smart-http";
              action = "ALLOW";
              expression = {
                all = [
                  ''
                    (
                      userAgent.startsWith("Git/") ||
                      userAgent.startsWith("git/") ||
                      userAgent.contains("libgit") ||
                      userAgent.startsWith("go-git") ||
                      userAgent.startsWith("JGit/") ||
                      userAgent.startsWith("JGit-")
                    )
                  ''
                  ''"Accept-Encoding" in headers''
                  ''headers["Accept-Encoding"].contains("gzip")''
                  ''
                    (
                      path.endsWith("/info/refs") ||
                      path.endsWith("/git-upload-pack") ||
                      path.endsWith("/git-receive-pack") ||
                      path.endsWith("/git-upload-archive")
                    )
                  ''
                ];
              };
            }
            # upstream's git client policy still blocks my clone :/
            { import = "(data)/clients/git.yaml"; }
            { import = "(data)/meta/default-config.yaml"; } # manually importing the default config so the git config comes first
          ];
          useDefaultBotRules = false; # this imports the `default-config.yaml`, but places it first, so we disable it
        };
      };
    };

    forgejo = {
      enable = true;
      database.type = "postgres";
      stateDir = "/${drive.root}/${drive.main}/lib/forgejo";
      lfs.enable = true; # by default, large files go to {stateDir}/data/lfs
      settings = {
        server = {
          DOMAIN = "git.example.com"; # TODO: replace example domain
          ROOT_URL = "https://${forgejoSrv.DOMAIN}/";
          HTTP_PORT = var.port; # TODO: open firewall
          SSH_DOMAIN = "${config.services.avahi.hostName}.${config.services.avahi.domainName}"; # NOTE: ssh is only available locally # TODO: change to domain name
          SSH_LISTEN_PORT = 2222;
          START_SSH_SERVER = true;
          LANDING_PAGE = "explore";
        };
        service.DISABLE_REGISTRATION = true; # TODO: temporary allow to create admin user (first user is admin)
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
        ui = {
          DEFAULT_THEME = "catppuccin-rosewater-auto";
          THEMES = "catppuccin-rosewater-auto,catppuccin-flamingo-auto,catppuccin-pink-auto,catppuccin-mauve-auto,catppuccin-red-auto,catppuccin-maroon-auto,catppuccin-peach-auto,catppuccin-yellow-auto,catppuccin-green-auto,catppuccin-teal-auto,catppuccin-sky-auto,catppuccin-sapphire-auto,catppuccin-blue-auto,catppuccin-lavender-auto";
        };
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d '${config.services.forgejo.customDir}/public' - forgejo forgejo - -"
    "d '${config.services.forgejo.customDir}/public/assets' - forgejo forgejo - -"
    "C+ '${config.services.forgejo.customDir}/public/assets/css' - forgejo forgejo - ${./static/forgejo/css}"
    "C+ '${config.services.forgejo.customDir}/templates' - forgejo forgejo - ${./static/forgejo/templates}"
  ];
}
