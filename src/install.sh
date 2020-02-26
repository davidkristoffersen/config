#!/usr/bin/env bash

dotfiles_init() {
	pwd_org="$(pwd)"
	local cur="$(dirname "${BASH_SOURCE[0]}")"
	cd "$cur/.."
	export DOTFILES="$(pwd)"
	OK_POS="$(($(tput cols) - 4))"
	WRITE=true
	SUBMODULE=true

	printf "Install requires sudo: "
	echo
	sudo true
}

dotfiles_conf_init() {
	local _src="$DOTFILES/.dotfiles.sh"
	local _dst="$HOME/.dotfiles.sh"
	local _out=""
	read -r -d '' _out << EOF
#!/usr/bin/env bash

export DOTFILES="$DOTFILES"\n
EOF
	_out+="$(cat $_src)"
	printf "$_out" > $_dst
	. $_dst
}

dotfiles_fini() {
	cd "$pwd_org"
}

link_header() {
	printf "$RESET$FAINT"
	printf "#%.0s" $(seq 1 $((${#1} + 4)))
	printf "\n$FAINT# $RESET$BYELLOW$1$RESET $FAINT#\n"
	printf "#%.0s" $(seq 1 $((${#1} + 4)))
	printf "$RESET\n"
}

link_section() {
	printf "\n$FAINT# $RESET$BCYAN$1$RESET\n"
}

path_is_abs() {
	case $1 in
		/*) printf true ;;
		*) printf false ;;
	esac
}

path_set_pre() {
	if $(path_is_abs "$1"); then
		printf "$1"
	else
		printf "$2/$1"
	fi
}

link_need_sudo() {
	if $(path_is_abs $1) && ! [[ "$1" == $HOME* ]]; then
		printf true
	else
		printf false
	fi
}

create_path() {
	local _sudo=""
	if $(link_need_sudo $1); then
		_sudo="sudo "
	fi
	printf "\t${_sudo}mkdir -p \"$1\"\n"; check_error $?
	test $WRITE && $_sudo mkdir -p "$1"; check_error $?
}

rm_file() {
	local _sudo=""
	if $(link_need_sudo $1); then
		_sudo="sudo "
	fi
	printf "\t${_sudo}rm -f \"$1\"\n"; check_error $?
	test $WRITE && $_sudo rm -f "$1"; check_error $?
}

_link_file() {
	local _sudo=""
	if $(link_need_sudo $1) || $(link_need_sudo $2); then
		_sudo="sudo "
	fi
	printf "\t${_sudo}ln -s \"$1\" \"$2\"\n"; check_error $?
	test $WRITE && $_sudo ln -s "$1" "$2"; check_error $?
}

link_file() {
	[ ${#@} == 3 ] && true; check_error $? nargs
	local name="$(basename $1)"
	local src="$(path_set_pre $1 $DOTFILES)"
	local dst="$(path_set_pre $2 $HOME)"
	local desc="$3"
	local desc_long="Replacing $3: "
	local desc_len="${#desc_long}"
	local desc_long="${BLUE}$desc_long${RESET}\n"
	local dirs="$(dirname "$dst")"
	local srcs="$(dirname "$src")"

	printf "$desc_long"

	create_path "$dirs"
	create_path "$srcs"
	rm_file "$dst"
	_link_file "$src" "$dst"

	print_at 5 $desc_len "${GREEN}OK${RESET}"
}

# Shell dotfiles
link_shell() {
	local -a profile_arr=(
		.bash_profile
		.profile
		.profile.d
	)
	local -a bash_arr=(
		.bashrc
		.bash.d
		.bash_completion.d
		.bash_logout
	)

	link_section "Profile"
	for profile_arr in ${profile_arr[@]}; do
		link_file $DOTFILES_SHELL/$profile_arr $profile_arr "$profile_arr"
	done

	link_section "Bash"
	for bash_arr in ${bash_arr[@]}; do
		link_file $DOTFILES_SHELL/$bash_arr $bash_arr "$bash_arr"
	done

	. $DOTFILES_SHELL/.profile; check_error $?
	. $DOTFILES_SHELL/.bashrc; check_error $?
}

# $HOME dotfiles
link_home() {
	link_section "Git"
	# Config
	link_file $DOTFILES_HOME/.gitconfig .gitconfig ".gitconfig"

	link_section "Session management"
	# I3
	link_file $DOTFILES_CONFIG/i3/i3.config .config/i3/config "i3 config - Window manager"
	# Rofi
	link_file $DOTFILES_CONFIG/rofi/rofi.rasi .config/rofi/config.rasi "rofi config - Application launcher"
	# Terminator
	link_file $DOTFILES_CONFIG/terminator/terminator.ini .config/terminator/config "terminator config - Terminal emulator"
	# Tmux
	link_file $DOTFILES_HOME/.tmux.conf .tmux.conf ".tmux.conf - Terminal multiplexer"
	# Dunst
	link_file $DOTFILES_CONFIG/dunst/dunst.cfg .config/dunst/dunstrc "Dunst config - Notification manager"
	# LightDM
	link_file $DOTFILES_ETC/lightdm.conf /etc/lightdm.conf "light config - Display manager"

	link_section "CLI configuration"
	# Readline
	link_file $DOTFILES_HOME/.inputrc .inputrc "readline config"
	# Xresources
	link_file $DOTFILES_HOME/.Xresources .Xresources "Xresources config"
	# xinit
	link_file $DOTFILES_HOME/.xinitrc .xinitrc "xinit config"
	# LS_COLOR
	link_file $DOTFILES_HOME/.dir_colors .dir_colors "LS_COLOR config"
	# EXA_COLOR
	link_file $DOTFILES_CONFIG/exa/.dir_colors .config/exa/.exa_colors "EXA_COLOR config"
	link_file $DOTFILES_CONFIG/exa/.dir_colors_extra .config/exa/.exa_colors_extra "EXA_COLOR extra config"

	link_section "Editor"
	# Vimrc files
	link_file $DOTFILES_HOME/.vim .vim "vim dir config"
	link_file $DOTFILES_HOME/.vim/.vimrc .vimrc "vim config"
	# Latex
	link_file $DOTFILES_CONFIG/latex/template.latex .config/latex/template.latex "Latex template"

	link_section "CLI programs"
	# SQLite
	link_file $DOTFILES_HOME/.sqliterc.sql .sqliterc "SQLite config"
	# Htop
	link_file $DOTFILES_CONFIG/htop/htoprc .config/htop/htoprc "htop config"

	link_section "GUI programs"
	# GIMP
	link_file $DOTFILES_HOME/.gimp-2.0/gimprc .gimp-2.0/gimprc "GIMP config"
	# Gitk
	link_file $DOTFILES_CONFIG/git/gitk .config/git/gitk "gitk config"
}

update_submodules() {
	echo
	$SUBMODULE || return
	git submodulepull; check_error $?
}

link_bin() {
	echo

	cd $DOTFILES_BIN
	local _scripts="$(ls -dA1 **)"
	cd - >/dev/null

	for script in $_scripts; do
		if [ -f $DOTFILES_BIN/$script ]; then
			link_file "$DOTFILES_BIN/$script" "$XDG_BIN_HOME/$(basename $script)" "$script"
		fi
	done
}

link_lib() {
	echo

	# Bash library
	link_file "$DOTFILES_LIB/bash" "$XDG_LIB_HOME/bash" "bash script library"
}

link_share() {
	echo

	# Bash metadata
	link_file "$DOTFILES_SHARE/bash-metadata" "$XDG_DATA_HOME/bash-metadata" "bash metadata"

	# Backgrounds
	link_file "$DOTFILES_SHARE/backgrounds" "$XDG_DATA_HOME/backgrounds" "backgrounds"

	# Rofi themes
	link_file "$DOTFILES_SHARE/rofi" "$XDG_DATA_HOME/rofi" "rofi themes"
}

main() {
	dotfiles_init
	dotfiles_conf_init

	link_header "Shell dotfiles"
	link_shell
	echo
	link_header "\$HOME dotfiles"
	link_home
	echo
	link_header "Update submodules"
	update_submodules
	echo
	link_header "Shell scripts"
	link_bin
	echo
	link_header "Shell libraries"
	link_lib
	echo
	link_header "Shell shared data"
	link_share

	dotfiles_fini
}
main