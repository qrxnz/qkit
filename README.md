# qkit

> \[!WARNING\]
> `qkit` is constantly being developed, it has many changes and has imperfections :)

## 👾 Features

### Subdomains
 \-

### Revshells

 \-

### Binwalk

`binwalk` has gained automation that allows you to first see the files and make a decision about extraction after viewing them:


## ⚒️  Installation

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
