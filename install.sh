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
