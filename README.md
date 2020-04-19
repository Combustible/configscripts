# Byron's Vim-centric Docker Integrated Development Environment

This is an easy-to-use Docker image of the Linux development environment I
personally use.

It is easy to set up, requires installing nothing on the host system besides
Docker, and has features comparable to the best of Visual Studio, Eclipse, etc.
It's also free and open source.

## Contents

This repository builds a docker image of the Vim environment I use for
C/C++/Rust/Java development work. This image drops you directly to a ZSH
command line where you can launch Vim (and other tools) and get right to work.
It only runs when you are using it - there is no background process.

Some things in here that I like:
- Vim
- Git
- ZSH - A better shell than Bash
- Astyle - Automatic code beautification
- GDB - Debugging

Vim plugins, sorted roughly by the amount I appreciate them:
- YouCompleteMe - Semantically-aware autocompletion
- NERDTree - Better folder browsing
- Fugitive - Git integration
- Vim-Bracketed-Paste - Automatically switch to :paste mode when pasting
- vimwiki - Note taking tool

For more information, see the scripts!
- [Dockerfile](Dockerfile)
- [.vimrc](scripts/vimrc)
- [.zshrc](scripts/zshrc)

## Getting started

Run `./build.sh` to build the image. This will automatically grab your current
user ID, group ID, and the docker group ID, so that when you mount files into
the docker image the permissions will work out as expected.

Once the build is complete, it will suggest adding a quick alias to launch into
your login script (`~/.bashrc` or similar). The idea is to create a separate
directory to be the home directory for the development image, and then mount it
in as the docker user's home. The docker image won't be able to get to the rest
of your computer - just what folders you choose to mount. You can of course
mount your actual home directory there if you want.

At that point, you can customize the environment for yourself by adding to
.vimrc and .zshrc. You might be surprised to find these empty - my base files
are installed to /etc/vimrc and /etc/zshrc which form the base development
platform so you don't have to configure the vast majority of it yourself.

### Read, and make changes!

There is a lot of stuff here that is at best self-documenting. I'd suggest
reading over the $HOME/.vimrc script to see what plugins are included and
exactly what I have changed. Also might be worth looking at the changes to
$HOME/.gitconfig to make sure things look reasonable.
