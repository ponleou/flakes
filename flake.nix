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
      nixpkgs,
      nixos-raspberrypi,
      ...
    } @ inputs:
    {
      nixosConfigurations.rpi4 = nixos-raspberrypi.lib.nixosSystem {
        specialArgs = { 
          inherit inputs; 
          pubkeys = (import ./constants/pubkeys.nix).pleiades;
          constants = (import ./constants).pleiades;
          };
        modules = [
          ./modules/rpi4
          ./pleiades/alcyone
          { system.stateVersion = "26.05"; }
        ];
      };
    };
}
