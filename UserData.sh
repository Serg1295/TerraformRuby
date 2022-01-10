#!/usr/bin/bash
sudo apt-get update
sudo apt-get install curl -y
sudo apt install gnupg -y
curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | sudo gpg --import -
curl -sSL https://get.rvm.io | sudo bash -s stable
source /etc/profile.d/rvm.sh
rvm user all
rvm requirements
rvm install ruby-2.6.6
rvm use 2.6.6 --default
gem install rails --version=5.2.6
bundle install
sudo apt install nodejs -y