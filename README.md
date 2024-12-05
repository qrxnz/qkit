# qkit

## ⚒️ Installation

### Try it without installing
```sh
nix run github:qrxnz/qkit
```
### Installation

Add input in your flake like:  
```nix
{
 inputs = {
   qkit = {
     url = "github:qrxnz/qkit";
     inputs.nixpkgs.follows = "nixpkgs";
   };
 };
}
```
With the input added you can reference it directly:  

```nix
{ inputs, system, ... }:
{
  # NixOS
  environment.systemPackages = [ inputs.qkit.packages.${pkgs.system}.default ];
  # home-manager
  home.packages = [ inputs.qkit.packages.${pkgs.system}.default ];
}
```
or

You can install this package imperatively with the following command

```nix
nix profile install github:qrxnz/qkit
```
