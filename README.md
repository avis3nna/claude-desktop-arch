# claude-desktop-arch

Arch Linux package for Claude Desktop. Repackages the AppImage from [aaddrick/claude-desktop-debian](https://github.com/aaddrick/claude-desktop-debian) into a native pacman package with fixes for Arch and Wayland compositors.

Anthropic does not ship an official Linux build. The upstream project does the hard work of extracting the Windows installer, patching native bindings, and producing a working Linux app. This repo adds the Arch-specific packaging layer.

## Install

```bash
git clone https://github.com/avis3nna/claude-desktop-arch.git
cd claude-desktop-arch
makepkg -si
```

Requires the [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) for cowork and extensions:

```bash
npm install -g @anthropic-ai/claude-code
```

## Update

```bash
cd claude-desktop-arch
./update-version.sh          # check for new upstream release
./update-version.sh --apply  # bump PKGBUILD and update checksums
makepkg -si
```

## What this fixes

The stock AppImage and other AUR packages have several issues on Arch, particularly with Hyprland and other wlroots compositors:

- **`claude` CLI not found** -- Cowork and extensions fail with `executable file not found in $PATH` because the Electron process doesn't inherit your shell's PATH. This package installs a launcher wrapper that prepends `~/.local/bin`, mise shims, and `~/.bun/bin` to PATH before launching Electron.

- **Hardcoded `/usr/local/bin/claude`** -- Cowork also looks for the CLI at a hardcoded path that doesn't exist on typical Arch installs. This package installs a shim there that finds the real binary at runtime.

- **No Wayland flags** -- On Hyprland/Sway, the app runs under XWayland by default. This package auto-detects Wayland sessions and passes the appropriate ozone flags. Set `CLAUDE_NO_WAYLAND=1` to force XWayland if needed.

- **FUSE dependency** -- Other packages run the AppImage as a FUSE blob. This package extracts it at build time and installs files directly -- no FUSE needed.

## Conflicts

This package conflicts with `claude-desktop-appimage`, `claude-desktop-native`, and `claude-desktop`. Only one can be installed at a time.

## Upstream

This package exists because of [aaddrick/claude-desktop-debian](https://github.com/aaddrick/claude-desktop-debian), which extracts Anthropic's Windows installer, replaces native bindings with Linux-compatible stubs, and patches the Electron app. That project produces `.deb`, `.rpm`, and AppImage outputs with CI/CD automation.

The native binding work originates from [k3d3/claude-desktop-linux-flake](https://github.com/k3d3/claude-desktop-linux-flake).

## License

Build scripts and packaging: MIT / Apache-2.0. Claude Desktop itself is proprietary software by [Anthropic](https://www.anthropic.com).
