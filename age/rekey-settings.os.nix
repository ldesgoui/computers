{ self, ... }:
{ config, ... }: {
  age.rekey = {
    masterIdentities = [
      {
        identity = "${self}/age/yubikey-id.pub";
        pubkey = "age1yubikey1q2s7ye4w4t33arh2g6zkz79yekmed7sf8gc3kcdcyx3cgqlv8e66gmemh69";
      }
      {
        identity = "${self}/age/master.age";
        pubkey = "age1muncma6qvwmetka89lrtyeslkfg2ks8g8kp42gt299zraflrcpusa08eus";
      }
    ];
    storageMode = "local";
    localStorageDir = "${self}/age/${config.networking.hostName}";
  };
}
