#!/bin/bash
set -euo pipefail

case ${1:-} in
    amd64) platform=x86 ;;
    arm64) platform=arm ;;
    *) printf 'Usage: %s {amd64|arm64} [output-directory]\n' "$0" >&2; exit 2 ;;
esac
arch=$1
source_dir=$(cd -- "$(dirname -- "$0")" && pwd -P)
mkdir -p -- "${2:-dist/fnos}"
output_dir=$(cd -- "${2:-dist/fnos}" && pwd -P)
fnpack=$(command -v "${FNPACK:-fnpack}")
fnpack=$(realpath -- "$fnpack")
version=$(awk -F= '$1 == "version" {print $2}' "$source_dir/package/manifest")
asset="openlist-linux-musl-$arch.tar.gz"
work_dir=$(mktemp -d /tmp/openlist-fpk.XXXXXXXX)
trap 'if [[ $work_dir == /tmp/openlist-fpk.* && -d $work_dir ]]; then rm -rf -- "$work_dir"; fi' EXIT

if [[ -n ${OPENLIST_ASSET_DIR:-} && -f $OPENLIST_ASSET_DIR/$asset ]]; then
    cp -- "$OPENLIST_ASSET_DIR/$asset" "$work_dir/$asset"
else
    curl --fail --silent --show-error --location --retry 3 \
        "https://github.com/OpenListTeam/OpenList/releases/download/v$version/$asset" \
        --output "$work_dir/$asset"
fi
checksum=$(awk -v asset="$asset" '$2 == asset {print}' "$source_dir/SHA256SUMS")
[[ -n $checksum ]]
(cd -- "$work_dir" && sha256sum --check <<< "$checksum")

package_dir=$work_dir/package
cp -a -- "$source_dir/package" "$package_dir"
printf 'platform=%s\n' "$platform" >> "$package_dir/manifest"
tar -xOzf "$work_dir/$asset" openlist > "$package_dir/app/openlist"
chmod 755 "$package_dir/app/openlist"
cp -- "$source_dir/../../LICENSE" "$package_dir/app/LICENSE"
(cd -- "$package_dir" && "$fnpack" build --nosign)
cp -- "$package_dir/openlist-fnos.fpk" "$output_dir/OpenList-$version-fnOS-$arch.fpk"
printf '%s\n' "$output_dir/OpenList-$version-fnOS-$arch.fpk"
