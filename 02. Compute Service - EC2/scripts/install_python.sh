#!/bin/bash

# Python 3.11 설치 스크립트
echo "#####################"
echo "Python 3.11 설치 시작"
echo "#####################"
sudo dnf install python3.11 -y

echo "##############################"
echo "Python Default Version Setting"
echo "update-alternatives 명령 실행."
echo "##############################"
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 2
echo 2 | sudo update-alternatives --config python3


echo "################################"
echo "Python 3.11 PIP Module 설치 시작"
echo "################################"
sudo python3 -m ensurepip --default-pip

echo "##############################"
echo "Python3 → Python Symbolic link"
echo "##############################"
echo "sudo ln -fs /usr/bin/python3.11 /usr/bin/python"
sudo ln -fs /usr/bin/python3.11 /usr/bin/python

echo "#######################"
echo "Python 3.11 설치 완료"
echo "설치된 Python 버전 정보"
echo "#######################"
python --version

echo "#####################################"
echo "dnf/yum에서 사용하는 Python 버전 지정"
echo "#####################################"
head -1 /usr/bin/dnf
sudo sed -i 's|#!/usr/bin/python3|#!/usr/bin/python3.9|g' /usr/bin/dnf
sudo sed -i 's|#!/usr/bin/python3|#!/usr/bin/python3.9|g' /usr/bin/yum
head -1 /usr/bin/dnf
sudo dnf --version

echo "################"
echo "PIP Upgrade 설치"
echo "################"
sudo python3 -m pip install --upgrade pip

echo "################"
echo "Stress Tool 설치"
echo "################"
sudo dnf install stress -y

echo "##################"
echo "Git & Code Install"
echo "##################"
cd /root/
sudo yum install git -y
sudo git clone https://github.com/CJ-CloudWave-Public-Hands-on-Lab/streamlit-project.git

echo "######################"
echo "Python Package Install"
echo "######################"
cd streamlit-project
pip install -r requirements.txt

echo "##############"
echo "Upgrade AWSCLI"
echo "##############"
sudo sh scripts/upgrade_aws_cli_v2.sh

echo "#################"
echo "Application Start"
echo "#################"
# streamlit run main.py --server.port 8080 --server.enableCORS false --server.enableXsrfProtection false --server.enableWebsocketCompression=false
streamlit run main.py --server.port 80