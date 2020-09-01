#!/bin/bash
source .env

update_env() {
  sed -i "" -e "s/$1=.*/$1=$2/g" \.env
}

# Get parameters
read -p "Fork new GitLab repository [$HISTORY_CREATE_REPO]: " create_repo
create_repo=${create_repo:-$HISTORY_CREATE_REPO}
update_env "HISTORY_CREATE_REPO" $create_repo
if [[ "$create_repo" =~ [Yy] ]]
then
  read -p "Name of new GitLab repository [$HISTORY_REPO]: " repo
else
  read -p "Name of existing GitLab repository [$HISTORY_REPO]: " repo
fi
repo=`echo "${repo}" | tr '[A-Z]' '[a-z]' | sed 's/[[:blank:]]//g'`
repo=${repo:-$HISTORY_REPO}
update_env "HISTORY_REPO" $repo

read -p "Portal name [$HISTORY_PORTAL_NAME]: " portal_name
portal_name=${portal_name:-$HISTORY_PORTAL_NAME}
update_env "HISTORY_PORTAL_NAME" "\"$portal_name\""

read -p "SSH user [$HISTORY_USER]: " user
user=${user:-$HISTORY_USER}
update_env "HISTORY_USER" $user

read -p "Email address [$HISTORY_EMAIL]: " email
email=${email:-$HISTORY_EMAIL}
update_env "HISTORY_EMAIL" $email

read -p "Matomo Site ID (from stats.wechange.de) [$HISTORY_MATOMO_SITE_ID]: " matomo_site_id
matomo_site_id=${matomo_site_id:-$HISTORY_MATOMO_SITE_ID}
update_env "HISTORY_MATOMO_SITE_ID" $matomo_site_id

# read -p "Rocket.Chat user (e.g. plattformn-bot): " rocket_user
# read -p "Rocket.Chat password: " rocket_password

if [[ "$create_repo" =~ [Yy] ]]
then
  # Fork template repo
  echo -n -e "\rFork template repo... "
  project_id=`curl --request POST --silent --header "PRIVATE-TOKEN: ${ACCESS_TOKEN}" --header "Content-Type: application/json" \
  --data "{\"name\": \"${repo}\", \"path\": \"${repo}\", \"namespace_id\": ${NAMESPACE_ID}, \"namespace_path\": \"${NAMESPACE_PATH}\"}" \
  "${API_URL}/projects/${TEMPLATE_ID}/fork" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin)['id'])
except:
    print(0)
"`
  if [[ $project_id -eq 0 ]]
  then
    echo -e "failed (name already taken?)"
    exit
  else
    echo -e "done"
  fi
else
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
  if [[ default_project_id -eq 0 ]]
  then
    echo -e "failed (name not found)"
    exit
  else
    echo -e "done"
  fi

  read -p "GitLab project ID [$default_project_id]: " project_id
  project_id=${project_id:-$default_project_id}
fi

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
portal_user=`echo "${user%@*}"`
portal_url=`echo "${user#*@}"`
db_password=`ssh ${user} 'cat .pgpass | sed "s/.*\://"'`
secret_key=`cat /dev/urandom | env LC_CTYPE=C tr -dc a-zA-Z0-9 | head -c 64; echo`
broker_port=`ssh ${user} 'echo \`find .. -maxdepth 1 -type d | wc -l\`-1 | bc'`
broker_port=$(expr $broker_port + 4)
ssh ${user} "git clone ${CLONE_URL}/$repo htdocs"
ssh ${user} "chown -R $portal_user:www-data htdocs"
ssh ${user} "cp htdocs/wechange/settings.py.dist htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/COSINNUS_PORTAL_NAME = '<salt-managed>'/COSINNUS_PORTAL_NAME = '${repo}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/COSINNUS_PORTAL_URL = '<salt-managed>'/COSINNUS_PORTAL_URL = '${portal_url}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/COSINNUS_BASE_PAGE_TITLE_TRANS = '<salt-managed>'/COSINNUS_BASE_PAGE_TITLE_TRANS = '${portal_name}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/'PASSWORD': '<salt-managed>'/'PASSWORD': '${db_password}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/COSINNUS_ETHERPAD_API_KEY = '<salt-managed>'/COSINNUS_ETHERPAD_API_KEY = '${ETHERPAD_API_KEY}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/COSINNUS_DEFAULT_FROM_EMAIL = '<salt-managed>'/COSINNUS_DEFAULT_FROM_EMAIL = '${email}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/SECRET_KEY = '<salt-managed>'/SECRET_KEY = '${secret_key}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/BROKER_URL = 'redis:\/\/localhost:6379\/%d' % <salt-managed>/BROKER_URL = 'redis:\/\/localhost:6379\/%d' % ${broker_port}/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/PIWIK_SITE_ID = <salt-managed>/PIWIK_SITE_ID = ${matomo_site_id}/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/EMAIL_HOST = '<salt-managed>'/EMAIL_HOST = '${EMAIL_HOST}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/EMAIL_HOST_USER = '<salt-managed>'/EMAIL_HOST_USER = '${EMAIL_HOST_USER}'/g\" htdocs/wechange/settings.py"
ssh ${user} "sed -i \"s/EMAIL_HOST_PASSWORD = '<salt-managed>'/EMAIL_HOST_PASSWORD = '${EMAIL_HOST_PASSWORD}'/g\" htdocs/wechange/settings.py"
# ssh ${user} "sed -i \"s/COSINNUS_CHAT_USER = '<salt-managed>'/COSINNUS_CHAT_USER = '${rocket_user}'/g\" htdocs/wechange/settings.py"
# ssh ${user} "sed -i \"s/COSINNUS_CHAT_PASSWORD = '<salt-managed>'/COSINNUS_CHAT_PASSWORD = '${rocket_password}'/g\" htdocs/wechange/settings.py"
echo -e "done"

# Create virtualenv
echo -n -e "\rCreate virtualenv... "
ssh ${user} 'virtualenv -p /usr/bin/python3 venv'
echo -e "done"

# Install requirements
echo -n -e "\rInstall requirements... "
ssh ${user} 'venv/bin/pip install -r htdocs/requirements-production.txt'
echo -e "done"

# Migrate database
echo -n -e "\rMigrate database... "
ssh ${user} 'venv/bin/python htdocs/manage.py migrate'
echo -e "done"

# Create superuser
echo -n -e "\rCreate superuser... "
ssh ${user} "venv/bin/python htdocs/manage.py shell -c \"from django.contrib.auth.models import User; User.objects.create_superuser('${SUPERUSER_EMAIL}', '${SUPERUSER_EMAIL}', '${SUPERUSER_PASSWORD}')\""
echo -e "done"

# Update site
echo -n -e "\rUpdate site... "
ssh ${user} "venv/bin/python htdocs/manage.py shell -c \"from django.contrib.sites.models import Site;site = Site.objects.update(domain='${portal_url}', name='${portal_url}');\""
echo -e "done"

# Update portal
echo -n -e "\rUpdate portal... "
ssh ${user} "venv/bin/python htdocs/manage.py shell -c \"from cosinnus.models import CosinnusPortal;p = CosinnusPortal.objects.first();p.slug = '${repo}';p.name = '${portal_name}';p.save();\""
echo -e "done"

# Create forum group
echo -n -e "\rCreate forum... "
ssh ${user} "venv/bin/python htdocs/manage.py shell -c \"from cosinnus.models.group_extra import CosinnusSociety;CosinnusSociety.objects.create(slug='forum', name='Forum', public=True);\""
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

# Create oauth app within Rocket.Chat
# echo -n -e "\rCreate oauth2 connection for Rocket.Chat and sync settings/users/groups..."
# ssh ${user} "venv/bin/python htdocs/manage.py rocket_sync_settings"
# ssh ${user} "venv/bin/python htdocs/manage.py rocket_sync_users"
# ssh ${user} "venv/bin/python htdocs/manage.py rocket_sync_groups"tel
# echo -e "done"

# Restart service
echo -n -e "\rRestart service... "
ssh ${user} "chown ${portal_user}:www-data ."
ssh ${user} "sudo /bin/systemctl restart django-${portal_user}.service"
echo -e "done"
