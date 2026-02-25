#!/bin/bash
# Claude Desktop launcher for Arch Linux
#
# Ensures the claude CLI and other user-local tools are visible to
# the Electron process, and sets appropriate Wayland/X11 flags.

# Prepend common user-local binary paths so MCP servers, cowork, etc.
# can find tools like `claude`, `node`, `docker`, `bun`.
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.bun/bin:$PATH"

# Electron environment
export ELECTRON_FORCE_IS_PACKAGED=true
export ELECTRON_USE_SYSTEM_TITLE_BAR=1

FLAGS=(
    --disable-features=CustomTitlebar
    --no-sandbox
)

# Wayland support -- auto-detect by default.
# Set CLAUDE_NO_WAYLAND=1 to force X11/XWayland.
if [ -z "$CLAUDE_NO_WAYLAND" ]; then
    if [ "$XDG_SESSION_TYPE" = "wayland" ] || [ -n "$WAYLAND_DISPLAY" ]; then
        FLAGS+=(
            --enable-features=UseOzonePlatform,WaylandWindowDecorations
            --ozone-platform-hint=auto
        )
    fi
fi

exec /usr/lib/claude-desktop/electron \
    /usr/lib/claude-desktop/resources/app.asar \
    "${FLAGS[@]}" \
    "$@"
