{ 
  description = "A pack of the custom fonts used in the hit GBA game series Megaman Batte Network";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  
  outputs = { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forEachSystem = nixpkgs.lib.genAttrs systems;

      overlayList = [ self.overlays.default ];

      pkgsBySystem = forEachSystem ( system:
        import nixpkgs {
          inherit system;
          overlays = overlayList;
        }
      );

      pname = "mmbn-fonts";
    in {

      overlays.default = final: prev: {
        ${pname} = final.callPackage ./mmbn-fonts.nix {};
      };

      packages = forEachSystem ( system: {
        ${pname} = pkgsBySystem.${system}.${pname};
        default = pkgsBySystem.${system}.${pname};
      });
      # packages.${system} = pkgs.callPackage ./mmbn-fonts.nix { };
    };
}
