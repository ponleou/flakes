{ ... }:
{
  users.users.access = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDacEJOQjxXOXVkoQ7RdIz9txNq69Lrqc2LE0EU/E3Wa masterkey@pleiades"
    ];
    initialPassword = "";
  };
}
