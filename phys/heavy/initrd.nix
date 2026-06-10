# shoutout to da elvish jerricco
{ config, lib, utils, ... }: {
  boot.initrd = {
    network = {
      enable = true;

      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/ssh/host-keys/initrd_ed25519" ];
        authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      };
    };

    systemd.enable = true;

    systemd.emergencyAccess = true;

    # We replace the NixOS implementation
    systemd.services.zfs-import-bagel.enable = false;

    systemd.services.zfs-import-bare-bagel =
      let
        # Compute the systemd units for the devices in the pool
        devices = map (p: utils.escapeSystemdPath p + ".device") [
          config.disko.devices.disk.transcend-mte110s.device
        ];
      in
      {
        after = [ "modprobe@zfs.service" ] ++ devices;
        requires = [ "modprobe@zfs.service" ];

        # Devices are added to 'wants' instead of 'requires' so that a
        # degraded import may be attempted if one of them times out.
        # 'cryptsetup-pre.target' is wanted because it isn't pulled in
        # normally and we want this service to finish before
        # 'systemd-cryptsetup@.service' instances begin running.
        wants = [ "cryptsetup-pre.target" ] ++ devices;
        before = [ "cryptsetup-pre.target" ];

        unitConfig.DefaultDependencies = false;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        path = [ config.boot.zfs.package ];
        enableStrictShellChecks = true;
        script =
          let
            # Check that the FSes we're about to mount actually come from
            # our encryptionroot. If not, they may be fraudulent.
            shouldCheckFS = fs: fs.fsType == "zfs" && utils.fsNeededForBoot fs;
            checkFS = fs: ''
              encroot="$(zfs get -H -o value encryptionroot ${fs.device})"
              if [ "$encroot" != bagel/heavy ]; then
                echo ${fs.device} has invalid encryptionroot "$encroot" >&2
                exit 1
              else
                echo ${fs.device} has valid encryptionroot "$encroot" >&2
              fi
            '';
          in
          ''
            function cleanup() {
              exit_code=$?
              if [ "$exit_code" != 0 ]; then
                zpool export bagel
              fi
            }
            trap cleanup EXIT

            zpool import -N -d /dev/disk/by-id bagel

            # Check that the file systems we will mount have the right encryptionroot.
            ${lib.concatStringsSep "\n" (lib.map checkFS (lib.filter shouldCheckFS config.system.build.fileSystems))}
          '';
      };

    # Adding an fstab is the easiest way to add file systems whose
    # purpose is solely in the initrd and aren't a part of '/sysroot'.
    # The 'x-systemd.after=' might seem unnecessary, since the mount                                                                                                
    # unit will already be ordered after the mapped device, but it
    # helps when stopping the mount unit and cryptsetup service to
    # make sure the LUKS device can close, thanks to how systemd
    # orders the way units are stopped.
    supportedFilesystems.ext4 = true;
    systemd.contents."/etc/fstab".text = ''
      /dev/mapper/heavy-keys /etc/credstore ext4 defaults,x-systemd.after=systemd-cryptsetup@${utils.escapeSystemdPath "heavy-keys"}.service 0 2
    '';

    # Add some conflicts to ensure the credstore closes before leaving initrd.
    systemd.targets.initrd-switch-root = {
      conflicts = [
        "etc-credstore.mount"
        "systemd-cryptsetup@${utils.escapeSystemdPath "heavy-keys"}.service"
      ];
      after = [
        "etc-credstore.mount"
        "systemd-cryptsetup@${utils.escapeSystemdPath "heavy-keys"}.service"
      ];
    };

    # Though, we need to make sure udev remains up while credstore is closing.
    # Orderings during stop jobs are reversed.
    systemd.services.systemd-udevd.before = [
      "systemd-cryptsetup@${utils.escapeSystemdPath "heavy-keys"}.service"
    ];

    # After the pool is imported and the credstore is mounted, finally
    # load the key. This uses systemd credentials, which is why the
    # credstore is mounted at '/etc/credstore'. systemd will look
    # there for a credential file called 'zfs-sysroot.mount' and
    # provide it in the 'CREDENTIALS_DIRECTORY' that is private to
    # this service. If we really wanted, we could make the credstore a
    # 'WantsMountsFor' instead and allow providing the key through any
    # of the numerous other systemd credential provision mechanisms.
    systemd.services.zfs-load-key-bagel = {
      requiredBy = [ "initrd.target" ];
      before = [ "sysroot.mount" "initrd.target" ];
      requires = [ "zfs-import-bare-bagel.service" ];
      after = [ "zfs-import-bare-bagel.service" ];

      unitConfig = {
        DefaultDependencies = false;
        RequiresMountsFor = "/etc/credstore";
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ImportCredential = "heavy.passphrase";
        ExecStart = "${config.boot.zfs.package}/bin/zfs load-key -L file://%d/heavy.passphrase bagel/heavy";
      };
    };

    systemd.services.symlink-machine-id = {
      after = [ "var-lib-systemd.mount" ];
      before = [ "initrd-switch-root.target" ];

      serviceConfig.Type = "oneshot";

      script = ''
        mkdir -p /sysroot/etc
        ln -sf /var/lib/systemd/machine-id /sysroot/etc/machine-id
      '';
    };
  };
}
