_:
{
  zfs.datasets = {
    main = {
      properties = {
        acltype = "posix";
        atime = "off";
        compression = "on";
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";
        xattr = "sa";
      };
    };

    # Cleartext
    main.clr = { };

    # Encrypted
    main.enc = {
      properties = {
        encryption = "on";
        keylocation = "prompt";
        keyformat = "passphrase";
      };
    };

    main.enc.sys.root = {
      mountPoint = "/";
    };

    main.clr.sys.nix = {
      mountPoint = "/nix";

      properties = {
        exec = "on";
      };
    };
  };
}
