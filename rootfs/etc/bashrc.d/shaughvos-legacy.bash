#!/bin/bash
{
	#////////////////////////////////////
	# shaughvOS bash init script
	#
	#////////////////////////////////////
	# Created by MichaIng / micha@shaughvos.com / shaughvos.com
	#
	#////////////////////////////////////
	#
	# Info:
	# - Location: /etc/bashrc.d/shaughvos.bash
	# - Sourced by all interactive bash shells from: /etc/bash.bashrc
	# - Prepares shell for shaughvOS and runs autostarts on /dev/tty1
	#////////////////////////////////////

	# Failsafe: Never load this script in non-interactive shells, e.g. SFTP, SCP or rsync
	[[ -t 0 && $- == *'i'* ]] || return 0

	# shaughvOS-Globals: shaughvos-* aliases, G_* functions and variables
	. /boot/shaughvos/func/shaughvos-globals || { echo -e '[\e[31mFAILED\e[0m] shaughvOS-Login | Failed to load shaughvOS-Globals. Skipping shaughvOS login scripts...'; return 1; }

	# Aliases
	# - sudo alias that allows running other aliases with "sudo": https://github.com/RealEmmettS/shaughvOS/issues/424
	alias sudo='sudo '
	# - shaughvOS programs
	alias shaughvos-letsencrypt='/boot/shaughvos/shaughvos-letsencrypt'
	alias shaughvos-autostart='/boot/shaughvos/shaughvos-autostart'
	alias shaughvos-cron='/boot/shaughvos/shaughvos-cron'
	alias shaughvos-launcher='/boot/shaughvos/shaughvos-launcher'
	alias shaughvos-cleaner='/boot/shaughvos/shaughvos-cleaner'
	alias shaughvos-morsecode='/boot/shaughvos/shaughvos-morsecode'
	alias shaughvos-sync='/boot/shaughvos/shaughvos-sync'
	alias shaughvos-backup='/boot/shaughvos/shaughvos-backup'
	alias shaughvos-bugreport='/boot/shaughvos/shaughvos-bugreport'
	alias shaughvos-services='/boot/shaughvos/shaughvos-services'
	alias shaughvos-config='/boot/shaughvos/shaughvos-config'
	alias shaughvos-software='/boot/shaughvos/shaughvos-software'
	alias shaughvos-update='/boot/shaughvos/shaughvos-update'
	alias shaughvos-drive_manager='/boot/shaughvos/shaughvos-drive_manager'
	alias shaughvos-logclear='/boot/shaughvos/func/shaughvos-logclear'
	alias shaughvos-survey='/boot/shaughvos/shaughvos-survey'
	alias shaughvos-explorer='/boot/shaughvos/shaughvos-explorer'
	alias shaughvos-banner='/boot/shaughvos/func/shaughvos-banner'
	alias shaughvos-justboom='/boot/shaughvos/misc/shaughvos-justboom'
	alias shaughvos-led_control='/boot/shaughvos/shaughvos-led_control'
	alias shaughvos-wifidb='/boot/shaughvos/func/shaughvos-wifidb'
	alias shaughvos-optimal_mtu='/boot/shaughvos/func/shaughvos-optimal_mtu'
	alias shaughvos-cloudshell='/boot/shaughvos/shaughvos-cloudshell'
	alias shaughvos-vpn='/boot/shaughvos/shaughvos-vpn'
	alias shaughvos-ddns='/boot/shaughvos/shaughvos-ddns'
	alias shaughvos-display='/boot/shaughvos/shaughvos-display'
	alias shaughvos-benchmark='/boot/shaughvos/shaughvos-benchmark'
	alias cpu='/boot/shaughvos/shaughvos-cpuinfo'
	# - Optional shaughvOS software aliases
	[[ -d '/mnt/shaughvos_userdata/sonarr' || -d '/mnt/shaughvos_userdata/radarr' || -d '/mnt/shaughvos_userdata/lidarr' || -d '/mnt/shaughvos_userdata/prowlarr' ]] && alias shaughvos-servarr_to_ram='/boot/shaughvos/shaughvos-servarr_to_ram'
	command -v kodi > /dev/null && alias startkodi='kodi --standalone'
	[[ -f '/usr/games/opentyrian/run' ]] && alias opentyrian='/usr/games/opentyrian/run'
	[[ -f '/mnt/shaughvos_userdata/dxx-rebirth/run.sh' ]] && alias dxx-rebirth='/mnt/shaughvos_userdata/dxx-rebirth/run.sh'
	[[ -f '/var/www/nextcloud/occ' ]] && alias occ='sudo -u www-data php /var/www/nextcloud/occ' && alias ncc=occ
	# - 1337 moments ;)
	alias 1337='echo "Indeed, you are =)"'

	# "G_SHAUGHVOS-NOFITY -2 message" starts a process animation. If scripts fail to kill the animation, e.g. cancelled by user, terminal bash prompt has to do it as last resort.
	[[ $PROMPT_COMMAND == *'shaughvos-process.pid'* ]] || PROMPT_COMMAND="[[ -w '/tmp/shaughvos-process.pid' ]] && rm -f /tmp/shaughvos-process.pid &> /dev/null && echo -ne '\r\e[J'; $PROMPT_COMMAND"

	# Workaround if SSH client overrides locale with "POSIX" fallback: https://github.com/RealEmmettS/shaughvOS/issues/1540#issuecomment-367066178
	if [[ ${LC_ALL:-${LANG:-POSIX}} == 'POSIX' ]]
	then
		current_locale=$(sed -n '/^[[:blank:]]*AUTO_SETUP_LOCALE=/{s/^[^=]*=//p;q}' /boot/shaughvos.txt)
		export LC_ALL=${current_locale:=C.UTF-8} LANG=$current_locale
		unset -v current_locale
	fi

	# Workaround if SSH client sets an unsupported $TERM string: https://github.com/RealEmmettS/shaughvOS/issues/2034
	term="/${TERM::1}/$TERM"
	if [[ $SSH_TTY && ! -f /lib/terminfo$term && ! -f /usr/share/terminfo$term && ! -f ~/.terminfo$term && ! -f /etc/terminfo$term ]]
	then
		TERM_old=$TERM
		export TERM='xterm'
		[[ $TERM_old == *'256'* ]] && TERM+='-256color'

		G_WHIP_MENU_ARRAY=('0' 'Ignore for now, I will change the SSH clients terminal.')
		ncurses_term=
		if ! dpkg-query -s ncurses-term &> /dev/null
		then
			ncurses_term=' or install the "ncurses-term" APT package, which enables broader terminal support'
			G_WHIP_MENU_ARRAY+=('1' 'Install "ncurses-term" now to enable broader terminal support.')
			G_WHIP_DEFAULT_ITEM=1
		fi

		if G_PROGRAM_NAME='Unsupported SSH client terminal' G_WHIP_MENU "[WARNING] Your SSH client passed an unsupported terminal: TERM=$TERM_old
\nAs a workaround, we fooled the server by setting TERM=$TERM. This is not the cleanest solution as commands may use control sequences which are not supported by the current terminal.
\nPlease change your SSH clients terminal, respectively the passed \$TERM string$ncurses_term." && (( $G_WHIP_RETURNED_VALUE ))
		then
			if (( $UID ))
			then
				G_SUDO G_AGI ncurses-term
			else
				G_AGI ncurses-term
			fi
		fi
		unset -v TERM_old ncurses_term
	fi
	unset -v term

	# shaughvOS-Login: First run setup, autostarts and login banner
	# - Prevent call if $G_SHAUGHVOS_LOGIN has been set. E.g. when shell is called as subshell of G_EXEC or shaughvos-login itself, we don't want autostart programs to be launched.
	[[ $G_SHAUGHVOS_LOGIN ]] || /boot/shaughvos/shaughvos-login
}
