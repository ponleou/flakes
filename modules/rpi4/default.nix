{ pkgs, nixos-raspberrypi, ... }:
{
  imports = with nixos-raspberrypi.nixosModules; [
    raspberry-pi-4.base
    raspberry-pi-4.bluetooth

    ./filesystem.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.openssh.enable = true;
  environment.systemPackages = with pkgs; [
    neovim
    git
  ];
}
