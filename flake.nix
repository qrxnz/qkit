{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      pythonPackages = pkgs.python3Packages;
    in {
      devShells.default = pkgs.mkShell {
        name = "qkit";
        venvDir = "./.venv";
        buildInputs = [
          # A Python interpreter including the 'venv' module is required to bootstrap
          # the environment.
          pythonPackages.python

          # This executes some shell code to initialize a venv in $venvDir before
          # dropping into the shell
          pythonPackages.venvShellHook


          #
          # Normal packages
          #

          # wrapper
          pkgs.gum
          pkgs.cargo


          # bins
          pkgs.curl
        ];

        # Run this command, only after creating the virtual environment
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
          pip install -r requirements.txt
        '';

        # Now we can execute any commands within the virtual environment.
        # This is optional and can be left out to run pip manually.
        postShellHook = ''
          # allow pip to install wheels
          unset SOURCE_DATE_EPOCH

          # cargo bins
          cargo install NtHiM
        '';
      };
    });
}
