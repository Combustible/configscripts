#!/bin/bash

mkdir -p bin
cd bin

################### Build git
# http://git-scm.com/book/en/v2/Getting-Started-Installing-Git
#
# yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc xmlto docbook2x
# apt-get install libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev asciidoc xmlto docbook2x

# Old centos might require:
#    yum install docbook2X-texi
#    ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi
#
# Get source URL from here: https://www.kernel.org/pub/software/scm/git/
wget 'https://www.kernel.org/pub/software/scm/git/git-2.3.0.tar.gz'
tar xzf git-2.3.0.tar.gz
pushd git-2.3.0
make configure
./configure --prefix=`pwd`/../git-compile
make all doc info -j 8
make install install-doc install-html install-info
popd

export PATH=~/configscripts/bin/git-compile/bin:$PATH


################### Python3
# https://stackoverflow.com/questions/8087184/installing-python3-on-rhel
wget 'https://www.python.org/ftp/python/3.4.2/Python-3.4.2.tgz'
tar xzf Python-3.4.2.tgz
pushd Python-3.4.2
./configure --prefix=`pwd`/../python3
make  -j 8
make install
popd

export PATH=:~/configscripts/bin/python3/bin:$PATH

################### Python2
# https://stackoverflow.com/questions/8087184/installing-python3-on-rhel
wget 'https://www.python.org/ftp/python/2.7.9/Python-2.7.9.tgz'
tar xzf Python-2.7.9.tgz
pushd Python-2.7.9
./configure --prefix=`pwd`/../python2
make  -j 8
make install
popd

export PATH=:~/configscripts/bin/python2/bin:$PATH


###################  Build vim
# http://vim.wikia.com/wiki/Building_Vim
#
# For Ubuntu:
# sudo apt-get install libncurses5-dev libatk1.0-dev
#
git clone 'https://github.com/b4winckler/vim.git'
mv vim vim-src
pushd vim-src
make distclean
./configure \
    --with-features=huge \
    --enable-pythoninterp \
    --with-compiledby="Byron Marohn <byron.marohn@intel.com>" \
    --prefix=`pwd`/../vim-compile

#    --enable-python3interp

make -j8
make install
popd

export PATH=~/configscripts/bin/vim-compile/bin:$PATH

################### pdb-clone for pyclewn
# https://pypi.python.org/pypi/pdb-clone
wget 'https://pypi.python.org/packages/source/p/pdb-clone/pdb-clone-1.9.2.py2.7.tar.gz#md5=248b8cdad99c8e3c57accde28e77b586'
tar xzf pdb-clone-1.9.2.py2.7.tar.gz
pushd pdb-clone-1.9.2.py2.7
python setup.py install
popd

################### trollius
wget 'https://pypi.python.org/packages/source/t/trollius/trollius-1.0.4.tar.gz#md5=3631a464d49d0cbfd30ab2918ef2b783'
tar xzf trollius-1.0.4.tar.gz
pushd trollius-1.0.4
python setup.py install
popd

################### pyclewn
# http://pyclewn.sourceforge.net/install.html
# https://pypi.python.org/pypi/pyclewn
wget 'https://pypi.python.org/packages/source/p/pyclewn/pyclewn-2.0.tar.gz#md5=c55f6a2c018bdf409c3f28d24616b4f9'
tar xzf pyclewn-2.0.tar.gz
pushd pyclewn-2.0
python setup.py install
popd

################### gdb
wget http://ftp.gnu.org/gnu/gdb/gdb-7.8.2.tar.gz
tar xzf gdb-7.8.2.tar.gz
pushd gdb-7.8.2
./configure --prefix=`pwd`/../gdb-compile
make -j8
make install
popd

export PATH=~/configscripts/bin/gdb-compile/bin:$PATH
