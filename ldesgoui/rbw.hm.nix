_:
{ pkgs, ... }: {
  programs.rbw = {
    enable = true;
    settings = {
      email = "ldesgoui@gmail.com";
      base_url = "https://vaultwarden.int.lde.sg";
      sync_interval = 600;
      pinentry = pkgs.pinentry;
    };
  };
}
