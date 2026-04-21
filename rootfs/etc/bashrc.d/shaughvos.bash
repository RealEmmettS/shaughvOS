#!/bin/bash
# shaughvOS terminal session init — runs TR-300 machine report on interactive login.
# ASCII art splash is now rendered inside shaughvos-banner (single source of truth)
# rather than duplicated here. This file only handles the login-time `tr300 --fast` call.

# Only run on interactive shells (guards against sourced/non-interactive contexts)
[[ $- == *i* ]] || return 0

# Opt-out: honor ~/.hushlogin (standard Unix convention)
[[ -f "${HOME:-}/.hushlogin" ]] && return 0

# Opt-out: SHAUGHVOS_NO_AUTORUN=1 disables the login-time machine report
[[ ${SHAUGHVOS_NO_AUTORUN:-} == 1 ]] && return 0

# Skip if stdout isn't a TTY (scp, rsync, non-interactive ssh, etc.)
[[ -t 1 ]] || return 0

# Skip if we've already rendered in this process tree (e.g. sudo -i → bash)
[[ ${SHAUGHVOS_SPLASH_SHOWN:-} ]] && return 0
export SHAUGHVOS_SPLASH_SHOWN=1

# Run TR-300 machine report in fast mode if available
if command -v tr300 &>/dev/null
then
	tr300 --fast
fi

# Convenience alias
alias report='tr300'
