#!/bin/bash

if grep -qiE 'debian|ubuntu' /etc/os-release && [ "$(dpkg --print-architecture 2>/dev/null)" = "amd64" ]; then
    apt install wget git make tar -y

    wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz

    tar -xvf go1.24.4.linux-amd64.tar.gz

    rm go1.24.4.linux-amd64.tar.gz

    mv ./go /usr/local/

    export PATH=$PATH:/usr/local/go/bin

    git clone https://github.com/MeshManager/MeshManagerAgent.git

    cd ./MeshManagerAgent/

    make install
else
    echo "이 스크립트는 Debian 계열 amd64 시스템에서만 동작합니다."
    exit 1
fi