pkgs: devInputs: devInputs // {
  nativeBuildInputs = with pkgs.haskellPackages; [
    cabal-install
    hlint
    fourmolu
    haskell-language-server
  ];
}
