#!/bin/bash

set -euo pipefail

cd /home/linuxbrew/EnsemblTaps
for i in *
do
    TARGET="/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/ensembl/$i"
    rm -rf "$TARGET"
    cp -a "$i" "$TARGET"
done

brew deps --union "$@" | if grep -q ensembl/moonshine/
then
    echo Test skipped because the formulae rely on ensembl/moonshine, which is not available:
    brew deps --union "$@" | grep ensembl/moonshine/
else
    brew install --build-from-source "$@"
fi
