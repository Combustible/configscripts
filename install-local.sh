#!/bin/bash

#################################
####### Utility Functions

# Figure out the value of CONFIG_SCRIPTS_DIR if it isn't set by determining the folder this script is in
if [[ "$CONFIG_SCRIPTS_DIR " == " " ]]; then
	export CONFIG_SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
fi

if [[ -t 1 ]]; then
	GOODCOLOR='\e[0;32m' # Green, bold
	ENDGOODCOLOR='\e[0m' # Have to use at end of color
else
	GOODCOLOR=''
	ENDGOODCOLOR=''
fi
if [[ -t 2 ]]; then
	BADCOLOR='\e[0;31m' # Red, bold
	ENDBADCOLOR='\e[0m' # Have to use at end of color
else
	BADCOLOR=''
	ENDBADCOLOR=''
fi

RUN() {
	echo -e "${GOODCOLOR}Running: ${@}${ENDGOODCOLOR}"
	"$@"
	RETVAL=$?
	if [[ $RETVAL -ne 0 ]]; then
		echo -e "${BADCOLOR}ERROR: execution of command $@ returned ${RETVAL}${ENDBADCOLOR}" >&2
		exit $RETVAL
	fi
}

PRINTSTART() (
	PACKAGE="$1"

	echo -e "${GOODCOLOR}###############################################################################${ENDGOODCOLOR}"
	echo -e "${GOODCOLOR}############################# Installing ${PACKAGE}${ENDGOODCOLOR}"
	echo -e
)

make_link() (
	link="$1"
	target="$2"

	if [[ -e "$link" ]]; then
		if [[ ! -L "$link" ]]; then
			echo "Error: $link exists and is not a symlink"
			echo "  Please rename/backup this file and re-run this script"
			return 1
		fi

		if [[ " $CONFIG_SCRIPTS_DIR/$target" != " $(readlink "$link")" ]]; then
			# Link points to the wrong place, warn the user
			echo "Warning: $link exists but is a symlink"
			echo "Replacing it with a link to $target"
		fi
	fi

	# Remove the link, even if it does not exist (in case it is a broken link)
	rm -f "$link"
	ln -s "$CONFIG_SCRIPTS_DIR/$target" "$link"
	echo "Link created for $link -> $CONFIG_SCRIPTS_DIR/$target"
)

NUMTHREADS=8

while (( "$#" )); do
	if [[ "$1" == "--reinstall" ]]; then
		REINSTALL="TRUE"
		echo -e "${GOODCOLOR}Performing a reinstallation of everything in the bin folder${ENDGOODCOLOR}"
	elif [[ "$1" =~ ^-j[0-9][0-9]*$ ]]; then
		NUMTHREADS="$(echo "$1" | sed -e 's|^-j||g')"
		echo -e "${GOODCOLOR}Changing number of compile threads to $NUMTHREADS${ENDGOODCOLOR}"
	else
		echo -e "${BADCOLOR}Command line argument '$1' not understood. Valid arguments are -j<number of threads>, --reinstall, and --use-system-python${ENDBADCOLOR}"
		exit 1
	fi

	shift
done


#################################
####### Initial Setup

# Make the bin folder and move to it
mkdir -p "$CONFIG_SCRIPTS_DIR/bin"
cd "$CONFIG_SCRIPTS_DIR/bin"

make_link "$HOME/.vim" "scripts/vim"
touch "$HOME/.vimrc"

###############################################################################
############################# Vim

if [[ ! -d vim-compile ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Vim"
	RUN rm -rf vim-src
	RUN rm -rf vim-compile
	RUN git clone 'https://github.com/vim/vim.git' vim-src
	RUN pushd vim-src
	RUN make distclean
	RUN ./configure \
		--with-features=huge \
		--enable-python3interp \
		--enable-luainterp \
		--with-compiledby='Byron Marohn <combustible@live.com>' \
		--prefix="$CONFIG_SCRIPTS_DIR/bin/vim-compile"

	RUN make "-j$NUMTHREADS"
	RUN make install
	RUN popd
	RUN rm -rf vim-src
fi

export PATH="$CONFIG_SCRIPTS_DIR/bin/vim-compile/bin:$PATH"

###############################################################################
############################# Vim Plugins

if [[ ! -d $HOME/.vim/bundle/dein.vim ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Vim Plugins"
	RUN rm -rf "$HOME/.vim/bundle/dein.vim"
	RUN git clone 'https://github.com/Shougo/dein.vim' "$HOME/.vim/bundle/dein.vim"
	RUN vim-compile/bin/vim -N -u ../scripts/vimrc -c "try | call dein#update() | finally | qall! | endtry" -V1 -es
fi

export PATH="$CONFIG_SCRIPTS_DIR/bin/vim-compile/bin:$PATH"

###############################################################################
############################# gitconfig

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
if ! cat "$HOME/.gitconfig" | grep -q "path = $CONFIG_SCRIPTS_DIR/scripts/gitconfig"; then
	cat <<EOF >> "$HOME/.gitconfig"

[include]
	path = $CONFIG_SCRIPTS_DIR/scripts/gitconfig

[core]
	excludesfile = $CONFIG_SCRIPTS_DIR/scripts/gitignore_global
EOF
fi
