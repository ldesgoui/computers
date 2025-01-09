{
  services.hickory-dns = {
    settings.zones = [
      { zone = "localhost"; file = ./localhost.zone; }
      { zone = "0.0.127.in-addr.arpa"; file = ./127.0.0.1.zone; }
      { zone = "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa"; file = ./ipv6_1.zone; }
      { zone = "255.in-addr.arpa"; file = ./255.zone; }
      { zone = "0.in-addr.arpa"; file = ./0.zone; }
    ];
  };
}


