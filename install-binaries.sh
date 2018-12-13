#!/bin/bash

#################################
####### Utility Functions

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

NUMTHREADS=8

while (( "$#" )); do
	if [[ "$1" == "--reinstall" ]]; then
		REINSTALL="TRUE"
		echo -e "${GOODCOLOR}Performing a reinstallation of everything in the bin folder${ENDGOODCOLOR}"
	elif [[ "$1" =~ ^-j[0-9][0-9]*$ ]]; then
		NUMTHREADS="$(echo "$1" | sed -e 's|^-j||g')"
		echo -e "${GOODCOLOR}Changing number of compile threads to $NUMTHREADS${ENDGOODCOLOR}"
	else
		echo -e "${BADCOLOR}Command line argument '$1' not understood. Valid arguments are -j<number of threads>, and --reinstall${ENDBADCOLOR}"
		exit 1
	fi

	shift
done

#################################
####### Initial Setup

# Figure out the value of CONFIG_SCRIPTS_DIR if it isn't set by determining the folder this script is in
if [[ "$CONFIG_SCRIPTS_DIR " == " " ]]; then
	export CONFIG_SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
fi

# Make the bin folder and move to it
mkdir -p "$CONFIG_SCRIPTS_DIR/bin"
cd "$CONFIG_SCRIPTS_DIR/bin"


###############################################################################
############################# Cscope
#
# CentOS/Fedora:
#   yum install ncurses-devel
#
if [[ ! -d cscope-compile ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Cscope"
	RUN rm -f cscope-15.8b.tar.gz
	RUN rm -rf cscope-15.8b
	RUN rm -rf cscope-compile
	RUN wget 'https://downloads.sourceforge.net/project/cscope/cscope/15.8b/cscope-15.8b.tar.gz'
	RUN tar xzf cscope-15.8b.tar.gz
	RUN pushd cscope-15.8b
	RUN ./configure --prefix="$CONFIG_SCRIPTS_DIR/bin/cscope-compile"
	RUN make "-j$NUMTHREADS"
	RUN make install
	RUN popd
	RUN rm -f cscope-15.8b.tar.gz
	RUN rm -rf cscope-15.8b
fi

export PATH="$CONFIG_SCRIPTS_DIR/bin/cscope-compile/bin:$PATH"


###############################################################################
############################# Vim
#
# http://vim.wikia.com/wiki/Building_Vim
#
# For Ubuntu:
# apt-get install libncurses5-dev libatk1.0-dev
#
if [[ ! -d vim-compile ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Vim"
	RUN rm -rf vim-src
	RUN rm -rf vim-compile
	RUN git clone 'https://github.com/vim/vim.git' vim-src
	RUN pushd vim-src
	RUN make distclean
	RUN ./configure \
		--with-features=huge \
		--enable-pythoninterp \
		--with-compiledby='Byron Marohn <byron.marohn@intel.com>' \
		--prefix="$CONFIG_SCRIPTS_DIR/bin/vim-compile"

	#    --enable-python3interp

	RUN make "-j$NUMTHREADS"
	RUN make install
	RUN popd
	RUN rm -rf vim-src
fi

export PATH="$CONFIG_SCRIPTS_DIR/bin/vim-compile/bin:$PATH"

###############################################################################
############################# Vim Dein (NeoBundle / Vundle replacement)
if [[ ! -d "$CONFIG_SCRIPTS_DIR/bin/repos/github.com/Shougo/dein.vim" ]] || [[ "$REINSTALL " == "TRUE " ]]; then

	PRINTSTART "Vim Neobundle"
	rm -rf "$CONFIG_SCRIPTS_DIR/scripts/vim/bundle/dein.vim"
	RUN git clone 'https://github.com/Shougo/dein.vim' "$CONFIG_SCRIPTS_DIR/scripts/vim/bundle/dein.vim"
	vim +'call dein#install()'
fi

###############################################################################
############################# Artistic Style (astyle)
#
# CentOS/Fedora:
#    yum install gcc-c++
#
if [[ ! -e "astyle" ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Artistic Style (astyle)"
	RUN rm -f astyle_2.05.1_linux.tar.gz
	RUN rm -f astyle
	RUN rm -rf astyle_src
	RUN wget 'https://downloads.sourceforge.net/project/astyle/astyle/astyle%202.05.1/astyle_2.05.1_linux.tar.gz'
	RUN mkdir astyle_src
	RUN pushd astyle_src
	RUN tar xzf ../astyle_2.05.1_linux.tar.gz
	RUN cd astyle/build/gcc
	RUN make "-j$NUMTHREADS"
	RUN mv bin/astyle "$CONFIG_SCRIPTS_DIR/bin"
	RUN popd
	RUN rm -f astyle_2.05.1_linux.tar.gz
	RUN rm -rf astyle_src
fi

###############################################################################
############################# Rebuild VIM help tags
RUN cd "$CONFIG_SCRIPTS_DIR/scripts/vim/doc/"
RUN rm -f 'tags'
RUN vim '+helptags .' '+qall' &>/dev/null



echo -e "${GOODCOLOR}Install complete!${ENDGOODCOLOR}"

