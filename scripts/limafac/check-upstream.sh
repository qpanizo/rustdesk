#!/bin/sh
set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
cd "$project_root"

expected_upstream=https://github.com/rustdesk/rustdesk.git
if [ "$(git remote get-url upstream)" != "$expected_upstream" ]; then
  echo 'El remoto upstream no apunta al proyecto original RustDesk.' >&2
  exit 1
fi

git fetch upstream --tags
git log --oneline --max-count=30 HEAD..upstream/master
git diff --stat HEAD...upstream/master
