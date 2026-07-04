#!/bin/bash
set -euo pipefail

# Build the diff-only overlay on top of the existing published image and push
# it back to the SAME tag. Only the newly added layer is uploaded; all base
# layers already live on the registry.
#
# Override the image ref via environment variables if needed.
IMAGE_NAME="${IMAGE_NAME:-kyo0221/cudagl}"
IMAGE_TAG="${IMAGE_TAG:-12.8.1-devel-ubuntu22.04-torch-humble}"
IMAGE_REF="${IMAGE_NAME}:${IMAGE_TAG}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Make sure we overlay the latest published base (not a stale local copy).
docker pull "${IMAGE_REF}"

# Build the overlay, re-tagging it as the same ref so the push is diff-only.
docker image build \
    --build-arg "BASE_IMAGE=${IMAGE_REF}" \
    -t "${IMAGE_REF}" \
    "${SCRIPT_DIR}"

docker push "${IMAGE_REF}"
