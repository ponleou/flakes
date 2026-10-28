{ pubkeys, ... }:
{
  users.users.star = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      pubkeys.masterkey
      pubkeys.alcyone
    ];
    initialPassword = "";
    uid = 1003; # pinned cus mounted ntfs drives in drive.nix
  };
}
