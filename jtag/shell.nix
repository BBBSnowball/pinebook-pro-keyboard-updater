{ system ? builtins.currentSystem, nixpkgsPath ? <nixpkgs> }:
let
  p1 = import nixpkgsPath { inherit system; };
  p2 = import nixpkgsPath {
    inherit system;
    crossSystem = p1.lib.systems.examples.arm-embedded;
    overlays = [ fixUnnecessaryTargetDepsOverlay ];
  };

  # Some packages are different if the target platform changes but they shouldn't be, in my opinion.
  # For example, Cython uses a GDB for the target but we won't ever use it for RISC-V code.
  fixUnnecessaryTargetDepsOverlay = self: super:
  if (with super.stdenv; buildPlatform.config == hostPlatform.config && hostPlatform.config != targetPlatform.config) then {
    # see https://nixos.wiki/wiki/Overlays#Python_Packages_Overlay
    python3 = super.python3.override {
      packageOverrides = self2: super2: {
        cython = super2.cython.override { inherit (self.pkgsBuildBuild) gdb; };
      };
    };
    python3Packages = self.python3.pkgs;

    thin-provisioning-tools = super.thin-provisioning-tools.override { inherit (self.pkgsBuildBuild) binutils; };
  } else {};

in p1.mkShell {
  buildInputs = (with p2.pkgsBuildHost; [ gcc gcc-unwrapped binutils binutils-unwrapped openocd gdb ]) ++ (with p1; [ srecord ]);
}

