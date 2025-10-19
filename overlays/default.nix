{inputs}: let
  overlayFiles = builtins.attrNames (builtins.readDir ./.);
  filteredFiles = builtins.filter (file: file != "default.nix") overlayFiles;
in
  map (file: (import ./${file})) filteredFiles
