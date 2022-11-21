#!/usr/bin/env bash

# Runs a docker container with the image created by build_demo.bash
# Requires
#   docker
#   nvidia-docker2
#   an X server
# Recommended
#   A joystick mounted to /dev/input/js0 or /dev/input/js1

# PARSE INPUT ARGUMENTS

NVIDIA=false # set a default

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    --nvidia)
        NVIDIA=true
        echo "Running with Nvidia enabled"
        shift # past argument
        shift # past value
        ;;
    *)
        echo "Ignoring input argument: $key"
        shift # Shift removes from the list the argument
        shift # and value so we can continue with the next
        ;;
    esac
done

if [[ $NVIDIA == true ]]; then
    until nvidia-docker ps; do
        echo "Waiting for docker server"
        sleep 1
    done
fi

if ! [ -x "$(command -v git)" ]; then
    echo "Rocker not found pulling from pip"
    mkdir -p /tmp/car_demo_rocker_venv
    python3 -m venv /tmp/car_demo_rocker_venv
    . /tmp/car_demo_rocker_venv/bin/activate
    pip install -U git+https://github.com/osrf/rocker.git
fi

if [[ $NVIDIA == true ]]; then
    rocker --nvidia --x11 --devices /dev/input/js0 /dev/input/js1 -- osrf/car_demo
else
    rocker --x11 -- osrf/car_demo
fi
