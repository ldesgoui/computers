{ self, inputs, ... }: {
  system = "x86_64-linux";

  modules =
    (builtins.attrValues {
      inherit (self.nixosModules)
        sniper-nixos
        sniper-hardware
        sniper-storage

        sniper-murmur

        nixos-zfs

        ldesgoui-user

        profiles-defaults
        profiles-nix
        profiles-zfs-datasets

        # age-rekey-settings
        ;
    })
    ++ [
      inputs.home-manager.nixosModules.home-manager
      # inputs.agenix.nixosModules.default
      # inputs.agenix-rekey.nixosModules.default
    ];
}
