{
  nixos = {
    common-universal = import ./nixos/common-universal.nix;
    common-linux = import ./nixos/common-linux.nix;
  };

  home-manager = {
  };
}
