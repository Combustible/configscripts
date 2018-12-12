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
```sh
apt-get install python-dev cmake ctags g++
```

#### CentOS / Fedora:
```sh
yum install gcc gcc-c++ python-devel ncurses-devel clang cmake ctags
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

This used to manually compile a bunch of packages in your home directory (git, gdb, even python2). It doesn't anymore because new enough versions of most packages tend to exist on the systems I use to develop these days. As of this writing, only cscope, Vim, and Astyle are compiled (plus loading/compiling vim plugins themselves).

This script no longer uses sudo in any capacity.

If at any point something goes wrong in the installation, your best bet is to read the error message and the install-binaries.sh script for clues. If you can't figure it out, feel free to email/message me about it.

### Read, and make changes!

There is a lot of stuff here that is at best self-documenting. I'd suggest reading over the $HOME/.vimrc script to see what plugins are included and exactly what I have changed. Also might be worth looking at the changes to $HOME/.gitconfig to make sure things look reasonable.
