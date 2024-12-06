{
  description = "A best script!";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        my-name = "qkit";
        my-buildInputs = with pkgs; [
          ddate
          gum
          amass
        ];
        qkit = (pkgs.writeScriptBin my-name (builtins.readFile ./qkit.sh)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in rec {
        defaultPackage = packages.qkit;
        packages.qkit = pkgs.symlinkJoin {
          name = my-name;
          paths = [ qkit ] ++ my-buildInputs;
          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${my-name} --prefix PATH : $out/bin";
        };
      }
    );
}
