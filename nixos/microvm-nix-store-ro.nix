{
  flake.nixosModules.microvm-nix-store-ro = {
    microvm = {
      shares = [{
        proto = "virtiofs";
        tag = "ro-store";
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
      }];
    };
  };
}
