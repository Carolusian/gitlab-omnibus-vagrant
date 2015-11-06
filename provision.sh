#!/bin/bash

# Get ip and hostname from config.yml
ip=$1
hostname=$2

# run as root
sudo apt-get update -y
sudo apt-get upgrade -y

# Set vim as default editor
sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic

sudo debconf-set-selections <<< "postfix postfix/mailname string $hostname"
sudo debconf-set-selections <<< "postfix postfix/main_mailer_type string string 'Internet Site'"
sudo apt-get install curl openssh-server ca-certificates postfix | 
curl -LJO "https://packages.gitlab.com/gitlab/gitlab-ce/packages/ubuntu/trusty/gitlab-ce_8.1.3-ce.0_amd64.deb/download"
sudo dpkg -i gitlab-ce_8.1.3-ce.0_amd64.deb

sudo gitlab-ctl reconfigure
sudo gitlab-ctl stop
sudo gitlab-ctl start
sudo gitlab-ctl reconfigure
sudo gitlab-ctl stop

sudo echo "gitlab_rails['gitlab_email_from'] = 'git@$hostname'" >> /etc/gitlab/gitlab.rb
sudo echo "gitlab_rails['gitlab_email_display_name'] = 'GitLab'" >> /etc/gitlab/gitlab.rb
sudo echo "gitlab_rails['gitlab_email_reply_to'] = 'noreply@$hostname'" >> /etc/gitlab/gitlab.rb

sudo gitlab-ctl start

# =====================
# root login: root/5iveL!fe

# TODO: checkout hostname settings and secret.yml settings
