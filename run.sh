#!/bin/bash
set -euo pipefail

# Image name/tag and container name (override via environment variables).
IMAGE_NAME="${IMAGE_NAME:-cuda12.6-devel-ubuntu22.04-torch-humble}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-torch_humble}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Host workspace mounted into the container so your code/work persists.
HOST_WS="${SCRIPT_DIR}/workspace"
mkdir -p "${HOST_WS}"

# Allow the container to talk to the host X server so OpenGL GUIs
# (RViz2 / Gazebo) can render on the host display.
xhost +local:root >/dev/null 2>&1 || true

docker run -it --rm \
    --name "${CONTAINER_NAME}" \
    --gpus all \
    --net host \
    --ipc host \
    --privileged \
    -e DISPLAY="${DISPLAY:-:0}" \
    -e QT_X11_NO_MITSHM=1 \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v "${HOST_WS}:/workspace" \
    "${IMAGE_NAME}:${IMAGE_TAG}" \
    bash
