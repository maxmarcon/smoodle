#!/usr/bin/env bash

case $1 in
  major|minor|patch)
  ;;
  *)
  echo "Usage: $0 <major|minor|patch>"
  exit 1
esac

MIX_VERSION=$(mix version.current)
NPM_VERSION=$(cd webapp && jq --raw-output .version package.json)

if [ $MIX_VERSION != $NPM_VERSION ]; then
  echo "Current version mismatch: MIX_VERSION=${MIX_VERSION}, but NPM_VERSION=${NPM_VERSION}"
  exit 1
fi

(cd webapp && yarn version --no-git-tag-version --non-interactive --$1) &&
  git add webapp/package.json &&
  mix version.up $1 &&
  mix version.tag
