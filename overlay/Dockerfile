# Diff-only overlay for the already-published base image.
#
# This builds ON TOP of the existing Docker Hub image and only adds the
# ros2_control packages required by the simulator's gz_ros2_control plugin
# (caster / driven-wheel actuation). Because every base layer already exists
# on the registry, `docker push` uploads ONLY this new layer.
#
# The canonical source of truth lives in ../Dockerfile; keep both in sync.
ARG BASE_IMAGE=kyo0221/cudagl:12.8.1-devel-ubuntu22.04-torch-humble
FROM ${BASE_IMAGE}

# --- ros2_control for Gazebo (gz_ros2_control plugin) ---------------------
# ros-humble-gz-ros2-control pulls in controller_manager / ros2_control;
# ros2-controllers provides the position_controllers used for the
# caster_yaw joint. The ROS 2 apt repo is already configured in the base.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-gz-ros2-control \
    ros-humble-controller-manager \
    ros-humble-ros2-controllers \
    && rm -rf /var/lib/apt/lists/*
