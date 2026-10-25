{
  description = "My Raspberry Pis' NixOS flakes";

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
  };

  outputs =
    {
      nixos-raspberrypi,
      ...
    }:
    {
      nixosConfigurations.rpi4 = nixos-raspberrypi.lib.nixosSystem {
        modules = [
          {
            imports = with nixos-raspberrypi.nixosModules; [
              raspberry-pi-4.base
              raspberry-pi-4.bluetooth
            ];
          }
          (
            { pkgs, ... }:
            {

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              networking.hostName = "rpi4";
              networking.networkmanager.enable = true;

              services.openssh.enable = true;

              users.users.ponleou = {
                isNormalUser = true;
                extraGroups = [
                  "networkmanager"
                  "wheel"
                  "video"
                ];
                openssh.authorizedKeys.keys = [
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA7dnvTKs26CC16ncnCgAvVbmegukt7VXslEBJzLx32y dev.ponleousk@gmail.com"
                ];
              };

              environment.systemPackages = with pkgs; [
                nvim
                git
              ];

              # these are defined by nixos-raspberry's sd image, i have no idea how to modify it
              fileSystems = {
                "/boot/firmware" = {
                  device = "/dev/disk/by-label/FIRMWARE";
                  fsType = "vfat";
                  options = [
                    "noatime"
                    "noauto"
                    "x-systemd.automount"
                    "x-systemd.idle-timeout=1min"
                  ];
                };
                "/" = {
                  device = "/dev/disk/by-label/NIXOS_SD";
                  fsType = "ext4";
                  options = [ "noatime" ];
                };
              };

              swapDevices = [
                {
                  device = "/swapfile";
                  size = 2 * 1024; # 2 gb
                }
              ];
              zramSwap.enable = true;

              system.stateVersion = "26.05";

            }
          )
        ];
      };
    };
}
