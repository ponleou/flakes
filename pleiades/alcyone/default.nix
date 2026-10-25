{ ... }:
{
  imports = [
    ./users.nix
  ];

  networking = {
    hostName = "alcyone";
    networkmanager.enable = true;
  };
}
