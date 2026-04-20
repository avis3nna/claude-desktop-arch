#!/bin/bash
# Checks for a new upstream release and updates the PKGBUILD accordingly.
# Usage: ./update-version.sh [--apply]
#
# Without --apply, just prints what would change.
# With --apply, edits the PKGBUILD with new versions and checksums.

set -euo pipefail

UPSTREAM="aaddrick/claude-desktop-debian"

command -v gh >/dev/null || { echo "error: gh CLI required" >&2; exit 1; }
command -v sha256sum >/dev/null || { echo "error: sha256sum required" >&2; exit 1; }

cd "$(dirname "$0")"

latest=$(gh release view --repo "$UPSTREAM" --json tagName --jq .tagName)

# Tag format: v<wrapper>+claude<claude>, e.g. v2.0.0+claude1.3109.0
wrapper_ver=${latest#v}
wrapper_ver=${wrapper_ver%+claude*}
claude_ver=${latest#*+claude}

current_claude=$(grep '^_claude_ver=' PKGBUILD | cut -d= -f2)
current_wrapper=$(grep '^_wrapper_ver=' PKGBUILD | cut -d= -f2)

if [ "$claude_ver" = "$current_claude" ] && [ "$wrapper_ver" = "$current_wrapper" ]; then
    echo "Already up to date: claude=${claude_ver} wrapper=${wrapper_ver}"
    exit 0
fi

echo "Update available:"
echo "  claude:  ${current_claude} -> ${claude_ver}"
echo "  wrapper: ${current_wrapper} -> ${wrapper_ver}"

if [ "${1:-}" != "--apply" ]; then
    echo "Run with --apply to update PKGBUILD"
    exit 0
fi

release_url="https://github.com/${UPSTREAM}/releases/download/v${wrapper_ver}+claude${claude_ver}"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

declare -A sha
for arch_pair in "x86_64:amd64" "aarch64:arm64"; do
    arch=${arch_pair%:*}
    suffix=${arch_pair#*:}
    name="claude-desktop-${claude_ver}-${wrapper_ver}-${suffix}.AppImage"
    echo "Downloading ${name}..."
    curl -fsSL -o "${tmp}/${name}" "${release_url}/${name}"
    sha[$arch]=$(sha256sum "${tmp}/${name}" | awk '{print $1}')
    echo "  ${arch}: ${sha[$arch]}"
done

sed -i "s/^_claude_ver=.*/_claude_ver=${claude_ver}/" PKGBUILD
sed -i "s/^_wrapper_ver=.*/_wrapper_ver=${wrapper_ver}/" PKGBUILD
sed -i "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('${sha[x86_64]}')/" PKGBUILD
sed -i "s/^sha256sums_aarch64=.*/sha256sums_aarch64=('${sha[aarch64]}')/" PKGBUILD

echo
echo "PKGBUILD updated. Review the diff, then:"
echo "  makepkg -si"
echo "  git commit -am 'Update to claude ${claude_ver} (wrapper ${wrapper_ver})'"
