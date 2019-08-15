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
docker build . -t byron_dev --build-arg USERNAME=bmarohn --build-arg GIT_NAME="Byron Marohn" --build-arg GIT_EMAIL=pleasedontemailme@seriously.com --build-arg UID=1000 --build-arg GID=1000 --build-arg DOCKER_GID=999 --build-arg SSH_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDidsslbXU9IjUHhZhJvhK7kzxc/F2l74+Ptv05k3NhD9JOvEu+ACN9cztddt1Gp4v5ZKjoqdP34u62pfLyDf8/edPdZpwr5RSv8cE0T8bTKVmD3a/XjpO6Y2CytVhrtg15ICvVADZ7eW/zvS4/3A7MVR+nPAqFIxzW0SrrcYgER1jTlpvSD4EIZS102FfJggV6bjrPlViNE8RAwPtbJh0E8yOiJIgITXb+gDnjTSEar6h+0oMI61fW0xxtO0BY/8wQvv+RoHxzsctHS14GN2/XzoEXUTvv9WA4Comyq0EHkOXUcK4sBy1atqk7pTN0o2VnhspUHdv6SHhKIjwz6cMuBySJVykTPlWUdrEpcAjFofQC/YcK9Q1B1riQg5fYu92HJhDrwYWehQzLs9UWqPR8h6oomaP0ie3YHbiS4tWpFHT2fSUQ/8f+TdIwuIQULfRtJisFA7uqCECFkEwQLz8/Bgbdh4OqPy5xM47cJZWBE3fF4VQfXNNpujpbOt/aGoXO4IdvdOQPQ1+wSeWVvQJ7l63qOz4gtfz7Xlw8xOAQgcvP43RCMQRdwDPtvwnPZH6yH1X6hElUtFugzb5DCZXXzwsfhy/QhEkmGvkeP8NIUQDHgyDb7LWqe09o3ko8BsrsiifEBxv+XkDOHdMdmcZK0W2BHWOc35wKbm7IMuc7HQ== 8f:b8:18:43:03:4e:a5:42:5b:ce:95:2d:bc:1a:a1:86 Byron Marohn Personal Key 2016'
```

### Read, and make changes!

There is a lot of stuff here that is at best self-documenting. I'd suggest reading over the $HOME/.vimrc script to see what plugins are included and exactly what I have changed. Also might be worth looking at the changes to $HOME/.gitconfig to make sure things look reasonable.
