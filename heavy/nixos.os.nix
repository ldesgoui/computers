_:
{ lib, ... }: {
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOl9I0HzHom5YxcealhIHeX4M9tWQeLn53SFBDywNd/f";
  };

  programs.coolercontrol = {
    enable = true;
  };
}
