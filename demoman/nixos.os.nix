_:
{ lib, pkgs, ... }: {
  age.rekey = {
    hostPubkey = "ssh-ed25519 ";
  };
}
