_:
{ lib, ... }: {
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8Kg9mUIe8h3RMjVJtXkTYK1cHxu5ZX8KHL/+EXlLhO";
  };

  users.users = {
    root.initialPassword = "thisisextremelysafe";
    root.hashedPasswordFile = lib.mkForce null;
    ldesgoui.initialPassword = "thisisverysafe";
    ldesgoui.hashedPasswordFile = lib.mkForce null;
  };
}
