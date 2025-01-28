_:
{
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8Kg9mUIe8h3RMjVJtXkTYK1cHxu5ZX8KHL/+EXlLhO";
  };

  boot.zfs.forceImportRoot = true;

  users.users.ldesgoui.homeMode = "711"; # services need x
}
