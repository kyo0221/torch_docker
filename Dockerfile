FROM nvidia/cuda:12.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Etc/UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Base utilities + locale + Python tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    tzdata \
    curl \
    gnupg2 \
    ca-certificates \
    lsb-release \
    software-properties-common \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    build-essential \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# ROS 2 apt repository setup (Ubuntu 22.04 / ROS 2 Humble)
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
    > /etc/apt/sources.list.d/ros2.list

# Install ROS 2 Humble desktop
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-humble-desktop \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    && rosdep init \
    && rm -rf /var/lib/apt/lists/*

# Keep ROS environment loaded for interactive shells
RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc

# Update pip and install PyTorch for CUDA 12.8
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel \
    && python3 -m pip install --no-cache-dir --ignore-installed \
    torch==2.9.1 torchvision==0.24.1 torchaudio==2.9.1 \
    --index-url https://download.pytorch.org/whl/cu128

WORKDIR /workspace
CMD ["bash"]
