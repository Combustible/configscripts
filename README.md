# Byron's Linux Config Scripts

This is a package of the configuration scripts I personally use for Linux software development.

It may be useful to people who are interested in learning about Vim and trying out some of the plugins I'm using without having to do too much work.

## Contents

Installing this package will add customization for the following items:

* $HOME/.gitconfig
* $HOME/.gdbinit
* $HOME/.zshrc
* $HOME/.commonrc
* $HOME/.vimrc
* $HOME/.vim

## Setup
### Clone project
```sh
cd $HOME
git clone https://github.com/Combustible/configscripts.git
```

### Install required packages:
#### Ubuntu:
apt-get install libcurl4-openssl-dev libexpat1-dev gettext libz-dev libssl-dev asciidoc xmlto docbook2x autoconf python-dev libncurses5-dev libatk1.0-dev cmake ctags g++


#### CentOS / Fedora:
```sh
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel asciidoc xmlto docbook2X autoconf gcc perl-devel gcc-c++ python-devel ncurses-devel clang cmake libstdc++-static ctags
ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi
```

Additionally, if using CentOS6 this might be required:
```sh
pushd /usr/lib64
ln -s libedit.so.0 libedit.so.2
popd
```

### Install scripts
```sh
cd $HOME/configscripts
./install-scripts.sh
```

This will add some symbolic links to your home directory to make the contents all point to items in $HOME/configscripts.
If files already exist and are not symbolic links, they won't be overwritten

Note that I use zsh instead of Bash. If you use bash or any other shell, the install-scripts.sh script will tell you that you have to add "source $HOME/.commonrc" to whatever shell script is run when you log in (for example, $HOME/.bashrc)

### Install binaries
```sh
cd $HOME/configscripts
./install-binaries -j8
```

This will download and compile several programs from source under $HOME/configscripts/bin. Look at the script, it's pretty well documented.

When the script first runs, it will ask you if you want to use the built-in system python. If you say yes, it'll install some python modules needed for Pyclewn (GDB Debugging within Vim) into the system python directory. This will require root access, so it'll automatically try to use sudo to install these modules. You'll get to see exactly what command the script is trying to run before you have to enter your sudo passphrase.

If you don't want to install to the system, don't want to use sudo, or don't have root access, choose "no". The script will attempt to download and compile Python into $HOME/configscripts/bin. This may work, but I usually don't use this configuration so it isn't nearly as well tested.

If at any point something goes wrong in the installation, your best bet is to read the error message and the install-binaries.sh script for clues. If you can't figure it out, feel free to email/message me about it.

### Read, and make changes!

There is a lot of stuff here that is at best self-documenting. I'd suggest reading over the $HOME/.vimrc script to see what plugins are included and exactly what I have changed. Also might be worth looking at the changes to $HOME/.gitconfig to make sure things look reasonable.
