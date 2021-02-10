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

cmd=(docker build . -t vim_dev_environment --build-arg USERNAME=$input_user --build-arg UID=$input_uid --build-arg GID=$input_gid --build-arg DOCKER_GID=$input_docker_gid)
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


