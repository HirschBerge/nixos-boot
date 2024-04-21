let
  pkgs = import <nixpkgs> {};
  lib = pkgs.lib;
in
{
  pkgs ? pkgs,
  theme ? (lib.types.str.default("load_unload")), # Specify a default value and the type as string
  # theme ? "load_unload", # TODO: Should be a list when more themes come
  bgColor ? "1, 1, 1", # rgb value between 0-1. TODO: Write hex to plymouth magic
}:
pkgs.stdenv.mkDerivation rec {
  pname = "nixos-boot";
  version = "0.1.0";

  src = ./src;

  buildInputs = [
    pkgs.git
  ];

  unpackPhase = ''
  '';

  configurePhase = ''
    mkdir -p $out/share/plymouth/themes/${theme}
  '';

  buildPhase = ''
    # Set the Background Color
    sed -i 's/\(Window\.SetBackground[^ ]*\).*/\1 (${bgColor});/' "${theme}/${theme}.script"
  '';

  # Currently not multi-theme enabled
  installPhase = ''
    cd ${theme}
    cp *png ${theme}.script ${theme}.plymouth $out/share/plymouth/themes/${theme}
    chmod +x $out/share/plymouth/themes/${theme}/${theme}.plymouth $out/share/plymouth/themes/${theme}/${theme}.script
    sed -i "s@\/usr\/@$out\/@" $out/share/plymouth/themes/${theme}/${theme}.plymouth
  '';
}
