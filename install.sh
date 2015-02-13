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
		rm -f "$link"
	fi

	ln -s "$SCRIPT_DIR/$target" "$link"
	echo "Link created for $link -> $SCRIPT_DIR/$target"
)

make_link ~/.zshrc "scripts/.zshrc"
make_link ~/.vimrc "scripts/.vimrc"
make_link ~/.vim "scripts/.vim"
make_link ~/.gitconfig "scripts/.gitconfig"
