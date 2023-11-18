{ lib, ... }:
let inherit (lib) mkOption types literalExpression;
in {
  options = {
    fp-rndp-lib = {
      root = mkOption {
        type = types.pathInStore;
        example = literalExpression "./.";
        default = ./.;
        description = ''
          The root from which configurations and modules should be searched.
        '';
      };
      generateModule = mkOption { type = types.raw; };
    };
  };
}
