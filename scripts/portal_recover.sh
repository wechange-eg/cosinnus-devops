#!/bin/bash
source .env

update_env() {
  sed -i "" -e "s/$1=.*/$1=$2/g" \.env
}

# Get parameters
read -p "SSH user [$HISTORY_USER]: " user
user=${user:-$HISTORY_USER}
update_env "HISTORY_USER" $user
portal_user=`echo "${user%@*}"`
portal_url=`echo "${user#*@}"`

read -p "Name of existing GitLab repository [$HISTORY_REPO]: " repo
repo=`echo "${repo}" | tr '[A-Z]' '[a-z]' | sed 's/[[:blank:]]//g'`
repo=${repo:-$HISTORY_REPO}
update_env "HISTORY_REPO" $repo

 # Get repo ID
echo -n -e "\rSearch repo ID... "
default_project_id=`curl --request GET --silent --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" --header "Content-Type: application/json" \
  --data "{\"search\": \"${repo}\"}" "${API_URL}/projects?search=${repo}" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin)[0]['id'])
except:
    print(0)
"`
if [[ $default_project_id -eq 0 ]]
then
  echo -e "failed (name not found)"
  exit
else
  echo -e "done"
fi
read -p "GitLab project ID [$default_project_id]: " project_id
project_id=${project_id:-$default_project_id}

read -p "Python version [$HISTORY_PYTHON_VERSION]: " python_version
python_version=${python_version:-$HISTORY_PYTHON_VERSION}
update_env "HISTORY_PYTHON_VERSION" $python_version

# Get deploy key
deploy_key=`ssh ${user} 'cat ~/.ssh/id_ed25519.pub'`

# Add deploy key
echo -n -e "\rAdd deploy key to repo... "
deploy_key_id=`curl --request POST --silent --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" --header "Content-Type: application/json" \
--data "{\"title\": \"${user}\", \"key\": \"${deploy_key}\"}" \
"$API_URL/projects/${project_id}/deploy_keys" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin)['id'])
except:
    raise
"`
if [[ deploy_key_id -eq 0 ]]
then
  echo -e "failed (key already exists?)"
  exit
else
  echo -e "done"
fi

# Deploy to server
echo -n -e "\rDeploy to server... "
ssh ${user} "git clone ${CLONE_URL}/$repo htdocs"
echo -e "done"

# Create pyenv
echo -n -e "\rCreate pyenv... "
ssh ${user} 'git clone https://github.com/pyenv/pyenv.git ~/.pyenv'
ssh ${user} 'git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv'
ssh ${user} "echo 'export PYENV_ROOT=\"\$HOME/.pyenv\"' > ~/.bashrc"
ssh ${user} "echo 'export PATH=\"\$PYENV_ROOT/bin:\$PATH\"' >> ~/.bashrc"
ssh ${user} "pyenv install $python_version"
ssh ${user} "pyenv global $python_version"
echo -e "done"

# Create virtualenv
echo -n -e "\rCreate virtualenv... "
ssh ${user} 'pyenv virtualenv venv'
ssh ${user} 'ln -s ~/.pyenv/versions/venv venv'
echo -e "done"

# Install requirements
echo -n -e "\rInstall requirements... "
ssh ${user} 'venv/bin/pip install --upgrade pip'
ssh ${user} 'venv/bin/pip install -r htdocs/requirements-production.txt'
echo -e "done"

# Compile webpack
echo -n -e "\rCompile webpack... "
ssh ${user} "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash"
# bashrc
# ln -s /srv/etherpad/.nvm/versions/node/v12.18.3/bin/node /usr/bin/nodejs
ssh ${user} "nvm install 12.18.3"
ssh ${user} "cd venv/src/cosinnus/;npm install;npm run production;"
echo -e "done"

# Mount latest backup to recover settings and media files
mnt_path="/tmp/wechange-backup"
bkp_path="${mnt_path}/snapshots/latest/"
bkp_project_path="${bkp_path}/srv/http/${portal_url}/htdocs"
bkp_db_path="${mnt_path}/snapshots/latest/var/dbbackups"
project_path="/srv/http/${portal_url}/htdocs"
echo "Please mount latest backup as root to recover settings and media files:"
echo "---"
echo "Mount backup (root@${portal_url}):"
echo "\$ runrestic shell"
echo "\$ 0 (or 1)"
echo "\$ restic mount ${mnt_path}"
echo "---"
echo "Project settings and media files (new session root@${portal_url}):"
echo "\$ cp ${bkp_project_path}/wechange/settings.py ${project_path}/wechange/"
echo "\$ rsync -az --no-perms --no-owner --no-group ${bkp_project_path}/media/ ${project_path}/media/"
echo "\$ chown $portal_user:www-data ${project_path}"
echo "\$ chown $portal_user:$portal_user ${project_path}/wechange/settings.py"
echo "\$ chown -R $portal_user:www-data ${project_path}/wechange/media"
read -p "Please press return to continue... "

# Collectstatic
echo -n -e "\rCollect static files... "
ssh ${user} "venv/bin/python htdocs/manage.py collectstatic --noinput"
echo -e "done"

# Compile less
echo -n -e "\rCompile less... "
ssh ${user} 'cd venv/src/cosinnus;npm install lessc clean-css'
ssh ${user} 'venv/src/cosinnus/node_modules/.bin/lessc --clean-css htdocs/static-collected/less/cosinnus.less htdocs/static-collected/css/cosinnus.css'
ssh ${user} "chown -R ${portal_user}:www-data htdocs/static-collected"
echo -e "done"

echo "To finish recovering, please proceed with the following steps:"
echo "---"
echo "Letsencrypt (optionally, better use certbot)"
echo "\$ rsync -az --no-perms --no-owner --no-group ${bkp_path}/etc/letsencrypt/ /etc/letsencrypt/"
echo "---"
echo "Databases (this will take a while, e.g. postgres about 2.5h):"
echo "\$ cp ${bkp_path}/etc/salt/grains /etc/salt/grains"
echo "\$ cat ${bak_db_path}/pgbackup.sql | su -u postgres psql"
echo "\$ cat ${bak_db_path}/mysqlbackup.sql | mysql"
echo "---"
echo "Etherpad:"
echo "\$ cp ${bkp_path}/srv/etherpad/current/APIKEY.txt /srv/etherpad/current/APIKEY.txt"
echo "\$ cp ${bkp_path}/srv/etherpad/current/SESSIONKEY.txt /srv/etherpad/current/SESSIONKEY.txt"
echo "\$ su etherpad"
echo "\$ cd /srv/etherpad/current"
echo "\$ bin/run.sh  # required to compile node_modules"
echo "---"
echo "Ethercalc:"
echo "\$ salt-call state.apply ethercalc"
echo "\$ su ethercalc"
echo "\$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash"
echo "\$ nvm install 12.18.3"
echo "\$ npm install ethercalc"
echo "\$ salt-call state.apply ethercalc"
echo "\$ sc ethercalc stop; sc redis-server stop"
echo "\$ cp /var/lib/redis/dump.rdb /var/lib/redis/dump-bkp.rdb"
echo "\$ cp ${bkp_path}/var/lib/redis/dump.rdb /var/lib/redis/"
echo "\$ chown redis:redis /var/lib/redis/dump.rdb"
echo "\$ sc redis-server start; sc ethercalc start"
echo "---"
echo "Elasticsearch:"
echo "\$ wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.3.9.deb"
echo "\$ wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.3.9.deb.sha1.txt"
echo "\$ shasum -a 512 -c elasticsearch-1.3.9.deb.sha1.txt"
echo "\$ dpkg -i elasticsearch-1.3.9.deb"
echo "\$ update-rc.d elasticsearch defaults 95 10"
echo "---"