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
        GANDIV5_PERSONAL_ACCESS_TOKEN = config.age.secrets.gandi-pat;
      };
      dnsProvider = "gandiv5";
      email = "ldesgoui@gmail.com";
    };
  };
}
