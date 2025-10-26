{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  programs.zsh.enable = true;

  networking.hostname = "NEW_MACHINE_NAME";

  users.users = {
    "NEW_MACHINE_NAME" = {
      isNormalUser = true;
      description = "Primary user for NEW_MACHINE_NAME";
      extraGroups = ["wheel"];
      password = "123";
      shell = pkgs.zsh;
    };
    root = {
      isSystemUser = true;
      password = "123";
      shell = pkgs.zsh;
    };
  };
}
