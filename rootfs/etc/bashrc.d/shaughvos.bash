#!/bin/bash
# shaughvOS terminal session init
# Displays ASCII art splash and runs TR-300 machine report on interactive login

# Only run on interactive login shells
[[ $- == *i* ]] || return 0
# Skip if not a login shell or if already displayed this session
[[ ${SHAUGHVOS_SPLASH_SHOWN:-} ]] && return 0
export SHAUGHVOS_SPLASH_SHOWN=1

# shaughvOS ASCII art banner
echo -e '\e[1;35m'
cat << 'BANNER'
     _                       _       ___  ____
 ___| |__   __ _ _   _  __ _| |__   / _ \/ ___|
/ __| '_ \ / _` | | | |/ _` | '_ \ | | | \___ \
\__ \ | | | (_| | |_| | (_| | | | || |_| |___) |
|___/_| |_|\__,_|\__,_|\__, |_| |_| \___/|____/
                       |___/
BANNER
echo -e '\e[0m'

# Run TR-300 machine report (fast mode) if available
if command -v tr300 &>/dev/null
then
	tr300 --fast
fi

# Convenience alias
alias report='tr300'
