FROM debian:testing

ARG DOCKER_GID
RUN : "${DOCKER_GID:?'DOCKER_GID' argument needs to be set and non-empty.}"

# Set proxy if it was set on the host
ARG FTP_PROXY=""
ARG HTTPS_PROXY=""
ARG HTTP_PROXY=""
ARG NO_PROXY=""
ARG SOCKS_PROXY=""
ARG ftp_proxy=""
ARG http_proxy=""
ARG https_proxy=""
ARG no_proxy=""
ARG socks_proxy=""

ENV FTP_PROXY=$FTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV NO_PROXY=$NO_PROXY
ENV SOCKS_PROXY=$SOCKS_PROXY
ENV ftp_proxy=$ftp_proxy
ENV http_proxy=$http_proxy
ENV https_proxy=$https_proxy
ENV no_proxy=$no_proxy
ENV socks_proxy=$socks_proxy

ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

RUN if [ -z "$FTP_PROXY" ]; then unset FTP_PROXY; fi; \
	if [ -z "$HTTPS_PROXY" ]; then unset HTTPS_PROXY; fi; \
	if [ -z "$HTTP_PROXY" ]; then unset HTTP_PROXY; fi; \
	if [ -z "$NO_PROXY" ]; then unset NO_PROXY; fi; \
	if [ -z "$SOCKS_PROXY" ]; then unset SOCKS_PROXY; fi; \
	if [ -z "$ftp_proxy" ]; then unset ftp_proxy; fi; \
	if [ -z "$http_proxy" ]; then unset http_proxy; fi; \
	if [ -z "$https_proxy" ]; then unset https_proxy; fi; \
	if [ -z "$no_proxy" ]; then unset no_proxy; fi; \
	if [ -z "$socks_proxy" ]; then unset socks_proxy; fi; \
	groupadd --non-unique -g $DOCKER_GID docker && \
	apt-get update && \
	apt-get install -y apt-transport-https ca-certificates wget dirmngr gnupg software-properties-common && \
	apt-get update && \
	apt-get install -y build-essential git zsh openssh-client less man tmux tree unzip zip ncdu pv python3-dev python3-pip cmake universal-ctags g++ curl wget gdb cscope astyle libncurses5-dev libatk1.0-dev docker.io liblua5.3-dev lua5.3 python3-watchdog openjdk-17-jdk maven locales gnuplot && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

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
COPY ./scripts/vimrc ./scripts/gitconfig ./scripts/gitignore_global ./scripts/global_ycm_extra_conf.py /etc/
COPY ./scripts/vim /etc/vim

WORKDIR /usr/local

RUN echo 'source /etc/zsh/zshrc_global' >> /etc/zsh/zshrc && \
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

# Can't build this via dein arg anymore since it refuses to build as root
RUN cd /etc/vim/bundle/dein.vim/state/repos/github.com/Valloric/YouCompleteMe && \
	./install.py --clang-completer --java-completer --rust-completer

WORKDIR /home/$USERNAME
CMD ["/usr/bin/zsh"]
