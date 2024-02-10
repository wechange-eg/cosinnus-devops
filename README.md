# wechange Stack

## Intro

This repo serves as a starting point for initiating a wechange portal. wechange is composed of a frontend, a backend and multiple microservices from third-party providers. Contained within this repository is the necessary configuration for executing all the components on a local machine for development purposes. *This setup is not intended for production use.*

## Setup

### 1. Install dependencies
 * [Docker](https://docs.docker.com/engine/install/)
 * [Docker Compose](https://docs.docker.com/compose/install/)
 * [Tilt](https://docs.tilt.dev/install.html)

### 2. Clone this repo
`git clone git@github.com:wechange-eg/cosinnus-devops.git`

### 3. Clone wechange frontend and backend
```
cd cosinnus-devops/apps
git clone git@git.wechange.de:code/portals/wechange-frontend.git
git clone git@git.wechange.de:code/portals/wechange.git wechange-backend
cd ..
```

### 4. Build and run services
```
tilt up
```

### 5. Access platform

* Main platform (wechange): e. g. http://wechange.localhost/dashboard
* CMS service (wordpress) http://wechange.localhost/ (and http://wechange.localhost/cms/)
* Messaging service (rocketchat): http://chat.wechange.localhost/
* Cloud storage service (nextcloud & collabora): http://cloud.wechange.localhost/
* Document collaboration service (etherpad): http://pad.wechange.localhost/
* Spreadsheet collaboration service (ethercalc): http://calc.wechange.localhost/
