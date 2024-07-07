{ inputs, lib, ... }:
let
  inherit (lib) mkOption types;

  baseConfigType = {
    extraModules = mkOption {
      type = types.listOf types.unspecified;
      default = [ ];
    };
    disabledModules = mkOption {
      type = types.listOf types.unspecified;
      default = [ ];
    };
  };
in
{

  options = {
    fp-rndp-lib = {
      nixosConfigurations = mkOption {
        default = { };
        type = types.attrsOf (
          types.submodule (
            { name, config, ... }:
            {
              options = {
                nixpkgs = mkOption {
                  type = types.unspecified;
                  default = inputs.nixpkgs;
                };
                hostPlatform.system = mkOption {
                  type = types.str; # Is there a type def for system?
                  default = "x86_64-linux";
                };
                unfreeSoftware = mkOption {
                  type = types.listOf types.str;
                  default = [ ];
                };
                hmInput = mkOption {
                  type = types.unspecified;
                  default = null;
                };
                home-manager = mkOption {
                  default = { };
                  type = types.attrsOf (
                    types.submodule (
                      { name, config, ... }:
                      {
                        options = baseConfigType;
                      }
                    )
                  );
                };
              } // baseConfigType;
            }
          )
        );
      };
    };
  };
}
