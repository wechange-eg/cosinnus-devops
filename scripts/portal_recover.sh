#!/bin/bash
source .env

# Get parameters
read -p "SSH user (e.g. wechange@wechange.de): " user
portal_user=`echo "${user%@*}"`
portal_url=`echo "${user#*@}"`
read -p "URL of new GitLab repository (e.g. git@git.sinnwerkstatt.com:wechange/wechange.git): " repo

# Clone repo
echo -n -e "\rClone GitLab repo... "
ssh ${user} "git clone ${repo} htdocs"
echo -e "done"

# Create virtualenv
echo -n -e "\rCreate virtualenv... "
ssh ${user} 'virtualenv -p /usr/bin/python3 venv'
echo -e "done"

# Install requirements
echo -n -e "\rInstall requirements... "
ssh ${user} 'venv/bin/pip install -r htdocs/requirements-production.txt'
echo -e "done"

# Compile webpack
echo -n -e "\rCompile webpack... "
  ssh ${user} "cd venv/src/cosinnus/;npm install;npm run production;"
echo -e "done"

# Collectstatic
echo -n -e "\rCollect static files... "
ssh ${user} "venv/bin/python htdocs/manage.py collectstatic --noinput"
echo -e "done"

# Compile less
echo -n -e "\rCompile less... "
ssh ${user} 'cd venv/src/cosinnus;npm install lessc clean-css'
ssh ${user} 'venv/src/cosinnus/node_modules/.bin/lessc --clean-css htdocs/static-collected/less/cosinnus.less htdocs/static-collected/css/cosinnus.cssvenv/src/cosinnus/node_modules/.bin/lessc --clean-css htdocs/static-collected/less/cosinnus.less htdocs/static-collected/css/cosinnus.css'
ssh ${user} "chown -R ${portal_user}:www-data htdocs/static-collected"
echo -e "done"

# Create media folder
echo -n -e "\rCreate media folder... "
ssh ${user} "mkdir htdocs/media;chown -R ${portal_user}:www-data htdocs/media"
echo -e "done"
