#!/bin/bash
# Checks for a new upstream release and updates the PKGBUILD accordingly.
# Usage: ./update-version.sh [--apply]
#
# Without --apply, just prints what would change.
# With --apply, edits the PKGBUILD and updates checksums.

set -euo pipefail

UPSTREAM="aaddrick/claude-desktop-debian"

latest=$(gh release view --repo "$UPSTREAM" --json tagName --jq .tagName)

# Tag format: v1.3.14+claude1.1.4173
wrapper_ver=$(echo "$latest" | sed 's/^v//; s/+claude.*//')
claude_ver=$(echo "$latest" | sed 's/.*+claude//')

current_claude=$(grep '^_claude_ver=' PKGBUILD | cut -d= -f2)
current_wrapper=$(grep '^_wrapper_ver=' PKGBUILD | cut -d= -f2)

if [ "$claude_ver" = "$current_claude" ] && [ "$wrapper_ver" = "$current_wrapper" ]; then
    echo "Already up to date: claude=${claude_ver} wrapper=${wrapper_ver}"
    exit 0
fi

echo "Update available:"
echo "  claude: ${current_claude} -> ${claude_ver}"
echo "  wrapper: ${current_wrapper} -> ${wrapper_ver}"

if [ "${1:-}" != "--apply" ]; then
    echo "Run with --apply to update PKGBUILD"
    exit 0
fi

sed -i "s/^_claude_ver=.*/_claude_ver=${claude_ver}/" PKGBUILD
sed -i "s/^_wrapper_ver=.*/_wrapper_ver=${wrapper_ver}/" PKGBUILD

# Update checksums
updpkgsums

echo "PKGBUILD updated. Review changes, then:"
echo "  makepkg --printsrcinfo > .SRCINFO"
echo "  git commit -am 'Update to claude ${claude_ver}'"
