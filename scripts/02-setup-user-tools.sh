#!/usr/bin/env bash

# This script installs CAN related tools only
# Assumes 01-bootstrat.sh has already executed and all system utilities are installed

# Install tools

sudo apt-get install -y \

HOME_DIR=/home/vagrant
TOOLS_DIR=${HOME_DIR}/tools
CARING_CARIBOU_DIR=${TOOLS_DIR}/caringcaribou
ICSIM_DIR=${TOOLS_DIR}/ICSim
ICSIM_NOUI_DIR=${TOOLS_DIR}/ICSim-noui
UDSIM_DIR=${TOOLS_DIR}/UDSim
KAYAK_DIR=${TOOLS_DIR}/Kayak
SOCKETCAND_DIR=${TOOLS_DIR}/socketcand

pip install \
    python-can

mkdir -p ${TOOLS_DIR}
cd ${TOOLS_DIR}

#
# Clone or update caringcaribou 
#
if [ -d "caringcaribou" ]; then
    cd caringcaribou
    git pull
    cd ..
else
    cd ${TOOLS_DIR}
    git clone https://github.com/CaringCaribou/caringcaribou.git
fi

#
# Clone or update original ICSim 
#
if [ -d "${ICSIM_DIR}" ]; then
    cd ${ICSIM_DIR}
    git pull origin master
else
    cd ${TOOLS_DIR}
    git clone https://github.com/zombieCraig/ICSim.git ${ICSIM_DIR}
fi

#
# Clone and build modified ICSim version which doeesn't include GUI 
# Not starting GUI for both icsim and control at once
# makes the VM not freeze because of running 2 OpenGL windows.
#
if [ -d "${ICSIM_NOUI_DIR}" ]; then
    cd ${ICSIM_NOUI_DIR}
    git checkout support_tui
    git pull origin support_tui
    cd ..
else
    cd ${TOOLS_DIR}
    git clone https://github.com/Grazfather/ICSim.git ${ICSIM_NOUI_DIR}
    cd ${ICSIM_NOUI_DIR}
    git checkout support_tui
fi

# Rebuild ICSim without GUI (see: https://github.com/zombieCraig/ICSim/pull/6)
cd ${ICSIM_NOUI_DIR}
git checkout support_tui
make clean
make all CFLAGS+=-Wno-error=misleading-indentation CFLAGS+=-DDISABLE_SDL=1

# 
# Clone and build UDSim
#
if [ -d "${UDSIM_DIR}" ]; then
    cd ${UDSIM_DIR}
    git pull
else
    cd ${TOOLS_DIR}
    git clone https://github.com/zombieCraig/UDSim.git
fi

cd ${UDSIM_DIR}/src
make clean
make all

# 
# Install Kayak
#
if [ -d "${KAYAK_DIR}" ]; then
    # NOP
else
    cd ${KAYAK_DIR}
    wget http://kayak.2codeornot2code.org/Kayak-1.0-SNAPSHOT-linux.sh
    chmod +x Kayak-1.0-SNAPSHOT-linux.sh
fi

#
# Install metasploit
#
cd ${TOOLS_DIR}
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall
rm msfinstall

# 
# Install and build socketcand
#
if [ -d "${SOCKETCAND_DIR}"]; then 
    cd ${SOCKETCAND_DIR}
    git pull
else
    git clone http://github.com/dschanoeh/socketcand.git ${SOCKETCAND_DIR}
fi

cd ${SOCKETCAND_DIR}
autoconf
./configure
make clean
sudo make install
