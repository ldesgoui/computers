let
  registry = {
    # hypervisor = 0;
    # local = 1;
    # host = 2;
    "tf2-spot" = 3;
    "mumble-server" = 10;
    "knot-primary" = 11;
    "knot-secondary" = 12;
    "http-proxy" = 13;
  };
in
{
  flake.nixosModules.microvm-vsock-cid = { config, ... }: {
    microvm.vsock.cid =
      registry."${config.networking.hostName}"
        or (throw "failed to pick a VSOCK CID, update computers/nixos/microvm-sock-cid.nix");
  };
}
