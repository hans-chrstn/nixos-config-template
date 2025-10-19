{pkgs}: let
  items = builtins.attrNames (builtins.readDir ./.);
  packageDirs = builtins.filter (item: (builtins.typeOf (builtins.getAttr item ./.)) == "directory") items;
in
  builtins.listToAttrs (map (dir: {
      name = dir;
      value = pkgs.callPackage ./${dir} {};
    })
    packageDirs)
