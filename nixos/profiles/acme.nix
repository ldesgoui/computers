{ config, ... }: {
  age.secrets.gandi-pat = {
    rekeyFile = ./gandi-pat.age;
    owner = "acme";
    group = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "ldesgoui@gmail.com";

      dnsProvider = "gandiv5";
      credentialFiles = {
        GANDIV5_PERSONAL_ACCESS_TOKEN_FILE = config.age.secrets.gandi-pat.path;
      };

      dnsResolver = "1.1.1.1:53";
    };
  };
}
