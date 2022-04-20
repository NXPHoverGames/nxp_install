#!/bin/bash

#TODO check version of script

###############################################################################
catch_errors () {
    if [[ $? > 0 ]]
    then
        echo "Command failed, please contact Benjamin Perseghetti (benjamin.perseghetti@nxp.com), or Landon Haugh (landon.haugh@nxp.com) for support"
        exit
    else
        echo "Command ran successfully. Continuing..."
    fi
}
###############################################################################

###############################################################################
#Locale checking/set portion for UTF8
#if SET_LOCALE is assigned, forces system to use that UTF8 locale without asking for entry.

SET_LOCALE=""
COMMON_LOCALES=("af_ZA" "ar_AE" "de_DE" "en_GB" "en_US" "es_MX" "fi_FI" "fr_FR" "he_IL" "hi_IN" "it_IT" "ja_JP" "nl_NL" "pl_PL" "pt_PT" "sv_SE" "zh_CN")

#Checks for default locale file and allows entry if SET_LOCALE not set 
if [ ! -f /etc/default/locale ] || [[ ! "${LC_ALL}" =~ ".UTF-8" ]] || [[ ! "${LANG}" =~ ".UTF-8" ]]; then
    if [ -z ${SET_LOCALE} ]; then
        echo "System locale not UTF-8 and no SET_LOCALE set in script."
        echo "Common locale options: ${COMMON_LOCALES[@]}"
        echo "Please type the desired locale and [ENTER]"
        read SET_LOCALE
        if [[ ! ${COMMON_LOCALES[*]} =~ "${SET_LOCALE}" ]] || [ -z ${SET_LOCALE} ]; then
            echo "Provided locale: ${SET_LOCALE} not in common locale options."
            echo "Please retype desired locale or select one from common list to confirm."
            read SET_LOCALE2
            if [ ${SET_LOCALE} != ${SET_LOCALE2} ] && [[ ! ${COMMON_LOCALES[*]} =~ "${SET_LOCALE}" ]] || [ -z ${SET_LOCALE} ]; then
                echo "Locale not in common locale list and did not match previous entry."
                echo "Please rerun script and look at potential locale options: https://docs.oracle.com/cd/E23824_01/html/E26033/glset.html"
                exit 0
            else
                SET_LOCALE=${SET_LOCALE2}
            fi
        fi
    fi
fi
if [ -z ${SET_LOCALE} ]; then
    echo "System locale already set to ${LC_ALL}."
elif [ ! $(locale | grep "LC_ALL=${SET_LOCALE}.UTF-8" ) != "" ] || [ ! $(locale | grep "LANG=${SET_LOCALE}.UTF-8" ) != "" ]; then
    echo "System locale set to: ${LC_ALL} "
    echo "Correctly setting to ${SET_LOCALE}.UTF-8 now."
    sudo apt-get update && sudo apt-get -y install locales
    sudo locale-gen ${SET_LOCALE} ${SET_LOCALE}.UTF-8
    sudo update-locale LC_ALL=${SET_LOCALE}.UTF-8 LANG=${SET_LOCALE}.UTF-8
    export LANG=${SET_LOCALE}.UTF-8
fi
###############################################################################

###############################################################################
#Find HW type x86_64 or imx8 only supported in script currently.
HW_TYPE=$(dpkg --print-architecture)

if [ -f /proc/device-tree/model ]; then

    if grep -q MX8 /proc/device-tree/model; then
        echo "System is an IMX8, updating hardware target build parameters"
        HW_TYPE="imx8"
    fi
fi

sudo apt-get -y install curl gnupg gnupg2 lsb-release
catch_errors

if [ ! -f /usr/share/keyrings/ros-archive-keyring.gpg ]; then
    # Add ROS2 apt key
    sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
    catch_errors
fi
if [ ! -f /etc/apt/sources.list.d/ros2.list ]; then    
    # Add ROS2 sources list
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
    catch_errors
fi

# Update apt to bring in ROS2 repos
sudo apt update
catch_errors

sudo apt-get install -y \
    input-utils \
    libspnav-dev  \
    libbluetooth-dev  \
    libcwiid-dev \
    jstest-gtk \
    bash-completion \
    build-essential \
    cmake \
    git \
    ccache \
    pkg-config \
    python3-colcon-common-extensions \
    python3-flake8 \
    python3-pip \
    python3-dev \
    python3-pytest-cov \
    python3-rosdep \
    python3-setuptools \
    python3-vcstool \
    python3-argcomplete \
    python3-empy \
    python3-jinja2 \
    python3-cerberus \
    python3-coverage \
    python3-matplotlib \
    python3-numpy \
    python3-packaging \
    python3-pkgconfig \
    python3-opencv \
    python3-wheel \
    python3-requests \
    python3-serial \
    python3-six \
    python3-toml \
    python3-psutil \
    python3-pysolar \
    g++ \
    gcc \
    gdb \
    ninja-build \
    make \
    bzip2 \
    zip \
    rsync \
    shellcheck \
    tzdata \
    unzip \
    valgrind \
    xsltproc \
    binutils \
    bc \
    libyaml-cpp-dev \
    autoconf \
    automake \
    bison \
    ca-certificates \
    openssh-client \
    cppcheck \
    dirmngr \
    doxygen \
    file \
    gosu \
    lcov \
    libfreetype6-dev \
    libgtest-dev \
    libpng-dev \
    libssl-dev \
    libopencv-dev \
    flex \
    genromfs \
    gperf \
    libncurses-dev \
    libtool \
    uncrustify \
    vim-common \
    libxml2-utils \
    mesa-utils \
    libeigen3-dev \
    protobuf-compiler \
    libimage-exiftool-perl \
    ros-galactic-desktop \
    ros-galactic-cv-bridge \
    ros-galactic-image-tools \
    ros-galactic-image-transport \
    ros-galactic-image-transport-plugins \
    ros-galactic-image-pipeline \
    ros-galactic-camera-calibration-parsers \
    ros-galactic-camera-info-manager \
    ros-galactic-launch-testing-ament-cmake \
    ros-galactic-vision-opencv \
    ros-galactic-*msg*

# Install Python 3 pip build dependencies first.
python3 -m pip install --upgrade pip wheel setuptools
catch_errors

python3 -m pip install -U \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-docstrings \
    flake8-import-order \
    flake8-quotes \
    pytest-repeat \
    pytest-rerunfailures \
    pytest

# Source ROS2
source /opt/ros/galactic/setup.bash
catch_errors

# Add user to groups for external controller inputs
sudo adduser $USER plugdev input

if [ ${HW_TYPE} = "amd64" ]; then
    if [ ! -f /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg ]; then
        # Add Gazebo Ignition key
        sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg
        catch_errors
    fi
    if [ ! -f /etc/apt/sources.list.d/gazebo-stable.list ]; then
        # Add Gazebo Ignition sources list
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null
        catch_errors
    fi

    # Update apt to bring in IGN repos
    sudo apt update
    catch_errors

    sudo apt-get -y install \
        xterm \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-ugly \
        libgstreamer-plugins-base1.0-dev \
        x-window-system \
        xvfb \
        geographiclib-tools \
        libgeographic-dev \
        ignition-edifice \
        ros-galactic-ros-ign

    catch_errors

    # Install geographiclib geoids for ??
    sudo geographiclib-get-geoids egm96-5
    catch_errors

    # Not sure why this is here. Gonna just leave it be
    sudo apt-get -y autoremove
    catch_errors
fi

# Check to see if things are already sourced... this script may fail and then be run again by the user.
if ! grep -q "source /opt/ros/galactic/setup.bash" "/home/$USER/.bashrc"; then
    echo 'source /opt/ros/galactic/setup.bash' >> ~/.bashrc
fi

if ! grep -q "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" "/home/$USER/.bashrc"; then
    echo 'source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash' >> ~/.bashrc
fi

source ~/.bashrc

echo '\n----------------------------------------'
echo 'DONE! Ready to configure ROS2 workspace!'
echo '----------------------------------------'
