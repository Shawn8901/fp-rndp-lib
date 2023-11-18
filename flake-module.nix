{
  imports = [
    # Type definitions
    ./parts/typedefs/hydra-jobs.nix
    ./parts/typedefs/modules.nix
    ./parts/typedefs/system.nix

    # Actual work horses
    ./parts/flake-modules.nix
    ./parts/modules.nix
    ./parts/system.nix
  ];

}
