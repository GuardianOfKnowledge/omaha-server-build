#!/usr/bin/env bash -euo pipefail
. scripts/check_exit.sh

if [[ $# != 1 ]]; then
    cat "usage: $0 <path_to_dmg>"
    exit 1
fi

ROOT=$(pwd)
APP_PATH="../${1}"
APP_NAME="$(basename "${APP_PATH}")"

mkdir -p tmp && chmod 700 tmp && pushd tmp

if [[ ! -f dsa_priv.pem ]]; then
    ../sparkle/bin/generate_keys
fi

mkdir -p "${APP_PATH}/Contents/Resources"
cp ./dsa_pub.pem "${APP_PATH}/Contents/Resources/test_app_only_dsa_pub.pem"

zip -q -r "${APP_PATH}.zip" "${APP_PATH}"

export DSA_SIGNATURE="$($ROOT/sparkle/bin/sign_update "${APP_PATH}.zip" tmp/dsa_priv.pem)"

$ROOT/scripts/upload.sh "${APP_NAME}"

popd