FROM debian:stable

ARG DOCKER_GID
RUN : "${DOCKER_GID:?'DOCKER_GID' argument needs to be set and non-empty.}"

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN groupadd --non-unique -g $DOCKER_GID docker && \
	apt-get update && \
	apt-get install -y apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common && \
	wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - && \
	add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ && \
	apt-get update && \
	apt-get install -y build-essential git zsh openssh-client less man tmux tree ncdu pv python3-dev cmake ctags g++ curl wget gdb cscope astyle libncurses5-dev libatk1.0-dev docker.io liblua5.3-dev lua5.3 python3-watchdog adoptopenjdk-8-hotspot maven && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN git clone 'https://github.com/vim/vim.git' vim-src && \
	cd vim-src && \
	make distclean && \
	./configure --with-features=huge --enable-python3interp --enable-luainterp --with-compiledby='Byron Marohn <combustible@live.com>' && \
	make -j8 && \
	make install && \
	cd .. && \
	rm -rf vim-src

COPY ./scripts/zshenv ./scripts/zshrc_global /etc/zsh/
COPY ./scripts/vimrc ./scripts/gitconfig ./scripts/gitignore_global /etc/
COPY ./scripts/vim /etc/vim

WORKDIR /usr/local

RUN wget -qO - https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz | tar xz && \
	echo 'export PATH="$PATH:/usr/local/go/bin"' | tee -a /etc/bash.bashrc /etc/zsh/zshrc && \
	export PATH="$PATH:/usr/local/go/bin" && \
	echo 'source /etc/zsh/zshrc_global' >> /etc/zsh/zshrc && \
	touch /root/.vimrc && \
	git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git /etc/oh-my-zsh && \
	mkdir -p /etc/vim/bundle && \
	git clone 'https://github.com/Shougo/dein.vim' /etc/vim/bundle/dein.vim && \
	vim -N -u /etc/vimrc -c "try | call dein#update() | finally | qall! | endtry" -V1 -es && \
	mkdir -p /etc/vim/doc/ && \
	cd /etc/vim/doc/ && \
	rm -f 'tags' && \
	vim -N -u /etc/vimrc '+helptags .' '+qall'

ARG USERNAME
ARG UID
ARG GID
RUN : "${USERNAME:?'USERNAME' argument needs to be set and non-empty.}"
RUN : "${UID:?'UID' argument needs to be set and non-empty.}"
RUN : "${GID:?'GID' argument needs to be set and non-empty.}"

RUN groupadd --non-unique -g $GID $USERNAME && \
	# NOTE! -l flag prevents creation of gigabytes of sparse log file for some reason
	useradd -lmNs /usr/bin/zsh -u $UID -g $GID $USERNAME && \
	usermod -a -G docker $USERNAME && \
	chown $UID:$GID -R /etc/vim

USER $USERNAME

WORKDIR /home/$USERNAME
CMD ["/usr/bin/zsh"]
