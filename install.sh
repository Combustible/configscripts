#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

make_link() (
	link="$1"
	target="$2"

	if [[ -e "$link" ]]; then
		if [[ ! -L "$link" ]]; then
			echo "Error: $link exists and is not a symlink"
			echo "  Please rename/backup this file and re-run this script"
			return 1
		fi

		if [[ " $SCRIPT_DIR/$target" != " $(readlink "$link")" ]]; then
			# Link points to the wrong place, warn the user
			echo "Warning: $link exists but is a symlink"
			echo "Replacing it with a link to $target"
		fi
	fi

	# Remove the link, even if it doesn't exist (in case it is a broken link)
	rm -f "$link"
	ln -s "$SCRIPT_DIR/$target" "$link"
	echo "Link created for $link -> $SCRIPT_DIR/$target"
)

if [[ "$1 " == "work " ]] || [[ "$1 " == "personal " ]]; then
	TYPE="$1"
fi

if [[ $# -ne 1 || "$TYPE " == " " ]]; then
	echo "Usage: $0 [work|personal]"
	exit 1
fi


make_link ~/.zshrc "scripts/.zshrc"
make_link ~/.vimrc "scripts/.vimrc"
make_link ~/.vim "scripts/.vim"
make_link ~/.gitconfig "scripts/${TYPE}/.gitconfig"

if ! getent passwd | grep "^$USER" | grep -q zsh ; then
	echo "Warning! Login shell is not ZSH. You must manually add this text to your ~/.bashrc (or similar)"
	cat <<EOF

export CONFIG_SCRIPTS_DIR="$(readlink -f "$(dirname "$(readlink -f "$HOME/.zshrc")")/..")"

export PATH="$CONFIG_SCRIPTS_DIR/bin/git-compile/bin:$PATH"
export PATH="$CONFIG_SCRIPTS_DIR/bin/python2/bin:$PATH"
export PATH="$CONFIG_SCRIPTS_DIR/bin/python3/bin:$PATH"
export PATH="$CONFIG_SCRIPTS_DIR/bin/vim-compile/bin:$PATH"
export PATH="$CONFIG_SCRIPTS_DIR/bin/gdb-compile/bin:$PATH"
export PATH="$CONFIG_SCRIPTS_DIR/bin:$PATH"
export PATH="$HOME/bin:$PATH"
if [[ "$LD_LIBRARY_PATH " == " " ]]; then
    export LD_LIBRARY_PATH="$CONFIG_SCRIPTS_DIR/bin/python2/lib"
else
    export LD_LIBRARY_PATH="$CONFIG_SCRIPTS_DIR/bin/python2/lib:$LD_LIBRARY_PATH"
fi

# No more awful control-s freeze
stty ixany
stty ixoff -ixon

EOF
fi

echo "Make sure you also replace my name with yours in your ~/.gitconfig file!"


