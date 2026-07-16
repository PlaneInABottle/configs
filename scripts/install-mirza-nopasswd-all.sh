#!/usr/bin/env bash
set -Eeuo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_file="$root/sudoers/mirza-nopasswd-all"
target_file=/etc/sudoers.d/90-mirza-nopasswd-all

/usr/sbin/visudo -cf "$source_file"
sudo /usr/bin/install -o root -g root -m 0440 "$source_file" "$target_file"
sudo /usr/sbin/visudo -cf "$target_file"
sudo /usr/bin/cmp --silent "$source_file" "$target_file"

# Remove the superseded limited policy and fixed wrapper only after the full rule is valid.
sudo /usr/bin/rm -f \
  /etc/sudoers.d/codex-home-servers \
  /usr/local/sbin/codex-home-servers

sudo -k
sudo -n /usr/bin/true
[[ $(sudo -n /usr/bin/id -u) == 0 ]]
printf 'MIRZA_NOPASSWD_ALL_INSTALLED\n'
