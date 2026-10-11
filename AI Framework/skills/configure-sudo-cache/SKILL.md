---
name: configure-sudo-cache
description: Configure and troubleshoot bounded sudo credential timestamp caching on Linux, especially when Codex or another automation tool uses a new pseudo-terminal for each command. Use when sudo repeatedly prompts across terminal sessions, a user wants to authenticate once with sudo -v, or automation needs to reuse a recent interactive sudo authentication without storing a password.
---

# Configure Sudo Cache

Configure sudo's built-in timestamp records. Never request, capture, transmit, or store the user's password. Never add `NOPASSWD` unless the user explicitly requests it and accepts the security implications.

## Diagnose

1. Confirm Linux and inspect the installed sudo behavior without changing the system:

   ```bash
   uname -s
   sudo --version
   ```

2. Explain that sudo normally uses `timestamp_type=tty`; commands launched through distinct pseudo-terminals therefore authenticate separately.
3. Check for an existing policy before proposing a new one:

   ```bash
   sudo -n true
   sudo -V | grep -i timestamp
   ```

   Treat a failed `sudo -n true` only as an absent or expired credential, not as permission to collect a password.

## Configure a bounded global timestamp

1. Warn that a global timestamp lets any process running as the same user attempt permitted sudo commands during the cache window. Recommend 15–30 minutes; never default to a negative, non-expiring timeout.
2. Ask for approval before modifying `/etc/sudoers.d`.
3. Have the user run the interactive editor in a terminal where they can enter their password securely:

   ```bash
   sudo visudo -f /etc/sudoers.d/codex-session
   ```

4. Resolve the requesting login name with `id -un`. Add a user-specific policy, replacing `<login-name>` with that name:

   ```sudoers
   Defaults:<login-name> timestamp_type=global
   Defaults:<login-name> timestamp_timeout=30
   ```

5. Validate syntax through `visudo`; do not write sudoers policy with an unchecked redirect or generic file editor.
6. Have the user populate the cache interactively:

   ```bash
   sudo -v
   ```

7. Verify from a separate command session with `sudo -n true`. If it fails, inspect sudo policy and execution isolation instead of weakening authentication.

## Operate safely

- Refresh an active timestamp with `sudo -v`.
- Invalidate the user's current timestamp with `sudo -k`.
- Remove the custom policy only with explicit approval and `sudo visudo -f /etc/sudoers.d/codex-session`, then delete its contents or remove the exact file through an approved command.
- Keep passwords in the user's interactive terminal. Do not accept passwords in chat, command arguments, environment variables, files, or tool input.
