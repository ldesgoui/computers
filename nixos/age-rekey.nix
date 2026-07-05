{ self, ... }:
{
  flake.nixosModules.age-rekey-settings =
    { config, ... }: {
      age.generators = {
        knot-tsig = { secret, pkgs, ... }: ''
          ${pkgs.knot-dns}/bin/keymgr generate --tsig '${secret.settings.id}' ${secret.settings.algorithm or "hmac-sha512"}
        '';

        deps-to-env = { decrypt, deps, lib, pkgs, ... }:
          let
            env = lib.concatMapAttrsStringSep " "
              (name: secret:
                ''${name}="$(${decrypt} ${lib.escapeShellArg secret.file})"''
              )
              deps;
            query =
              "{"
              + lib.concatMapAttrsStringSep ", " (name: _: ''"${name}": strenv(${name})'') deps
              + "}";
          in
          ''
            ${env} ${pkgs.yq-go}/bin/yq -n -o=shell ${lib.escapeShellArg query}
          '';
      };

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
    };
}
