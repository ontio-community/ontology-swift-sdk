#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0")" && pwd)"

cd "${DIR}"

bash base58.sh
bash gmp.sh
bash openssl.sh
bash scrypt.sh
