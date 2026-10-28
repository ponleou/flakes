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
  services.nginx = {
    virtualHosts.${srv.DOMAIN} = {
      forceSSL = true;
      enableACME = true;
      locations."/".proxyPass = "http://localhost:${toString srv.HTTP_PORT}";
    };
  };

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
      };
      service.DISABLE_REGISTRATION = true; # TODO: temporary allow to create admin user (first user is admin)
      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };
    };
  };

  systemd.services = {
    forgejo.unitConfig.RequiresMountsFor = "/${drive.root}/${drive.main}";
    forgejo-secrets.unitConfig.RequiresMountsFor = "/${drive.root}/${drive.main}";
  };
}
