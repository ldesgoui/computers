let
  registry = {
    # hypervisor = 0;
    # local = 1;
    # host = 2;
    "mumble-server" = 3;
    "tf2-spot" = 4;
  };
in
{
  flake.nixosModules.microvm-vsock-cid = { config, ... }: {
    microvm.vsock.cid =
      registry."${config.networking.hostName}"
        or (throw "failed to pick a VSOCK CID, update computers/nixos/microvm-sock-cid.nix");
  };
}
