#!/bin/bash

mkdir bin

###################  Build vim
# http://vim.wikia.com/wiki/Building_Vim
rm -f vim
git clone 'https://github.com/b4winckler/vim.git'
mv vim vim-src
pushd vim-src
make distclean
./configure --with-features=huge --prefix=`pwd`/../vim-compile
make -j8
make install
popd

export PATH=~/configscripts/bin/vim-compile/bin:$PATH

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


################### Python
# https://stackoverflow.com/questions/8087184/installing-python3-on-rhel
wget 'https://www.python.org/ftp/python/3.4.2/Python-3.4.2.tgz'
tar xzf Python-3.4.2.tgz
pushd Python-3.4.2
./configure --prefix=`pwd`/../python3
make  -j 8
make install
popd

export PATH=:~/configscripts/bin/python3/bin:$PATH



################### pdb-clone for pyclewn
# https://pypi.python.org/pypi/pdb-clone
wget 'https://pypi.python.org/packages/source/p/pdb-clone/pdb-clone-1.9.2.py3.tar.gz#md5=74c9968ff10b1b3c93d7da20a375a28c'
tar xzf pdb-clone-1.9.2.py3.tar.gz
pushd pdb-clone-1.9.2.py3
python3 setup.py install
popd

################### pyclewn
# http://pyclewn.sourceforge.net/install.html
# https://pypi.python.org/pypi/pyclewn
wget 'https://pypi.python.org/packages/source/p/pyclewn/pyclewn-2.0.tar.gz#md5=c55f6a2c018bdf409c3f28d24616b4f9'
tar xzf pyclewn-2.0.tar.gz
pushd pyclewn-2.0
python3 setup.py install
popd



