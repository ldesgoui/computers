{ config, ... }: {
  age.secrets.gandi-pat = {
    rekeyFile = ./gandi-pat.age;
    owner = "acme";
    group = "acme";
  };

  security.acme = {
    acceptTerms = true;
    defaults = {
      credentialFiles = {
        GANDIV5_PERSONAL_ACCESS_TOKEN_FILE = config.age.secrets.gandi-pat.path;
      };
      dnsProvider = "gandiv5";
      email = "ldesgoui@gmail.com";
    };
  };
}
