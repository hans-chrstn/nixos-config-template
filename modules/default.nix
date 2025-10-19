{
  nixos = {
    common-universal = import ./nixos/common-universal;
    common-linux = import ./nixos/common-linux;
  };

  home-manager = {
  };
}
