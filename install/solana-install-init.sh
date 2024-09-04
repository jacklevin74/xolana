#!/bin/bash

{ # this ensures the entire script is downloaded #

RELEASE="${VARIABLE:-xolana}"
GH_LATEST_TARBALL="https://api.github.com/repos/jacklevin74/xolana/tarball/$RELEASE"
INSTALL_DIR="$HOME/.local/share/xolana/releases/$RELEASE"

set -e
sudo_cmd=$(which sudo &>/dev/null || true)

# Install dependencies
printf "\nInstalling dependencies\n\n"
if [[ "$OSTYPE" == "linux-gnu"* ]] && command -v apt &> /dev/null; then
	echo "Installing dependencies for apt package manager. You may need to enter your password."
	$sudo_cmd apt update
	$sudo_cmd apt -y install \
                build-essential \
                pkg-config \
                libudev-dev \
                llvm \
                libclang-dev \
                curl \
                protobuf-compiler

elif [[ "$OSTYPE" == "linux-gnu"* ]] && command -v yum &> /dev/null; then
	echo "Installing dependencies for yum package manager. You may need to enter your password."
	$sudo_cmd yum install -y \
								perl \
								clang-devel \
								pkg-config \
								libudev-devel \
								openssl \
								openssl-devel \
								curl \
								protobuf-compiler

elif command -v brew &> /dev/null; then
	brew install pkg-config protobuf llvm coreutils

else
	echo "Could not find package manager to install dependencies (yum, apt, brew). Please install: pkg-config, libssl-dev, protobuf, llvm, coreutils"
	exit 1
fi

# Install Rustup
printf "\nInstalling Rustup\n\n"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"

# Download Xolana
printf "\nDownloading Xolana's source from $GH_LATEST_TARBALL\n\n"
mkdir -p $INSTALL_DIR
curl -L "$GH_LATEST_TARBALL" | tar xz --strip-components=1 -C $INSTALL_DIR

# Build Xolana
printf "\nBuilding Xolana: $INSTALL_DIR\n\n"
cd $INSTALL_DIR
cargo build --release

printf "\nXolana has been built successfully\n\n"
echo "Before running Xolana, you need to add the binaries to your PATH. You can do this by running the following command:"
echo "export PATH=$INSTALL_DIR/target/release:\$PATH"
echo
echo "To permanently add the binaries to your PATH, you need to add the following line to your shell rc file. (~/.bashrc, ~/.zshrc, etc.)"
echo "export PATH=$INSTALL_DIR/target/release:\$PATH"
echo

} # this ensures the entire script is downloaded #
