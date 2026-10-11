---
name: install-wsl-browser-bridge
description: "Diagnose and restore opening Windows browser URLs from Linux under WSL by installing and verifying the wslview browser bridge from the Ubuntu wslu package. Use when xdg-open reports 'wslview: not found', Azure CLI cannot launch a login browser, or a Codex/WSL command needs to open an HTTP or HTTPS URL in the Windows default browser."
---

# Install WSL Browser Bridge

Restore URL opening from WSL with the distribution's packaged `wslu`/`wslview` integration.

## Diagnose

1. Confirm WSL before installing WSL-specific software:

   ```bash
   uname -a
   test -n "${WSL_DISTRO_NAME:-}" || grep -qi microsoft /proc/sys/kernel/osrelease
   command -v xdg-open || true
   command -v wslview || true
   ```

2. If `wslview` exists, test it instead of reinstalling. Ask for approval before opening a GUI or browser.
3. On Ubuntu or Debian, confirm the package candidate:

   ```bash
   apt-cache policy wslu
   ```

4. If the system is not WSL, stop and diagnose the actual desktop opener. Do not install `wslu` on ordinary Linux.

## Install on Ubuntu or Debian under WSL

1. Ask for approval before changing system packages.
2. Install from the configured distribution repository:

   ```bash
   sudo apt-get update
   sudo apt-get install -y wslu
   ```

3. If sudo requires authentication, tell the user to run `sudo -v` in their interactive terminal. Never request or transmit their password.
4. Verify installation:

   ```bash
   command -v wslview
   wslview --version
   ```

5. With approval to open the Windows browser, test:

   ```bash
   wslview https://example.com
   ```

6. Retry the original command, such as `az login`. Use `az login --use-device-code` as a non-browser fallback when appropriate.

## Troubleshoot

- If `wslview` is installed but `xdg-open` still fails, inspect `xdg-settings get default-web-browser` and the desktop MIME associations before changing them.
- If Windows interop executables cannot run, inspect `/etc/wsl.conf` and WSL interoperability status; do not overwrite WSL configuration without explicit approval.
- Prefer the distribution package over copying `wslview` scripts or creating a framework-maintained fork.
