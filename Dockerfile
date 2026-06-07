FROM nvidia/cuda:12.6.0-devel-ubuntu22.04

# --- Environment ---------------------------------------------------------
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Tokyo \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ROS_DISTRO=humble \
    ROS_PYTHON_VERSION=3

# Expose the GPU (compute) and OpenGL (graphics/display) capabilities so that
# both CUDA workloads and OpenGL GUIs (RViz2 / Gazebo) work at runtime.
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

# --- Base utilities + locale + Python tooling ----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    tzdata \
    ca-certificates \
    curl \
    wget \
    gnupg2 \
    lsb-release \
    software-properties-common \
    sudo \
    git \
    vim \
    tmux \
    less \
    nano \
    htop \
    xsel \
    build-essential \
    cmake \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# --- OpenGL / GLVND stack (cudagl equivalent) ----------------------------
# NVIDIA stopped publishing `nvidia/cudagl` images for CUDA 12.x, so we add
# the GLVND / OpenGL libraries that those images used to bundle. This lets
# hardware-accelerated OpenGL apps (RViz2, Gazebo) render through the NVIDIA
# driver inside the container.
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglvnd0 \
    libglvnd-dev \
    libgl1 \
    libgl1-mesa-dev \
    libglx0 \
    libegl1 \
    libegl1-mesa-dev \
    libgles2 \
    libgles2-mesa-dev \
    libx11-6 \
    libxext6 \
    mesa-utils \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Register the NVIDIA EGL vendor ICD (also normally provided by cudagl).
RUN mkdir -p /usr/share/glvnd/egl_vendor.d \
    && echo '{"file_format_version":"1.0.0","ICD":{"library_path":"libEGL_nvidia.so.0"}}' \
    > /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# --- ROS 2 apt repository (Ubuntu 22.04 / ROS 2 Humble) ------------------
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    > /etc/apt/sources.list.d/ros2.list

# --- ROS 2 Humble desktop + build tooling --------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    ros-humble-xacro \
    ros-humble-joint-state-publisher \
    ros-humble-joint-state-publisher-gui \
    ros-humble-can-msgs \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    && (rosdep init || true) \
    && rm -rf /var/lib/apt/lists/*

# --- Gazebo (Ignition Fortress, via ros_ign) -----------------------------
# ros-humble-ros-ign is the ignition-branded bridge (a shim that pulls in
# ros_gz under the hood) and provides the ros_ign_* package names plus
# Gazebo Fortress (`ign gazebo`).
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-ros-ign \
    && rm -rf /var/lib/apt/lists/*

# Pre-populate rosdep so `rosdep install` works out of the box.
RUN rosdep update --rosdistro ${ROS_DISTRO}

# Keep the ROS environment loaded for interactive shells.
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc

# --- Python / PyTorch (CUDA 12.6 build) ----------------------------------
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    && python3 -m pip install --no-cache-dir --ignore-installed \
    torch==2.9.1 torchvision==0.24.1 torchaudio==2.9.1 \
    --index-url https://download.pytorch.org/whl/cu126

WORKDIR /workspace
CMD ["bash"]
