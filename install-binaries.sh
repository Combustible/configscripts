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
		echo -e "${BADCOLOR}Command line argument '$1' not understood. Valid arguments are -j<number of threads> and --reinstall${ENDBADCOLOR}"
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
############################# Git
#
# http://git-scm.com/book/en/v2/Getting-Started-Installing-Git
#
# CentOS/Fedora:
#   yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc xmlto docbook2X autoconf gcc
#   ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi
#
# Debian/Ubuntu:
#   apt-get install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev asciidoc xmlto docbook2x autoconf
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
############################# Python3
#
# https://stackoverflow.com/questions/8087184/installing-python3-on-rhel
#
if [[ ! -d python3 ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python3"
	RUN rm -f Python-3.4.2.tgz
	RUN rm -rf Python-3.4.2
	RUN rm -rf python3
	RUN wget 'https://www.python.org/ftp/python/3.4.2/Python-3.4.2.tgz'
	RUN tar xzf Python-3.4.2.tgz
	RUN pushd Python-3.4.2
	RUN ./configure --prefix="$CONFIG_SCRIPTS_DIR/bin/python3"
	RUN make "-j$NUMTHREADS"
	RUN make install
	RUN popd
	RUN rm -f Python-3.4.2.tgz
	RUN rm -rf Python-3.4.2
fi

export PATH="$CONFIG_SCRIPTS_DIR/bin/python3/bin:$PATH"

###############################################################################
############################# Python2
#
# https://stackoverflow.com/questions/8087184/installing-python3-on-rhel
#
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

###############################################################################
############################# Cscope
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
# sudo apt-get install libncurses5-dev libatk1.0-dev
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
if [[ ! -d pdb-clone-1.9.2.py2.7 ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 pdb-clone"
	RUN rm -f pdb-clone-1.9.2.py2.7.tar.gz
	RUN rm -rf pdb-clone-1.9.2.py2.7
	RUN wget 'https://pypi.python.org/packages/source/p/pdb-clone/pdb-clone-1.9.2.py2.7.tar.gz#md5=248b8cdad99c8e3c57accde28e77b586'
	RUN tar xzf pdb-clone-1.9.2.py2.7.tar.gz
	RUN pushd pdb-clone-1.9.2.py2.7
	RUN python setup.py install
	RUN popd
	RUN rm -f pdb-clone-1.9.2.py2.7.tar.gz
fi

###############################################################################
############################# Python2 trollius
if [[ ! -d trollius-1.0.4 ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 trollius"
	RUN rm -f trollius-1.0.4.tar.gz
	RUN rm -rf trollius-1.0.4
	RUN wget 'https://pypi.python.org/packages/source/t/trollius/trollius-1.0.4.tar.gz#md5=3631a464d49d0cbfd30ab2918ef2b783'
	RUN tar xzf trollius-1.0.4.tar.gz
	RUN pushd trollius-1.0.4
	RUN python setup.py install
	RUN popd
	RUN rm -f trollius-1.0.4.tar.gz
fi

###############################################################################
############################# Python2 pyclewn
#
# http://pyclewn.sourceforge.net/install.html
# https://pypi.python.org/pypi/pyclewn
#
if [[ ! -d pyclewn-2.0 ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 pyclewn"
	RUN rm -f pyclewn-2.0.tar.gz
	RUN rm -rf pyclewn-2.0
	RUN wget 'https://pypi.python.org/packages/source/p/pyclewn/pyclewn-2.0.tar.gz#md5=c55f6a2c018bdf409c3f28d24616b4f9'
	RUN tar xzf pyclewn-2.0.tar.gz
	RUN pushd pyclewn-2.0
	RUN python setup.py install
	RUN popd
	RUN rm -f pyclewn-2.0.tar.gz
fi

###############################################################################
############################# Python2 pyserial
#
if [[ ! -d pyserial-2.7 ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Python2 pyserial"
	RUN rm -f pyserial-2.7.tar.gz
	RUN rm -rf pyserial-2.7
	RUN wget 'https://pypi.python.org/packages/source/p/pyserial/pyserial-2.7.tar.gz#md5=794506184df83ef2290de0d18803dd11'
	RUN tar xzf pyserial-2.7.tar.gz
	RUN pushd pyserial-2.7
	RUN python setup.py install
	RUN popd
	RUN rm -f pyserial-2.7.tar.gz
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
############################# Vim Vundle
if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Vim Vundle"
	rm -rf "$HOME/.vim/bundle/Vundle.vim"
	RUN git clone 'https://github.com/gmarik/Vundle.vim.git' "$HOME/.vim/bundle/Vundle.vim"
fi

###############################################################################
############################# Vim YouCompleteMe
# YouCompleteMe requires a more complicated installation process
#
# On ubuntu:
#   apt-get install cmake
#
# On CentOS6:
#   yum install clang
#   pushd /usr/lib64
#   ln -s libedit.so.0 libedit.so.2
#   popd
#
if [[ ! -d "$HOME/.vim/bundle/YouCompleteMe" ]] || [[ "$REINSTALL " == "TRUE " ]]; then
	PRINTSTART "Vim YouCompleteMe"
	RUN pushd "$HOME/.vim/bundle"
	RUN	rm -rf YouCompleteMe
	RUN git clone 'https://github.com/Valloric/YouCompleteMe.git'
	RUN cd YouCompleteMe
	RUN git submodule update --init --recursive
	export CMAKE_INCLUDE_PATH="$CONFIG_SCRIPTS_DIR/bin/python2/include"
	export EXTRA_CMAKE_ARGS="-DPYTHON_INCLUDE_DIR=$CONFIG_SCRIPTS_DIR/bin/python2/include/python2.7/ -DPYTHON_LIBRARY=$CONFIG_SCRIPTS_DIR/bin/python2/lib/libpython2.7.so -DPYTHON_EXECUTABLE=$CONFIG_SCRIPTS_DIR/bin/python2/bin/python"
	if [[ "$(ldd --version | grep 'ldd' | sed -e 's|^[^0-9]*||g')" == "2.12" ]]; then
		RUN ./install.sh --clang-completer --system-libclang
	else
		RUN ./install.sh --clang-completer
	fi
	RUN popd
fi

echo -e "${GOODCOLOR}Install complete!${ENDGOODCOLOR}"



##############################################################################
#----- The following junk still lives here in case I ever need it again ------
##############################################################################

# sudo yum install glibc-devel.i686
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




