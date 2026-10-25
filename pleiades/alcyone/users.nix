{ ... }:
let
  pleiades = (import ../../secrets/public.nix).pleiades;
in
{
  users.users.star = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      pleiades.masterkey
      pleiades.alcyone
    ];
    initialPassword = "";
  };
}
