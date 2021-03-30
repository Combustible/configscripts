#!/bin/bash

input_user=$(whoami)
input_uid=$(id -u)
input_gid=$(id -g)
input_docker_gid=$(getent group docker | awk -F: '{printf "%d", $3}')

if [[ "$input_user " == " " ]]; then
	echo "Failed to determine username, please edit this script with the correct value and retry"
	exit -1
fi
if [[ "$input_uid " == " " ]]; then
	echo "Failed to determine user's ID, please edit this script with the correct value and retry"
	exit -1
fi
if [[ "$input_gid " == " " ]]; then
	echo "Failed to determine user's group ID, please edit this script with the correct value and retry"
	exit -1
fi
if [[ "$input_docker_gid " == " " ]]; then
	echo "Failed to determine system's docker group ID, please edit this script with the correct value and retry"
	exit -1
fi

PROXY_ARGS=""
if [[ ! -z "$FTP_PROXY" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg FTP_PROXY=$FTP_PROXY"
fi
if [[ ! -z "$HTTPS_PROXY" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg HTTPS_PROXY=$HTTPS_PROXY"
fi
if [[ ! -z "$HTTP_PROXY" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg HTTP_PROXY=$HTTP_PROXY"
fi
if [[ ! -z "$NO_PROXY" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg NO_PROXY=$NO_PROXY"
fi
if [[ ! -z "$SOCKS_PROXY" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg SOCKS_PROXY=$SOCKS_PROXY"
fi
if [[ ! -z "$ftp_proxy" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg ftp_proxy=$ftp_proxy"
fi
if [[ ! -z "$https_proxy" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg https_proxy=$https_proxy"
fi
if [[ ! -z "$http_proxy" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg http_proxy=$http_proxy"
fi
if [[ ! -z "$no_proxy" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg no_proxy=$no_proxy"
fi
if [[ ! -z "$socks_proxy" ]]; then
	PROXY_ARGS="$PROXY_ARGS --build-arg socks_proxy=$socks_proxy"
fi

cmd=(docker build . -t vim_dev_environment --build-arg USERNAME=$input_user --build-arg UID=$input_uid --build-arg GID=$input_gid --build-arg DOCKER_GID=$input_docker_gid $PROXY_ARGS)
"${cmd[@]}"
if [[ $? -eq 0 ]]; then
	cat <<EOF
*****

Build success!

To run this, recommend creating a new directory that will be the home directory
for this docker image. For example:

	mkdir -p ~/docker_home

Then add an alias to your ~/.bashrc, etc. to run the docker image. Something like:

	alias dev="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v \$HOME/dockerhome:\$HOME -v \$SSH_AUTH_SOCK:\$SSH_AUTH_SOCK -e SSH_AUTH_SOCK="\$SSH_AUTH_SOCK" vim_dev_environment"

Then run it with:

	dev
EOF

else
	cat <<EOF
*****

Failed to build docker image. It's possible this computer can't download
everything it needs from the internet. To work around this, you can try
building this image on a different computer, then copying it to this one. Use
this build command (and not this script!):

	${cmd[@]}

Then run:

	docker save vim_dev_environment:latest | gzip > vim_dev_environment.tgz
	# Transfer the image back to this computer
	gunzip --stdout vim_dev_environment.tgz | docker load
EOF
fi


