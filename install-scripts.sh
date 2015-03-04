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

# Create links for config scripts to default locations
make_link "$HOME/.commonrc" "scripts/commonrc"
make_link "$HOME/.zshrc" "scripts/zshrc"
make_link "$HOME/.vimrc" "scripts/vimrc"
make_link "$HOME/.vim" "scripts/vim"
make_link "$HOME/.gdbinit" "scripts/gdbinit"


# Check gitconfig
if [[ ! -e "$HOME/.gitconfig" ]]; then
	# Only way this has any effect is if .gitconfig is a broken symlink
	rm -f "$HOME/.gitconfig"
fi
git config --global user.name > /dev/null
if [[ $? -ne 0 ]]; then
	echo "Git user.name not found! Enter your user.name to be placed in $HOME/.gitconfig"
	echo -n "> "
	read username;
	git config --global user.name "$username"
fi
git config --global user.email > /dev/null
if [[ $? -ne 0 ]]; then
	echo "Git user.email not found! Enter your user.email to be placed in $HOME/.gitconfig"
	echo -n "> "
	read useremail;
	git config --global user.email "$useremail"
fi
if ! cat "$HOME/.gitconfig" | grep -q "path = $SCRIPT_DIR/scripts/gitconfig"; then
	cat <<EOF >> "$HOME/.gitconfig"

[include]
	path = $SCRIPT_DIR/scripts/gitconfig

EOF
fi


# Check login shell
if ! getent passwd | grep "^$USER" | grep -q 'zsh' ; then
	echo "Warning! Login shell is not ZSH. You must manually add this text to your $HOME/.bashrc (or similar)"
	echo '    source "$HOME/.commonrc"'
fi

