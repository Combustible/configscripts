FROM debian:stable

# Check for mandatory build arguments
ARG USERNAME
ARG GIT_NAME
ARG GIT_EMAIL
ARG UID
ARG GID
ARG DOCKER_GID
RUN : "${USERNAME:?'USERNAME' argument needs to be set and non-empty.}"
RUN : "${GIT_NAME:?'GIT_NAME' argument needs to be set and non-empty.}"
RUN : "${GIT_EMAIL:?'GIT_EMAIL' argument needs to be set and non-empty.}"
RUN : "${UID:?'UID' argument needs to be set and non-empty.}"
RUN : "${GID:?'GID' argument needs to be set and non-empty.}"
RUN : "${DOCKER_GID:?'DOCKER_GID' argument needs to be set and non-empty.}"

RUN groupadd --non-unique -g $DOCKER_GID docker && \
	apt-get update && \
	apt-get install -y build-essential git zsh openssh-client less man tmux tree ncdu pv python-dev cmake ctags g++ wget gdb cscope openssh-server astyle libncurses5-dev libatk1.0-dev docker.io liblua5.3-dev lua5.3 && \
	mkdir /var/run/sshd

ENV USERHOME /home/$USERNAME

RUN groupadd --non-unique -g $GID $USERNAME && \
	# NOTE! -l flag prevents creation of gigabytes of sparse log file for some reason
	useradd -lmNs /usr/bin/zsh -u $UID -g $GID $USERNAME && \
	usermod -a -G docker $USERNAME && \
	mkdir /root/.ssh $USERHOME/.ssh && \
	echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDidsslbXU9IjUHhZhJvhK7kzxc/F2l74+Ptv05k3NhD9JOvEu+ACN9cztddt1Gp4v5ZKjoqdP34u62pfLyDf8/edPdZpwr5RSv8cE0T8bTKVmD3a/XjpO6Y2CytVhrtg15ICvVADZ7eW/zvS4/3A7MVR+nPAqFIxzW0SrrcYgER1jTlpvSD4EIZS102FfJggV6bjrPlViNE8RAwPtbJh0E8yOiJIgITXb+gDnjTSEar6h+0oMI61fW0xxtO0BY/8wQvv+RoHxzsctHS14GN2/XzoEXUTvv9WA4Comyq0EHkOXUcK4sBy1atqk7pTN0o2VnhspUHdv6SHhKIjwz6cMuBySJVykTPlWUdrEpcAjFofQC/YcK9Q1B1riQg5fYu92HJhDrwYWehQzLs9UWqPR8h6oomaP0ie3YHbiS4tWpFHT2fSUQ/8f+TdIwuIQULfRtJisFA7uqCECFkEwQLz8/Bgbdh4OqPy5xM47cJZWBE3fF4VQfXNNpujpbOt/aGoXO4IdvdOQPQ1+wSeWVvQJ7l63qOz4gtfz7Xlw8xOAQgcvP43RCMQRdwDPtvwnPZH6yH1X6hElUtFugzb5DCZXXzwsfhy/QhEkmGvkeP8NIUQDHgyDb7LWqe09o3ko8BsrsiifEBxv+XkDOHdMdmcZK0W2BHWOc35wKbm7IMuc7HQ== 8f:b8:18:43:03:4e:a5:42:5b:ce:95:2d:bc:1a:a1:86 Byron Marohn Personal Key 2016' > /root/.ssh/authorized_keys && \
	cp /root/.ssh/authorized_keys $USERHOME/.ssh/authorized_keys && \
	chown -R root:root /root/.ssh && \
	chown -R $USERNAME:$USERNAME $USERHOME/.ssh && \
	chmod go-rwx /root/.ssh $USERHOME/.ssh

# Vim
USER root
WORKDIR /tmp
RUN git clone 'https://github.com/vim/vim.git' vim-src && \
	cd vim-src && \
	make distclean && \
	./configure --with-features=huge --enable-pythoninterp --enable-luainterp --with-compiledby='Byron Marohn <combustible@live.com>' && \
	make -j8 && \
	make install && \
	cd .. && \
	rm -rf vim-src

COPY . $USERHOME/configscripts
RUN chown -R $USERNAME:$USERNAME $USERHOME/configscripts

USER $USERNAME
WORKDIR $USERHOME/configscripts
RUN ./install-scripts.sh && \
	git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh

# Dein & update plugins
RUN  rm -rf $USERHOME/.vim/bundle/dein.vim && \
	git clone 'https://github.com/Shougo/dein.vim' $USERHOME/.vim/bundle/dein.vim && \
	vim -N -u $USERHOME/.vimrc -c "try | call dein#update() | finally | qall! | endtry" -V1 -es && \
	cd $USERHOME/.vim/doc/ && \
	rm -f 'tags' && \
	vim '+helptags .' '+qall' && \
	rm $USERHOME/configscripts/scripts/vim/bundle/dein.vim/state/repos/github.com/jeaye/color_coded/*.xz

EXPOSE 22

USER root
#ENTRYPOINT ["/bin/bash"]
CMD ["/usr/sbin/sshd", "-D"]
