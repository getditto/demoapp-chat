#!/bin/sh

code=$(cat <<EOS

import Foundation

// This file is auto generated. Do not edit this, and edit .env instead.

struct Env {

EOS
)

if [ $# -ne 2 ]; then
  echo "require 2 arguments." 1>&2
  echo "./buildEnv.sh /path/to/.env /output/path" 1>&2
  exit 1
fi

# Fail loudly if the shared .env is missing rather than emitting an empty Env.swift,
# which would surface downstream as a confusing "Type 'Env' has no member" build error.
if [ ! -f "$1" ]; then
  echo "Ditto .env not found at \"$1\". Copy .env.template to .env at the repo root and fill it in." 1>&2
  exit 1
fi

if [ -f "$1" ]; then
    while IFS='' read -r line || [[ -n "$line" ]]; do
        line="${line//[$'\r\n']}"
        trimline="${line//[$'\t\r\n ']}"
        # Skip blank lines and # comments, and trim whitespace around the key and
        # value. This matches java.util.Properties (the Android parser) so the
        # shared .env means the same thing on both platforms — in particular a
        # stray space around '=' can't silently become a space-prefixed
        # credential, and a # comment can't break the generated Env.swift.
        case "$trimline" in
            ''|'#'*) continue ;;
        esac
        KEY=$(printf '%s' "${line%%=*}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        VALUE=$(printf '%s' "${line#*=}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        code=$(cat <<EOS
        $code
    static let $KEY = "$VALUE"
EOS
)
    done < "$1"
fi

code=$(cat <<EOS
$code
}
EOS
)

echo "${code}" > "$2/Env.swift"

exit 0
