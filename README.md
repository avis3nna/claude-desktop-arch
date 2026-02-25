# claude-desktop-arch

Claude Desktop for Arch Linux. Repackages the AppImage from [aaddrick/claude-desktop-debian](https://github.com/aaddrick/claude-desktop-debian) as a native pacman package.

All the hard work of extracting the Windows installer, patching native bindings, and building a working Linux app is done by aaddrick's project. This repo handles the Arch-specific layer: proper filesystem layout, PATH fixups for the `claude` CLI, and Wayland/Hyprland flags.

## Install

```bash
git clone https://github.com/avis3nna/claude-desktop-arch.git
cd claude-desktop-arch
makepkg -si
```

## Update

```bash
./update-version.sh          # check for new upstream release
./update-version.sh --apply  # bump PKGBUILD and update checksums
makepkg -si                  # rebuild and install
```

## What this does differently

- Extracts the AppImage at build time -- no FUSE dependency at runtime
- Wrapper script prepends `~/.local/bin` to PATH so the Electron app can find the `claude` CLI (fixes cowork/extensions errors)
- Auto-detects Wayland and sets ozone flags for Hyprland/wlroots compositors
- Set `CLAUDE_NO_WAYLAND=1` to force X11/XWayland if needed

## Upstream

This package exists because of [aaddrick/claude-desktop-debian](https://github.com/aaddrick/claude-desktop-debian), which does the heavy lifting: extracting Anthropic's Windows installer, replacing native bindings with Linux-compatible stubs, and patching the Electron app to run on Linux. That project produces `.deb`, `.rpm`, and AppImage outputs with CI/CD automation.

The native binding replacement ([patchy-cnb](https://github.com/nickvdyck/patchy-cnb)) originates from [k3d3/claude-desktop-linux-flake](https://github.com/k3d3/claude-desktop-linux-flake).

## License

Build scripts: MIT / Apache-2.0. Claude Desktop itself is proprietary software by [Anthropic](https://www.anthropic.com).
