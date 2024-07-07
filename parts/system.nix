{
  self,
  config,
  inputs,
  lib,
  withSystem,
  ...
}:
let
  inherit (builtins) hashString;
  inherit (lib)
    getName
    elem
    mapAttrs
    attrValues
    substring
    ;

  cfg = config.fp-rndp-lib.nixosConfigurations;

  # Generates a lib.nixosSystem based on given name and config.
  generateSystem = mapAttrs (
    name: conf:
    withSystem conf.hostPlatform.system (
      {
        system,
        inputs',
        self',
        ...
      }:
      let
        inherit (conf.nixpkgs) lib;
        configDir = "${config.fp-rndp-lib.root}/machines/${name}";
        extraArgs = {
          inherit
            self
            self'
            inputs
            inputs'
            ;
          flakeConfig = config;
        };
        allowUnfreePredicate = pkg: elem (getName pkg) conf.unfreeSoftware;
      in
      lib.nixosSystem {
        modules =
          [
            {
              _module.args = extraArgs;
              nixpkgs = {
                inherit (conf) hostPlatform;
              };
              networking.hostName = name;
              networking.hostId = substring 0 8 (hashString "md5" "${name}");
              system.configurationRevision = self.rev or "dirty";
              nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;
              inherit (conf) disabledModules;
            }

            inputs.sops-nix.nixosModules.sops
            { sops.defaultSopsFile = "${configDir}/secrets.yaml"; }
          ]
          ++ lib.optionals (builtins.pathExists "${configDir}/configuration.nix") [
            "${configDir}/configuration.nix"
          ]
          ++ lib.optionals (builtins.pathExists "${configDir}/hardware.nix") [ "${configDir}/hardware.nix" ]
          ++ (attrValues config.flake.nixosModules)
          ++ conf.extraModules
          ++ lib.optionals (conf.home-manager != { } && conf.hmInput != null) [
            conf.hmInput.nixosModule
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = extraArgs;
                  sharedModules = [
                    inputs.sops-nix.homeManagerModule
                  ] ++ (attrValues self.flakeModules.home-manager);
                  users = mapAttrs (
                    name: hmConf:
                    let
                      user = config.users.users.${name};
                    in
                    {
                      imports = [
                        (
                          { config, ... }:
                          {
                            sops = {
                              age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
                              defaultSopsFile = "${configDir}/secrets-home.yaml";
                              defaultSymlinkPath = "/run/user/${toString user.uid}/secrets";
                              defaultSecretsMountPoint = "/run/user/${toString user.uid}/secrets.d";
                            };
                          }
                        )
                      ] ++ lib.optionals (builtins.pathExists "${configDir}/home.nix") [ "${configDir}/home.nix" ];
                    }
                  ) conf.home-manager;
                };
              }
            )
          ];
      }
    )
  );
in
{
  flake.nixosConfigurations = generateSystem cfg;
}
