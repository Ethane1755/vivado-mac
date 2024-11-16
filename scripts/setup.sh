#!/bin/zsh

script_dir=$(dirname -- "$(readlink -nf $0)";)
IMAGE_NAME="ubuntu_vivado_env"
source "$script_dir/headers.sh"

if [ -d "$script_dir/../Xilinx" ]
then
	error "A previous installation was found. To reinstall, remove the Xilinx folder."
	exit 1
fi

if ! [[ $(docker image ls ) == *$IMAGE_NAME* ]]
then
    step "Build The Image"
    if ! docker build --platform linux/amd64 -t $IMAGE_NAME "$script_dir"
    then
        error "Docker image generation failed!"
        exit 1
    fi
    success "The Docker image was successfully generated."
else
    debug "The Image already exits"
fi

step "Start container for setup Vivado"
docker run --init --rm -it --name vivado_x11 --mount type=bind,source="$script_dir/..",target="/home/user" --platform linux/amd64 $IMAGE_NAME bash scripts/install.sh