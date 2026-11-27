#!/bin/bash
set -euo pipefail

case ${1:-} in
    amd64) platform=x86 ;;
    arm64) platform=arm ;;
    *) printf 'Usage: %s {amd64|arm64} [output-directory] [upstream-release.json]\n' "$0" >&2; exit 2 ;;
esac
arch=$1
source_dir=$(cd -- "$(dirname -- "$0")" && pwd -P)
mkdir -p -- "${2:-dist/fnos}"
output_dir=$(cd -- "${2:-dist/fnos}" && pwd -P)
fnpack=$(command -v "${FNPACK:-fnpack}")
fnpack=$(realpath -- "$fnpack")
asset="openlist-linux-musl-$arch.tar.gz"
work_dir=$(mktemp -d /tmp/openlist-fpk.XXXXXXXX)
trap 'if [[ $work_dir == /tmp/openlist-fpk.* && -d $work_dir ]]; then rm -rf -- "$work_dir"; fi' EXIT

release_json=${3:-$work_dir/release.json}
if [[ $# -lt 3 ]]; then
    curl --fail --silent --show-error --location --retry 3 --max-time 60 \
        https://api.github.com/repos/OpenListTeam/OpenList/releases/latest \
        --output "$release_json"
fi
tag=$(jq -er 'select(.draft == false and .prerelease == false) | .tag_name // empty' "$release_json")
if [[ ! $tag =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf 'Unexpected OpenList release tag: %s\n' "$tag" >&2
    exit 1
fi
revision=$(<"$source_dir/revision")
if [[ ! $revision =~ ^[1-9][0-9]*$ ]]; then
    printf 'Invalid fnOS package revision: %s\n' "$revision" >&2
    exit 1
fi
version=${tag#v}-$revision
digest=$(jq -er --arg asset "$asset" '.assets[] | select(.name == $asset) | .digest // empty' "$release_json")
if [[ ! $digest =~ ^sha256:[0-9a-f]{64}$ ]]; then
    printf 'Invalid SHA-256 digest for %s in %s\n' "$asset" "$tag" >&2
    exit 1
fi

if [[ -n ${OPENLIST_ASSET_DIR:-} && -f $OPENLIST_ASSET_DIR/$asset ]]; then
    cp -- "$OPENLIST_ASSET_DIR/$asset" "$work_dir/$asset"
else
    curl --fail --silent --show-error --location --retry 3 --max-time 300 \
        "https://github.com/OpenListTeam/OpenList/releases/download/$tag/$asset" \
        --output "$work_dir/$asset"
fi
(cd -- "$work_dir" && printf '%s  %s\n' "${digest#sha256:}" "$asset" | sha256sum --check)

package_dir=$work_dir/package
cp -a -- "$source_dir/package" "$package_dir"
printf 'version=%s\nplatform=%s\n' "$version" "$platform" >> "$package_dir/manifest"
tar -xOzf "$work_dir/$asset" openlist > "$package_dir/app/openlist"
chmod 755 "$package_dir/app/openlist"
cp -- "$source_dir/../../LICENSE" "$package_dir/app/LICENSE"
cp -- "$source_dir/logo/LICENSE" "$source_dir/logo/NOTICE.md" "$package_dir/app/ui/images/"
(cd -- "$package_dir" && "$fnpack" build --nosign)
cp -- "$package_dir/openlist-fnos.fpk" "$output_dir/OpenList-$version-fnOS-$arch.fpk"
printf '%s\n' "$output_dir/OpenList-$version-fnOS-$arch.fpk"
