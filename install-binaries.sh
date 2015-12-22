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

# Runs command with sudo if USESYSTEMPYTHON = 1
SPRUN() {
	echo -e "${GOODCOLOR}Running: ${@}${ENDGOODCOLOR}"
	if [[ $USESYSTEMPYTHON -eq 1 ]]; then
		sudo "$@"
	else
		"$@"
	fi
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
USESYSTEMPYTHON=0

while (( "$#" )); do
	if [[ "$1" == "--reinstall" ]]; then
		REINSTALL="TRUE"
		echo -e "${GOODCOLOR}Performing a reinstallation of everything in the bin folder${ENDGOODCOLOR}"
	elif [[ "$1" == "--use-system-python" ]]; then
		USESYSTEMPYTHON=1
		echo -e "${GOODCOLOR}Using system-installed python2${ENDGOODCOLOR}"
	elif [[ "$1" =~ ^-j[0-9][0-9]*$ ]]; then
		NUMTHREADS="$(echo "$1" | sed -e 's|^-j||g')"
		echo -e "${GOODCOLOR}Changing number of compile threads to $NUMTHREADS${ENDGOODCOLOR}"
	else
		echo -e "${BADCOLOR}Command line argument '$1' not understood. Valid arguments are -j<number of threads>, --reinstall, and --use-system-python${ENDBADCOLOR}"
		exit 1
	fi

	shift
done

# Check if using the system python will probably work
if [[ $USESYSTEMPYTHON -eq 0 ]]; then
	if which python &> /dev/null ; then
		if python -c 'import sys; sys.exit(not ((sys.version_info >= (2,6)) and (sys.version_info < (3,0))))' ; then
			echo -e "${GOODCOLOR}Looks like the current version of Python 2 is greater than 2.6 and will probably work.${ENDGOODCOLOR}"
			echo -e "${GOODCOLOR}Should system python be used? This is a good idea, but requires root access.${ENDGOODCOLOR}"
			echo -en "${GOODCOLOR}[Y/n]> ${ENDGOODCOLOR}"
			read line
			if [[ "$line" == "" ]] || [[ "$line" == "y" ]] || [[ "$line" == "Y" ]] || [[ "$line" == "yes" ]] || [[ "$line" == "YES" ]]; then
				echo -e "${GOODCOLOR}Using system python installation. Will attempt to use sudo as needed to install modules.${ENDGOODCOLOR}"
				USESYSTEMPYTHON=1
			else
				echo -e "${GOODCOLOR}Not using system python. Will compile python from source for this user ($USER)${ENDGOODCOLOR}"
			fi
			sleep 2
		fi
	fi
fi

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
############################# Git
#
# http://git-scm.com/book/en/v2/Getting-Started-Installing-Git
#
# CentOS/Fedora:
#   yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc xmlto docbook2X autoconf gcc perl-devel
#   ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi
#
# On CentOS, if all packages are not available, EPEL might have to be installed before trying again
#   yum install epel-release
#
# Debian/Ubuntu:
#   apt-get install libcurl4-openssl-dev libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev asciidoc xmlto docbook2x autoconf
#
# Get source URL from here: https://www.kernel.org/pub/software/scm/git/
#
if [[ ! -d git-compile ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Git"
	RUN rm -f git-2.3.0.tar.gz
	RUN rm -rf git-2.3.0
	RUN rm -rf git-compile
	RUN wget 'https://www.kernel.org/pub/software/scm/git/git-2.3.0.tar.gz'
	RUN tar xzf git-2.3.0.tar.gz
	RUN pushd git-2.3.0
	RUN make configure
	RUN ./configure --prefix="$CONFIG_SCRIPTS_DIR/bin/git-compile"
	RUN make all "-j$NUMTHREADS"
	RUN make doc "-j$NUMTHREADS"
	RUN make info "-j$NUMTHREADS"
	RUN make install install-doc install-html install-info
	RUN popd
	RUN rm -f git-2.3.0.tar.gz
	RUN rm -rf git-2.3.0
fi

export PATH="$CONFIG_SCRIPTS_DIR/bin/git-compile/bin:$PATH"


###############################################################################
############################# Python2
# Note: python-devel is only required if using system python
#
# CentOS/Fedora:
#   yum install python-devel
#
# Ubuntu:
#   apt-get install python-dev
#
#
if [[ $USESYSTEMPYTHON -eq 0 ]]; then
	if [[ ! -d python2 ]] || [[ "$REINSTALL " == "TRUE " ]]; then
		PRINTSTART "Python2"
		RUN rm -f Python-2.7.9.tgz
		RUN rm -rf Python-2.7.9
		RUN rm -rf python2
		RUN wget 'https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz'
		RUN tar xzf Python-2.7.9.tgz
		RUN pushd Python-2.7.9
		RUN ./configure --prefix="$CONFIG_SCRIPTS_DIR/bin/python2" --enable-shared
		RUN make "-j$NUMTHREADS"
		RUN make install
		RUN popd
		RUN rm -f Python-2.7.9.tgz
		RUN rm -rf Python-2.7.9
	fi

	export PATH="$CONFIG_SCRIPTS_DIR/bin/python2/bin:$PATH"
	export LD_LIBRARY_PATH="$CONFIG_SCRIPTS_DIR/bin/python2/lib:$LD_LIBRARY_PATH"
elif [[ -d python2 ]]; then
	# If we were not using system python before, remove the previously built python2 binaries
	RUN rm -rf python2
fi


###############################################################################
############################# Cscope
#
# CentOS/Fedora:
#   yum install ncurses-devel
#
if [[ ! -d cscope-compile ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Cscope"
	RUN rm -f cscope-15.8a.tar.gz
	RUN rm -rf cscope-15.8a
	RUN rm -rf cscope-compile
	RUN wget 'http://downloads.sourceforge.net/project/cscope/cscope/15.8a/cscope-15.8a.tar.gz'
	RUN tar xzf cscope-15.8a.tar.gz
	RUN pushd cscope-15.8a
	RUN ./configure --prefix="$CONFIG_SCRIPTS_DIR/bin/cscope-compile"
	RUN make "-j$NUMTHREADS"
	RUN make install
	RUN popd
	RUN rm -f cscope-15.8a.tar.gz
	RUN rm -rf cscope-15.8a
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
	RUN git clone 'https://github.com/b4winckler/vim.git' vim-src
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
############################# Python2 pdb-clone
#
# https://pypi.python.org/pypi/pdb-clone
#
if ! python -c 'import pdb' 2>/dev/null || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 pdb-clone"
	RUN rm -f pdb-clone-1.10.tar.gz
	SPRUN rm -rf pdb-clone-1.10
	RUN wget 'https://pypi.python.org/packages/source/p/pdb-clone/pdb-clone-1.10.tar.gz'
	RUN tar xzf pdb-clone-1.10.tar.gz
	RUN pushd pdb-clone-1.10
	SPRUN python setup.py install
	RUN popd
	RUN rm -f pdb-clone-1.10.tar.gz
	SPRUN rm -rf pdb-clone-1.10
fi


###############################################################################
############################# Python2 trollius
if ! python -c 'import trollius' 2>/dev/null || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 trollius"
	RUN rm -f trollius-1.0.4.tar.gz
	SPRUN rm -rf trollius-1.0.4
	RUN wget 'https://pypi.python.org/packages/source/t/trollius/trollius-1.0.4.tar.gz#md5=3631a464d49d0cbfd30ab2918ef2b783'
	RUN tar xzf trollius-1.0.4.tar.gz
	RUN pushd trollius-1.0.4
	SPRUN python setup.py install
	RUN popd
	RUN rm -f trollius-1.0.4.tar.gz
	SPRUN rm -rf trollius-1.0.4
fi


###############################################################################
############################# Python2 pyclewn
#
# http://pyclewn.sourceforge.net/install.html
# https://pypi.python.org/pypi/pyclewn
#
if ! python -c 'import clewn' 2>/dev/null || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 pyclewn"
	RUN rm -f pyclewn-*.tar.gz
	SPRUN rm -rf pyclewn-*
	RUN wget 'https://pypi.python.org/packages/source/p/pyclewn/pyclewn-2.2.tar.gz'
	RUN tar xzf pyclewn-2.2.tar.gz
	RUN pushd pyclewn-2.2
	SPRUN python setup.py install
	RUN popd
	RUN rm -f pyclewn-2.2.tar.gz
	SPRUN rm -rf pyclewn-2.2

	# Test if pyclewn installation was successful
	RUN python -c "import clewn;"

	# Install the pyclewn vimball
	RUN pushd /tmp
	PYCLEWN_VIMBALL="$(python -c "import clewn; clewn.get_vimball()" | cut -d ' ' -f '3-')"
	RUN test -e "$PYCLEWN_VIMBALL"
	RUN vim -S "$PYCLEWN_VIMBALL" +qall
	RUN popd
fi


###############################################################################
############################# Python2 pyserial
#
if ! python -c 'import serial' 2>/dev/null || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 pyserial"
	RUN rm -f pyserial-2.7.tar.gz
	SPRUN rm -rf pyserial-2.7
	RUN wget 'https://pypi.python.org/packages/source/p/pyserial/pyserial-2.7.tar.gz#md5=794506184df83ef2290de0d18803dd11'
	RUN tar xzf pyserial-2.7.tar.gz
	RUN pushd pyserial-2.7
	SPRUN python setup.py install
	RUN popd
	RUN rm -f pyserial-2.7.tar.gz
	SPRUN rm -rf pyserial-2.7
fi


###############################################################################
############################# GDB
#
if [[ ! -d gdb-compile ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "GDB"

	export LDFLAGS="-Wl,-rpath,$CONFIG_SCRIPTS_DIR/bin/python2/lib -L$CONFIG_SCRIPTS_DIR/bin/python2/lib"

	RUN rm -f gdb-7.8.2.tar.gz
	RUN rm -rf gdb-7.8.2
	RUN rm -rf gdb-compile
	RUN wget 'http://ftp.gnu.org/gnu/gdb/gdb-7.8.2.tar.gz'
	RUN tar xzf gdb-7.8.2.tar.gz
	RUN pushd gdb-7.8.2
	RUN ./configure --with-python --prefix="$CONFIG_SCRIPTS_DIR/bin/gdb-compile"
	RUN make "-j$NUMTHREADS"
	RUN make install
	RUN popd
	RUN rm -f gdb-7.8.2.tar.gz
	RUN rm -rf gdb-7.8.2
fi

export PATH="$CONFIG_SCRIPTS_DIR/bin/gdb-compile/bin:$PATH"


###############################################################################
############################# Vim Neobundle
if [[ ! -d "$HOME/.vim/bundle/neobundle.vim" ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Vim Neobundle"
	rm -rf "$HOME/.vim/bundle/neobundle.vim"
	RUN git clone 'https://github.com/Shougo/neobundle.vim.git' "$HOME/.vim/bundle/neobundle.vim"
fi


###############################################################################
############################# Vim YouCompleteMe
#
# On ubuntu:
#   apt-get install cmake ctags g++
#
# On CentOS6:
#   yum install clang cmake libstdc++-static ctags
#   pushd /usr/lib64
#   ln -s libedit.so.0 libedit.so.2
#   popd
#
if [[ ! -e "$HOME/.vim/bundle/YouCompleteMe/third_party/ycmd/ycm_core.so" ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Vim YouCompleteMe"
	RUN pushd "$HOME/.vim/bundle"
	RUN	rm -rf YouCompleteMe
	RUN git clone 'https://github.com/Valloric/YouCompleteMe.git'
	RUN cd YouCompleteMe
	RUN git submodule update --init --recursive

	if [[ $USESYSTEMPYTHON -eq 0 ]]; then
		export CMAKE_INCLUDE_PATH="$CONFIG_SCRIPTS_DIR/bin/python2/include"
		export EXTRA_CMAKE_ARGS="-DPYTHON_INCLUDE_DIR=$CONFIG_SCRIPTS_DIR/bin/python2/include/python2.7/ -DPYTHON_LIBRARY=$CONFIG_SCRIPTS_DIR/bin/python2/lib/libpython2.7.so -DPYTHON_EXECUTABLE=$CONFIG_SCRIPTS_DIR/bin/python2/bin/python"
	fi

	if [[ "$(ldd --version | grep 'ldd' | sed -e 's|^[^0-9]*||g')" == "2.12" ]]; then
		RUN ./install.sh --clang-completer --system-libclang
	else
		RUN ./install.sh --clang-completer
	fi
	RUN popd
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
	RUN wget 'http://downloads.sourceforge.net/project/astyle/astyle/astyle%202.05.1/astyle_2.05.1_linux.tar.gz'
	RUN mkdir astyle_src
	RUN pushd astyle_src
	RUN tar xzf ../astyle_2.05.1_linux.tar.gz
	RUN cd astyle/build/gcc
	RUN make
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

##############################################################################
#----- The following junk still lives here in case I ever need it again ------
##############################################################################

# yum install glibc-devel.i686
#tar xzf gcc-4.6.2.tar.gz
#pushd gcc-4.6.2
#./contrib/download_prerequisites
#rm -rf build
#mkdir build
#cd build
#$PWD/../configure --prefix=$CONFIG_SCRIPTS_DIR/bin/gcc-compile
#make -j8
#make install

# glibc 2.15
#
# This conditional needs to only run for glibc 2.12
#if [ "$(ldd --version | grep 'ldd' | sed -e 's|^[^0-9]*||g')" == "2.12" ] && [ ! -d glibc-compile ]; then
#	export GIT_PROXY_COMMAND=/root/bin/socks_connect
#	# RUN git clone git://sourceware.org/git/glibc.git
#	RUN pushd glibc
#	# RUN git checkout --track -b local_glibc-2.15 origin/release/2.15/master
#	RUN rm -rf build
#	RUN mkdir -p build/glibc-2.15
#	RUN cd build/glibc-2.15
#	RUN ../../configure --prefix="$CONFIG_SCRIPTS_DIR/bin/glibc-compile"
#	RUN make -j8
#	RUN make install
#fi


###############################################################################
############################# Python3
#
# https://stackoverflow.com/questions/8087184/installing-python3-on-rhel
#
#if [[ ! -d python3 ]] || [[ "$REINSTALL " == "TRUE " ]]; then
#	PRINTSTART "Python3"
#	RUN rm -f Python-3.4.2.tgz
#	RUN rm -rf Python-3.4.2
#	RUN rm -rf python3
#	RUN wget 'https://www.python.org/ftp/python/3.4.2/Python-3.4.2.tgz'
#	RUN tar xzf Python-3.4.2.tgz
#	RUN pushd Python-3.4.2
#	RUN ./configure --prefix="$CONFIG_SCRIPTS_DIR/bin/python3"
#	RUN make "-j$NUMTHREADS"
#	RUN make install
#	RUN popd
#	RUN rm -f Python-3.4.2.tgz
#	RUN rm -rf Python-3.4.2
#fi
#
#export PATH="$CONFIG_SCRIPTS_DIR/bin/python3/bin:$PATH"



