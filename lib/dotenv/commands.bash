#!/usr/bin/env bash
#
#   __          __
#  /\ \        /\ \__
#  \_\ \    ___\ \ ,_\    __    ___   __  __
#  /'_` \  / __`\ \ \/  /'__`\/' _ `\/\ \/\ \
# /\ \L\ \/\ \L\ \ \ \_/\  __//\ \/\ \ \ \_/ |
# \ \___,_\ \____/\ \__\ \____\ \_\ \_\ \___/
#  \/__,_ /\/___/  \/__/\/____/\/_/\/_/\/__/
#
# -----------------------------------------------------------------------------

BASE=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

# === API =====================================================================
# Loads the dotenv API functions

source "$BASE/api.bash"

function command-dotenv {
# Lists the available profiles
# -l --list PROFILE

	if [ -z "$DOTENV_PROFILES" ]; then
		dotenv_fail "Environment variable DOTENV_PROFILES not defined"
	fi

	while [ "$#" -gt 0 ]
	do
		case "$1" in
		-h|--help)
			echo "Usage: dotenv [OPTION] PROFILE|FILE…"
			echo "Manages multiple dotfile configurations"
			echo 
			echo "PROFILE"
			echo " PROFILE               Activates the given profile"
			echo " -p, --profile         List available profiles"
			echo " -p, --profile PROFILE Activates/creates the given profile"
			echo " -c, --configure       Configure the active profile"
			echo " -t, --templates       Configure the active profile templates"
			echo " -R, --revert-profile  Reverts the profile"
			echo 
			echo " FILE…"
			echo " -a, --add             Adds the given files to the active profile"
			echo " -u, --update          Updates all/given files based on the active profile"
			echo " -r, --revert          Reverts all/given files that were previously managed"
			echo " -e, --edit            Edits the given managed files(s)"
			echo " -l, --list            Lists all the managed files"
			echo " -l, --list FILE…      Outputs the contents of the managed file(s)"

			;;
		# =====================================================================
		# API
		# =====================================================================
		--api)
			shift
			eval "$@"
			exit 0
			;;
		# =====================================================================
		# PROFILES
		# =====================================================================
		-p|--profile|--profiles)
			if [ -z "$2" ]; then
				dotenv_profile_list
			elif [ "$2" == "none" ]; then
				dotenv_profile_revert
			else
				dotenv_profile_create "$2"
			fi
			exit 0
			;;
		-R|--revert-profile)
			dotenv_profile_revert
			exit 0
			;;
		-c|--config|--configure)
			dotenv_profile_config_edit "$1"
			exit 0
			;;
		-t|--templates)
			dotenv_profile_templates_edit "$1"
			exit 0
			;;
		# =====================================================================
		# MANAGED FILES
		# =====================================================================
		-a|--add)
			shift
			dotenv_managed_add "$*"
			exit 0
			;;
		-r|--revert)
			shift
			dotenv_managed_remove "$*"
			exit 0
			;;
		-u|--update)
			shift
			dotenv_managed_install "$*"
			exit 0
			;;
		-l|--list)
			shift
			if [ -z "$*" ]; then
				if [ -d "$DOTENV_MANAGED" ]; then
					dotenv_managed_list | column -ts→ | sed "s|$HOME|~|g"
					exit 0
				elif [ ! -d "$DOTENV_PROFILES" ]; then
					dotenv_info "No profile defined in $DOTENV_PROFILES"
					dotenv_info "Use \`dotenv --create PROFILE\` to create a profile with the given name"
				elif [ ! -d "$DOTENV_ACTIVE" ]; then
					dotenv_info "No active profile, run dotenv with one of:"
					dotenv_list "$(dotenv_profile_list)"
				else
					dotenv_info "No managed files in profile $(dotenv_profile_active), add files with: dotenv -a FILES…"
					exit 0
				fi
			else
				dotenv_managed_make "$@"
				dotenv_managed_cat "$@"
			fi
			;;

		-*)
			dotenv_fail "Invalid option '$1'. Use --help to see the valid options" >&2
			;;
		*)
			if [ ! -e "$DOTENV_PROFILES/$1" ]; then
				dotenv_info "Creating profile $1"
				mkdir -p "$DOTENV_PROFILES/$1"
			fi
			dotenv_profile_apply "$1"
			exit 0
			;;
		esac
		shift
	done
	# TODO: Default should:
	# 1) Show the active profile
	# 2) Show the managed files
}

# EOF - vim: ts=4 sw=4 noet 
