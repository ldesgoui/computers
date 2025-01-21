{ self, ... }: {
  perSystem = { ... }: {
    agenix-rekey.nixosConfigurations = {
      inherit (self.nixosConfigurations)
        soldier
        ;
    };
  };
}
