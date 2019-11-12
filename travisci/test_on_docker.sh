#!/bin/bash

brew deps --union "$@" | if grep -q ensembl/moonshine/
then
    echo Test skipped because ensembl/moonshine is not available
else
    brew install --build-from-source "$@"
fi
