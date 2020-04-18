FROM debian:stable

ARG DOCKER_GID
RUN : "${DOCKER_GID:?'DOCKER_GID' argument needs to be set and non-empty.}"

RUN groupadd --non-unique -g $DOCKER_GID docker && \
	apt-get update && \
	apt-get install -y apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
	add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/

RUN apt-get update && \
	apt-get install -y build-essential git zsh openssh-client less man tmux tree ncdu pv python3-dev cmake ctags g++ curl wget gdb cscope astyle libncurses5-dev libatk1.0-dev docker.io liblua5.3-dev lua5.3 python3-watchdog adoptopenjdk-8-hotspot maven && \
	rm -rf /var/lib/apt/lists/*

ARG USERNAME
ARG GIT_NAME
ARG GIT_EMAIL
ARG UID
ARG GID
RUN : "${USERNAME:?'USERNAME' argument needs to be set and non-empty.}"
RUN : "${GIT_NAME:?'GIT_NAME' argument needs to be set and non-empty.}"
RUN : "${GIT_EMAIL:?'GIT_EMAIL' argument needs to be set and non-empty.}"
RUN : "${UID:?'UID' argument needs to be set and non-empty.}"
RUN : "${GID:?'GID' argument needs to be set and non-empty.}"

ENV USERHOME /home/$USERNAME

RUN groupadd --non-unique -g $GID $USERNAME && \
	# NOTE! -l flag prevents creation of gigabytes of sparse log file for some reason
	useradd -lmNs /usr/bin/zsh -u $UID -g $GID $USERNAME && \
	usermod -a -G docker $USERNAME

WORKDIR /tmp

# Vim
RUN git clone 'https://github.com/vim/vim.git' vim-src && \
	cd vim-src && \
	make distclean && \
	./configure --with-features=huge --enable-python3interp --enable-luainterp --with-compiledby='Byron Marohn <combustible@live.com>' && \
	make -j8 && \
	make install && \
	cd .. && \
	rm -rf vim-src

USER $USERNAME

# Rust
RUN curl --proto '=https' --tlsv1.2 -sSf "https://sh.rustup.rs" -o rustup.sh && \
	chmod +x rustup.sh && \
	./rustup.sh -y && \
	. $USERHOME/.cargo/env && \
	rustup component add rls rust-analysis rust-src

USER root

COPY ./scripts/vimrc $USERHOME/.vimrc
COPY ./scripts/zshrc $USERHOME/.zshrc
COPY ./scripts/vim $USERHOME/.vim
COPY ./scripts/gitconfig $USERHOME/.gitconfig
COPY ./scripts/gitignore_global $USERHOME/.gitignore_global

RUN mkdir $USERHOME/dev && \
	chown -R $USERNAME:$USERNAME $USERHOME

USER $USERNAME

RUN git config --global user.name "$GIT_NAME" && \
	git config --global user.email "$GIT_EMAIL" && \
	git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh && \
	rm -rf $USERHOME/.vim/bundle/dein.vim && \
	git clone 'https://github.com/Shougo/dein.vim' $USERHOME/.vim/bundle/dein.vim && \
	vim -N -u $USERHOME/.vimrc -c "try | call dein#update() | finally | qall! | endtry" -V1 -es && \
	cd $USERHOME/.vim/doc/ && \
	rm -f 'tags' && \
	vim '+helptags .' '+qall'

WORKDIR $USERHOME/dev
CMD ["/usr/bin/zsh"]
