#!/bin/bash

set -euo pipefail

username=""
password=""
auth_payload="${AUTH_PAYLOAD:-}"

if [ $# -ge 3 ] && [[ "$1" == *:* ]]; then
    auth_payload="$2"
elif [ $# -ge 2 ]; then
    username="${1:-}"
    password="${2:-}"
fi

if [ -n "$auth_payload" ]; then
    if [[ "$auth_payload" == *:* ]]; then
        username="${auth_payload%%:*}"
        password="${auth_payload#*:}"
    elif [[ "$auth_payload" == *" "* ]]; then
        username="${auth_payload%% *}"
        password="${auth_payload#* }"
    fi
fi

username="${username:-${USERNAME:-}}"
password="${password:-${PASSWORD:-}}"

if [ -z "$username" ]; then
    read -r username || username=""
fi

if [ -z "$password" ]; then
    read -r password || password=""
fi

if [ -z "$username" ] || [ -z "$password" ]; then
    echo "missing credentials" >&2
    exit 1
fi

if ! id "$username" >/dev/null 2>&1; then
    echo "authentication failed" >&2
    exit 1
fi

python3 - "$username" "$password" <<'PY'
import sys

username = sys.argv[1]
password = sys.argv[2]

try:
    import pam  # type: ignore
except Exception:
    sys.exit(1)

auth = pam.pam()
ok = auth.authenticate(username, password, service="login")
if ok:
    print(username)
sys.exit(0 if ok else 1)
PY
