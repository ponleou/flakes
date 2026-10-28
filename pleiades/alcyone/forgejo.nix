{
  config,
  constants,
  ...
}:
let
  srv = config.services.forgejo.settings.server;

  drive = constants.alcyone.drive;
in
{
  services.forgejo = {
    enable = true;
    database.type = "postgres";
    stateDir = "/${drive.root}/${drive.main}/lib/forgejo";
    lfs.enable = true; # by default, large files go to {stateDir}/data/lfs
    settings = {
      server = {
        DOMAIN = "git.example.com"; # TODO: replace example domain
        ROOT_URL = "https://${srv.DOMAIN}/";
        HTTP_PORT = 3000;
        SSH_PORT = 2222;
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

  systemd.tmpfiles.rules = [
    "d '${config.services.forgejo.customDir}/public' - forgejo forgejo - -"
    "d '${config.services.forgejo.customDir}/public/assets' - forgejo forgejo - -"
    "C+ '${config.services.forgejo.customDir}/public/assets/css' - forgejo forgejo - ${./static/forgejo/css}"
    "C+ '${config.services.forgejo.customDir}/templates' - forgejo forgejo - ${./static/forgejo/templates}"
  ];
}
