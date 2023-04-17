#!/bin/bash

set -e

for gemfile in src/api/vendor/cache/*.gem; do
  gem="${gemfile##*/}"
  gem="${gem%-*.gem}"
  if compgen -G "dist/gem-patches/${gem}-*.patch" >/dev/null; then
    echo "Patching $gem"
    tar xf "$gemfile" metadata.gz data.tar.gz
    gemdir="`mktemp -d`"
    tar xzpf data.tar.gz -C "$gemdir"
    compgen -G "dist/gem-patches/${gem}-*.patch" | while read patchfile; do
      echo "Applying $patchfile to $gem"
      patch -d "$gemdir" -p1 < "$patchfile"
    done
    chmod 0644 data.tar.gz
    find "$gemdir" -printf '%P\n' |
    tar czf data.tar.gz -C "$gemdir" --no-recursion -T -
    rm -rf "$gemdir"
    (
      echo ---
      echo SHA1:
      sha1sum metadata.gz data.tar.gz | awk '{printf "  %s: %s\n", $2, $1}'
      echo SHA512:
      sha512sum metadata.gz data.tar.gz | awk '{printf "  %s: %s\n", $2, $1}'
    ) | gzip > checksums.yaml.gz
    chmod 0444 data.tar.gz checksums.yaml.gz
    tar cf "$gemfile" metadata.gz data.tar.gz checksums.yaml.gz
    rm -f metadata.gz data.tar.gz checksums.yaml.gz
  fi
done
