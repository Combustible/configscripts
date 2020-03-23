# Byron's Linux Config Scripts

This is a package of the development environment / configuration scripts I personally use for Linux software development.

It may be useful to people who are interested in learning about Vim and trying out some of the plugins I'm using without having to do too much work.

## Contents

This repository builds a docker image of the Vim environment I use for C/C++ development work. The image has just a single running process - sshd. You can SSH in, launch vim, and write some code.

The idea here is that any system with a working docker environment can build the image, mount source code into it, and be up and running without much work.

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

## Building

Building requires collecting the following variables:

- `-t byron_dev` - The local "tag" to give this image, which you can then use to run it
- `USERNAME` - The local user that should be created in the container
- `GIT_NAME` - Your name to put in ~/.gitconfig so commits will show up with the right author
- `GIT_EMAIL` - Your email address to put in ~/.gitconfig
- `UID` - What user ID the container user should have - this is important to match the host system you are running on so created files will have the right ownership
- `GID` - Group ID for the container user, see `UID`
- `DOCKER_GID` - The group ID of docker in the host system (in case you want to manipulate the host's docker from within the container)
- `SSH_KEY` - An entry to add to `~/.ssh/authorized_keys` so you can log in password-free (no support for password login)

Example command:
```
docker build . -t byron_dev --build-arg USERNAME=bmarohn --build-arg GIT_NAME="Byron Marohn" --build-arg GIT_EMAIL=pleasedontemailme@seriously.com --build-arg UID=1000 --build-arg GID=1000 --build-arg DOCKER_GID=999
```

Once this is built, suggest setting up a directory for persistent data for the docker image. For example:
```
mkdir ~/docker_home/dev ~/docker_home/.cargo ~/docker_home/
touch ~/docker_home/.histfile ~/docker_home/.viminfo
```

Then an alias to run and mount everything (in ~/.bashrc or similar):
```
alias dev='docker run --rm -it -v ~/docker_home/dev:/home/bmarohn/dev -v ~/docker_home/.histfile:/home/bmarohn/.histfile -v ~/docker_home/.viminfo:/home/bmarohn/.viminfo -v ~/docker_home/.cargo:/home/bmarohn/.cargo -v /var/run/docker.sock:/var/run/docker.sock byron_dev'
```

And run the alias to switch into the docker dev environment:
```
dev
```


### Read, and make changes!

There is a lot of stuff here that is at best self-documenting. I'd suggest reading over the $HOME/.vimrc script to see what plugins are included and exactly what I have changed. Also might be worth looking at the changes to $HOME/.gitconfig to make sure things look reasonable.
