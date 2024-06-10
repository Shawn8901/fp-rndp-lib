# Flake-Parts Random person lib

This is just a small lib from a random person from the internet around flake parts, that provides some useful functions to create my own flake configs.

## Motivation

Just some deduplication between [my private setups](https://github.com/shawn8901/nix-configuration) and my work setups (hosted on a GitHub-Enterprise), without pulling my whole private flake into the work nix store.
If you find it useful for your own flake-parts, feels free to use or copy whats useful for you. 🙂

## Disclaimer

There is no garantuee that the library is working or doing something useful. In case you want to use it and observe an error, feel free to create an issue or an pull request in case you already have a patch.
But it might take some time to responde from my side. So you have been warned.

## System configuration

A system can be defined by the following code block and will build a `nixpkgs.lib.nixosSystem`.

```nix
config.fp-rndp-lib.nixosConfigurations = {
  myhostname = {
    nixpkgs = inputs.nixpkgs-stable;
  };
};
```

The configuration can be extended by some options

- nixpkgs - nixpkgs to use for that host
- setupNixRegistry - boolean flag, if the flake should be setup in nix registry
- hostPlatform.system - system for the config defaults x86-64 (other arch like aarch64 or skylake)
- unfreeSoftware - list of unfree software
- hmInput - Home Manager input to use, defaults to null to not use HM
- extraModules - extra modules to load
- disabledModules - modules to disable from nixpkgs
- home-manager - definition for home manager

For home-manager the following options are setable

- extraModules - extra modules to load
- disabledModules - modules to disable from home manager

### Expected folder structure for system configs

- machines
  - `<hostname>`
    - configuration.nix
    - hardware.nix
    - home.nix (optional, can be used when home-manager is active)
    - secret.yaml (default sops file for system)
    - secrets-home.yaml (default sops file for home manager when used)

## Modules

Modules are the heart of NixOS, flakes often define some addional logic or custom modules.
fp-rndp-lib supports exposing modules from the flake and will auto load the exposed modules to the system configuration.

Modules can be defined by the following code block

```nix

config.fp-rndp-lib.modules.nixos = {
  public = ./nixos/public;
  private = ./nixos/private;
};

config.fp-rndp-lib.modules.home-manager = {
  public = ./home-manager/public;
  private = ./home-manager/private;
};
```

`config.fp-rndp-lib.modules.nixos` exposes modules as `nixosModules` and `flakeModules.nixos`, whilst `config.fp-rndp-lib.modules.home-manager` exposes HM modules to `flakeModules.home-manager`.

Public modules are exposed with the name of the folders or the nix files that is located at the path stored.
Private modules get a prefix attached, that has to be defined with `fp-rndp-lib.privateNamePrefix`
fp-rndp-lib expects either a nix file or a folder below the defined path.

## Packages

There is no special handling for packages in fp-rndp-lib. Just use the plain flake-parts code.

# Examples

- [test-config](https://github.com/Shawn8901/test-config) - Example config that helped me on externalizing the fp-rndp-lib from my personal config
- [nix-configuration](https://github.com/Shawn8901/nix-configuration) - My personal config
