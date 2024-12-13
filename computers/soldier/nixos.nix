{ config, inputs, ... }: {
  networking.hostName = "soldier";

  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8Kg9mUIe8h3RMjVJtXkTYK1cHxu5ZX8KHL/+EXlLhO";
    storageMode = "local";
    localStorageDir = "${inputs.self}/computers/soldier/secrets";
  };

  system.stateVersion = "24.11";

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.ldesgoui = {
    home.stateVersion = "24.11";
  };

  ldesgoui = {
    enable = true;
    graphical = false;
  };

  powerManagement.powertop.enable = true;

  services.openssh = {
    enable = true;
  };


  networking.firewall.trustedInterfaces = [ "wg0" ];
  networking.wireguard.interfaces.wg0 = {
    #  unCcOBXewoh78MG3E7o3cfaDgEE2A/2y1P684ppD4Ug=
    ips = [
      "10.77.67.2/24"
      "fc00:7767::2/128"
    ];

    privateKeyFile = config.age.secrets.wireguard-privkey.path;

    peers = [{
      publicKey = "QDEuEy768a+sQ2w+jvAzx2OJmHHgcaPpKQlifVFgzF0=";

      allowedIPs = [
        "10.77.67.0/24"
        "fc00:7767::/24"
      ];

      endpoint = "ldesgoui.xyz:51820";
      persistentKeepalive = 25;
    }];
  };
  age.secrets.wireguard-privkey = {
    rekeyFile = ./secrets/wireguard-privkey.age;
  };

}
