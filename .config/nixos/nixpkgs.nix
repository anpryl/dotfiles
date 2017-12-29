# Playing with patches
# This expression returns the /nix/store path to our version of nixpkgs.
# It ensures that all engineers use the same revision of nixpkgs.
#
# This technique was inspired by the article:
#
#   Reproducible Development Environments by Rok Garbas
#   https://garbas.si/2015/reproducible-development-environments.html

let # Note that we depend on a <nixpkgs> in our NIX_PATH. This nixpkgs is only
    # used to access the `fetchFromGitHub` function which is used to fetch the
    # desired version of nixpkgs.
    pkgs = import <nixpkgs> {};

    # Often times you need some modifications to be made to nixpkgs. For example
    # you may have created a Pull Request that makes a change to some NixOS
    # module and it hasn't been merged yet. In those cases you can take the
    # corresponding patch and apply it to the nixpkgs that we've checked out
    # above.
    patches = [
      (pkgs.fetchpatch {
        url = "https://github.com/NixOS/nixpkgs/commit/c177b838dfc3bc9a7744fc8c49fc0833de6c8c40.patch";
        sha256 = "0ffmq2q4aaxr9ks9cdxqsdm3kjqnagmrgh0xijrhk6k9by21vw63";
      })
    ];

in pkgs.runCommand ("nixpkgs-patched") {inherit pkgs patches; } ''
  cp -r $pkgs $out
  chmod -R +w $out
  for p in $patches ; do
    echo "Applying patch $p"
    patch -d $out -p1 < "$p"
  done
''
