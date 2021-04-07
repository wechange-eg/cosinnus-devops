wechange
=========================

This is the base project for wechange. It is mainly a configurable shell for the actual wechange apps, which are pluggable components. Most of the actual code resides in "cosinnus-core". See `requirements_staging.txt` for a full list of internal apps.

Note: The wechange project is often refered to as "neww" in code and imports and the internal apps and python Objects are named "cosinnus" for historical reasons. 

# Option A: Setup local development with Docker

    git submodule init
    git submodule update
    docker-compose up

# Option B: Setup local development manually

This will set up a local development environment, getting you ready to work on wechange and all its internal apps.


### Install PostgresSql 
#### Note: this step is necessary!

* Install PostgreSql for your system 
* Create new psql database. Name it "wechange" or similar and note its password and user
  * You can use the root psql user, but we advise you to use a different one

### Install the GDAL library

* Install GDAL for your system (https://docs.djangoproject.com/en/2.1/ref/contrib/gis/install/geolibs/)
* For macOS, use `brew install gdal`

  
### Install Python, Pip and Virtualenv
 
* Install python 3.6.6 or higher. Please refer to external guides if you are unsure how to do this for your system!
* `pip install --upgrade pip` - Upgrade pip. Don't skip this step!
* `pip install virtualenv` - Install virtualenv

### Install Git

* Install a git client. Please refer to external guides if you are unsure how to do this for your system!

### Create a virtualenv and project folders
 
* `virtualenv <your-path>/wechangeenv` - Create your virtualenv once
* `source <your-path>/wechangeenv/bin/activate` - Activate your wechange virtualenv (do this in every new console when working on wechange)
* `mkdir <your-project-folder>/wechange-source` - Create the new wechange project location
* `cd <your-project-folder>/wechange-source`

### Get the cosinnus-devops and cosinnus source code

* `git clone git@github.com:wechange-eg/cosinnus-devops.git cosinnus-devops`
* `cd cosinnus-devops/devops` - Get into the devops folder and initiate subfolders
* `git submodule init`
* `git submodule update`
  * Since cosinnus-devops is not updated regularly, the submodules are probably pointing to old commits. Make sure to check and pull the current master branch for each submodule. 

### Set up the local wechange source and install all dependencies
*  Get back to the cosinnus-devops folder
* `./cosinnus-devops/local_setup.sh`
  * This sets up all of the cosinnus-projects into individual folders and runs "python setup.py develop". This means that the source of the cosinnus dependency is localized in the same directory, and you can edit the files in there as if it were a source directory.
  * Check the `setup.log` log output and make sure that each individual call resulted in a successfull install, and did not stop with an error. If there are any errors in any of the calls, you need to resolve them and run `local_setup.sh` again untill all of them complete successfully!
  * If any errors because of dependency conflicts happen, some older dependencies may have problems, that we haven't ironed out recently. In this case, the easiest way to go is to temporarily comment out *all* the entries in the `install_requires=[...]` array in the `setup.py` file of the offending cosinnus subdirectory to complete the script. This is okay since all requirements will be properly installed through the requirements file in the next step.
* `pip install -r ./cosinnus-devops/requirements_local.txt`
  
**Notes:** 

* For wechange, we install the full set of dependencies via requirements.txt files. These are also used during our deployment and there are different files for local, staging and production environments.
* We tee the stdout so you can see errors more clearly.
* Deal with any errors you encounter here! Only move to the next step if you do not get any errors. Warnings are usually ok.
  * Especially Pillow and some other dependencies are known to cause trouble on some systems! 
  * if you see any compile errors, often time the solution is to install the offending dependency using a pip Wheel for your system.

### Configure up your local wechange projects

* `cd cosinnus-devops`
* `cp devops/settings_local.py devops/settings.py`
* Edit `devops/settings.py`:
  * Replace the database settings in ``DATABASES['default']``: 
    * NAME, USER, PASSWORD: based on how you created your psql database
  * (this settings.py file is in .gitignore)

### One-Time Django Setup 
  
* `./manage.py migrate` - Creates all the empty database tables
* `./manage.py createsuperuser` - Creates your own user account
  * Enter the credentials for your local user
  * The username doesn't matter, you will log in using the email as credential

### First-Time Wechange Setup

* `./manage.py runserver` - Runs the server
* Navigate to `http://localhost:8000/admin` and log in with the email address and password you just created
  * Navigate to `http://localhost:8000/admin/sites/site/1/` and change the default Site to 
    * domain: localhost:8000
    * name: Local Site (or anything you wish)
* Restart the server using "ctrl+c" and `./manage.py runserver`

### Compile the JS client using webpack

This will compile the `client.js` JS client, which is used for the Map/Tile View and the v2 User Dashboard and Navbar. After setting up your environment, you need to do this at least once.

* Install npm for your OS (https://nodejs.org/en/download/)
* In a new terminal, cd to your `cosinnus-core` source directory
* Run `npm install`
* Run `npm run dev`. You can leave this running to automatically recompile the client on any changes, or just quit the watcher process after compilation is complete.


### Install Elasticsearch on your system

If you are not planning to work with the map or “search” you can skip this step, otherwise it is required.

* Install and run Elasticsearch 1.3.9 (https://www.elastic.co/downloads/elasticsearch)
  * Using docker:
     * From `cosinnus-devops/elasticsearch-1.3.9-docker/` run `docker-compose up -d`
  * (Alternative) For macOS without docker: 
    * `brew tap elastic/tap`
    * `brew install elastic/tap/elasticsearch-full`
* Switch between haystack settings in the settings.py file by changing the comment section:

```
    """
    HAYSTACK_CONNECTIONS = {
        'default': {
            'ENGINE': 'haystack.backends.simple_backend.SimpleEngine',
        },
    }
    """
    # enable this haystack setting if you have actually set up elastic search on your system

    HAYSTACK_CONNECTIONS = {
        'default': {
            'ENGINE': 'cosinnus.backends.RobustElasticSearchEngine',  # replaces 'haystack.backends.elasticsearch_backend.ElasticsearchSearchEngine',
            'URL': 'http://127.0.0.1:9200/',
            'INDEX_NAME': 'wechange',
        },
    }
```

* Make sure elastic search is running, if not: run it.

### First-Time Wagtail Setup (no longer recommended)

This is an optional step for your your local environment. If you choose not to do this, your root URL will stay blank, but all other URLs will work fine.

We use Wagtail as CMS, and it will show up automatically as a root URL dashboard. You can skip this step configuring it, but all you will see on your root URL will be a blank page. Navigate to a page like `http://localhost:8000/projects/` to see the wechange-page.

* Navigate to `http://localhost:8000/cms-admin/pages/`
  * Delete the page "Welcome to your new Wagtail Site"
  * Create new Subpage on the root level
    * Tab Inhalt (de): Title: enter "Root"
    * Tab Förderung: Kurtitel (slug): enter "root"
    * Tab Einstellungen: Portal: choose "Default Portal"
    * Below in the drop-up: Click "Publish"
  * Hover over the new "Root" page and click "Add new Subpage"
    * Choose "Start-Page: Modular"
    * Tab Inhalt (de): Title: enter "Dashboard"
    * Tab Förderung: Kurtitel (slug): enter "dashboard"
    * Below in the drop-up: Click "Publish"
  * In the left side menu, go to Settings > Sites
    * Click "Add Site"
    * Hostname: localhost:8000
    * Port: 8000
    * Click Choose Origin Site:
      * Navigate below Root using ">", choose page "Dashboard"
    * Check "Default Site" on
    * Click "Save"
* Navigate to `http://localhost:8000/`, you should see the blank CMS dashboard. 
  * Its content can be edited in the "Dashboard" Page you just created in http://localhost:8000/cms-admin/pages/. 


### Check if you're up-and-running and create the Forum Group

* Navigate to `http://localhost:8000/groups/`
* Click "Create Group" in the left sidebar
  * Enter Group Name: "Forum" (must be exact!)
  * Click "Save" below
* If you get redirected to the Forum's Group Dashboard and "Forum" appears in the top navigation bar, you're all set!

## (Alternative) Using MariaDB instead of Postgres

To use MariaDB instead of Postgres locally, you will need to modify the following migrations files

* cosinnus-core/cosinnus/migrations/0048_auto_20190529_1505.py
* cosinnus-event/cosinnus_event/migrations/0010_auto_20190714_1755.py

In both, replace 

`django.contrib.postgres.fields.jsonb.JSONField`

with 

`django_mysql.models.JSONField`


# Git Structure

Cosinnus-devops pulls Cosinnus-core and all cosinnus apps in directly from their Git repositories. See `requirements_staging.txt` for the repo locations and used branches.

# Testing Subportals

WECHANGE supports sub-portals that share the same database and can display the contents of other portals in the same "pool" in searches and map views. For this, create a new CosinnusPortal in the django admin, enter its portal name, site-id and settings in config_subportal.py.

Run the new portal using `./manage.py --cosinnus-portal <portalname>`.

For multiple subportals, duplicate the `wsgi_subportal.py` and `config_subportal.py`. 

# Acknowledgements

wechange uses the Browserstack Testing Suite for Browser Testing.

<a href="https://www.browserstack.com" target="_blank"><img src="https://wechange.de/static/img/browserstack-logo.png" alt="BrowserStack" width=200/></a>
