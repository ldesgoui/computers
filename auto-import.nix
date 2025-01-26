{ lib, self, inputs, withSystem, ... }:
let
  inherit (builtins) concatStringsSep;
  recurse = segments:
    let
      dir = concatStringsSep "/" ([ (toString ./.) ] ++ segments);
      f = modules: name: type:
        let
          file = "${dir}/${name}";
          short-name = builtins.head (lib.splitString "." name);
          full-name = concatStringsSep "-" (segments ++ [ short-name ]);
          applied = import file { inherit lib self inputs withSystem; };
        in
        modules ++ (

          if type == "directory" then
            recurse (segments ++ [ name ])

          else if type == "unknown" then
            [ ]

          else if lib.hasSuffix ".part.nix" name then
            [ file ]

          else if lib.hasSuffix ".computer.nix" name then
            [{
              flake.nixosConfigurations.${full-name} =
                inputs.nixpkgs.lib.nixosSystem (applied // {
                  modules = applied.modules ++ [{
                    networking.hostName = lib.mkDefault full-name;
                  }];
                });
            }]

          else if lib.hasSuffix ".os.nix" name then
            [{
              flake.nixosModules.${full-name} = {
                _file = file;
                imports = [ applied ];
              };
            }]

          else if lib.hasSuffix ".hm.nix" name then
            [{
              flake.modules.homeManager.${full-name} = {
                _file = file;
                imports = [ applied ];
              };
            }]

          else if lib.hasSuffix ".pkg.nix" name then
            [{
              perSystem = { pkgs, ... }: {
                packages.${short-name} = pkgs.callPackage applied { };
              };
            }]

          else
            [ ]
        );
    in
    lib.foldlAttrs f [ ] (builtins.readDir dir);
in
{
  imports = recurse [ ];
}
