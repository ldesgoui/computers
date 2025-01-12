{
  mailserver = {
    enable = true;
    fqdn = "mx.ldesgoui.xyz";
    domains = [ "ldesgoui.xyz" "lde.sg" "piss-your.se" ];

    certificateScheme = "acme";

    loginAccounts = {
      "ldesgoui@ldesgoui.xyz" = {
        # hashedPassword = import ../secrets/email/ldesgoui.nix;
        hashedPasswordFile = "/etc/secrets/email/ldesgoui@ldesgoui.xyz";
        catchAll = [ "ldesgoui.xyz" "lde.sg" ];
        aliases = [ "@scw.ldesgoui.xyz" "@mx.ldesgoui.xyz" "@localhost" ];
      };
    };
  };
}
