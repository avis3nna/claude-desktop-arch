# Maintainer: Avi <avis3nna on GitHub>
# Upstream: https://github.com/aaddrick/claude-desktop-debian
#
# Extracts the AppImage from aaddrick/claude-desktop-debian and installs
# it as a native package -- no FUSE dependency, proper PATH handling,
# and Wayland flags for Hyprland/wlroots compositors.

pkgname=claude-desktop
_claude_ver=1.1.4173
_wrapper_ver=1.3.14
pkgver=${_claude_ver}
pkgrel=1
pkgdesc="Claude Desktop for Linux"
arch=('x86_64')
url="https://github.com/avis3nna/claude-desktop-arch"
_upstream="https://github.com/aaddrick/claude-desktop-debian"
license=('MIT' 'Apache-2.0')
depends=('gtk3' 'nss' 'alsa-lib' 'libxss')
optdepends=(
    'docker: for MCP servers that require containers'
    'libnotify: desktop notifications'
)
provides=('claude-desktop')
conflicts=('claude-desktop' 'claude-desktop-appimage' 'claude-desktop-native')
options=(!strip !debug)

_appimage="claude-desktop-${_claude_ver}-${_wrapper_ver}-amd64.AppImage"
source=(
    "${_upstream}/releases/download/v${_wrapper_ver}+claude${_claude_ver}/${_appimage}"
    "claude-desktop.sh"
    "claude-desktop.desktop"
)
noextract=("${_appimage}")
sha256sums=('ca855730d61da82a1219619fd984999246b52813b695dbe1747d1fd5e2d6404a'
            'SKIP'
            'SKIP')

prepare() {
    chmod +x "${srcdir}/${_appimage}"
    "${srcdir}/${_appimage}" --appimage-extract >/dev/null 2>&1
}

package() {
    cd "${srcdir}/squashfs-root"

    # Install the bundled Electron runtime and application
    install -dm755 "${pkgdir}/usr/lib/claude-desktop"
    cp -a usr/lib/node_modules/electron/dist/* "${pkgdir}/usr/lib/claude-desktop/"

    # Install launcher wrapper
    install -Dm755 "${srcdir}/claude-desktop.sh" "${pkgdir}/usr/bin/claude-desktop"

    # Install desktop entry
    install -Dm644 "${srcdir}/claude-desktop.desktop" \
        "${pkgdir}/usr/share/applications/claude-desktop.desktop"

    # Install icons
    local _icon="io.github.aaddrick.claude-desktop-debian.png"
    if [ -f "${_icon}" ]; then
        install -Dm644 "${_icon}" \
            "${pkgdir}/usr/share/icons/hicolor/256x256/apps/claude-desktop.png"
        install -Dm644 "${_icon}" \
            "${pkgdir}/usr/share/pixmaps/claude-desktop.png"
    fi

    # Install hicolor icons at multiple sizes if available
    for size in 16 32 48 64 128 256 512; do
        local _sized="usr/share/icons/hicolor/${size}x${size}/apps/claude-desktop.png"
        if [ -f "${_sized}" ]; then
            install -Dm644 "${_sized}" \
                "${pkgdir}/usr/share/icons/hicolor/${size}x${size}/apps/claude-desktop.png"
        fi
    done

    # The app hardcodes /usr/local/bin/claude as the path to the Claude Code CLI.
    # Install a wrapper that finds the real binary via PATH at runtime.
    install -dm755 "${pkgdir}/usr/local/bin"
    cat > "${pkgdir}/usr/local/bin/claude" << 'WRAPPER'
#!/bin/sh
# Shim for Claude Desktop -- the app hardcodes /usr/local/bin/claude
# but the CLI is typically installed at ~/.local/bin/claude via npm.
for d in "$HOME/.local/bin" "$HOME/.local/share/mise/shims" "$HOME/.bun/bin"; do
    [ -x "$d/claude" ] && exec "$d/claude" "$@"
done
echo "claude CLI not found. Install it: npm install -g @anthropic-ai/claude-code" >&2
exit 1
WRAPPER
    chmod 755 "${pkgdir}/usr/local/bin/claude"
}
