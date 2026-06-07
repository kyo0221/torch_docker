#!/bin/bash
set -euo pipefail

# Image name/tag (override via environment variables if needed).
IMAGE_NAME="${IMAGE_NAME:-cuda12.6-devel-ubuntu22.04-torch-humble}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

docker image build \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    "${SCRIPT_DIR}"
