wechange
=========================

This is the base project for wechange. It is mainly a configurable shell for the actual wechange apps, which are pluggable components. Most of the actual code resides in "cosinnus-core". See `requirements_staging.txt` for a full list of internal apps.

Note: The wechange project is often refered to as "neww" in code and imports and the internal apps and python Objects are named "cosinnus" for historical reasons. 

# Setup local development with Docker

    git submodule init
    git submodule update
    docker-compose up

# Setup local development manually

This will set up a local development envirenment, getting you ready to work on wechange and all its internal apps.

Note: Wechange still runs on Python 2.7.15 using Django 1.8, but we are in the process of upgrading to Python 3 and Django >= 2.0!


### Install PostgresSql 

* Install PostgreSql for your system 
* Create new psql database. Name it "wechange" or similar and note its password and user
  * you can use the root psql user, but we advise you to use a different one
  
### Install Python, Pip and Virtualenv
 
* Install python 2.7.15. Please refer to external guides if you are unsure how to do this for your system!
  * It is important that the python version is 2.7.15 exactly!
* `pip install --upgrade pip` - Upgrade pip. Don't skip this step!
* `pip install virtualenv` - Install virtualenv

### Install Git

* Install a git client. Please refer to external guides if you are unsure how to do this for your system!

### Create a virtualenv and project folders
 
* `virtualenv <your-path>/wechangeenv` - create your virtualenv once
* `source <your-path>/wechangeenv/bin/activate` - activate your wechange virtualenv (do this in every new console when working on wechange)
* `mkdir <your-project-folder>/wechange-source` - create the new wechange project location
* `cd <your-project-folder>/wechange-source`

### Get the cosinnus-devops and cosinnus source code

* `git clone git@github.com:wechange-eg/cosinnus-devops.git cosinnus-devops`
* `./cosinnus-devops/local_install.sh | tee install.log`

### Set up the local wechange source and install all dependencies

* `./cosinnus-devops/local_setup.sh | tee setup.log`
  * This sets up all of the cosinnus-projects into individual folders and runs "python setup.py develop". This means that the source of the cosinnus dependency is localized in the same directory, and you can edit the files in there as if it were a source directory.
* `pip install -r ./cosinnus-devops/requirements_local.txt | tee reqs.log`
  
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
  * replace the database settings in ``DATABASES['default']``: 
    * NAME, USER, PASSWORD: based on how you created your psql database
  * (this settings.py file is in .gitignore)

### One-Time Django Setup 
  
* `./manage.py migrate` - creates all the empty database tables
* `./manage.py createsuperuser` - create your own user account
  * enter the credentials for your local user
  * the username doesn't matter, you will log in using the email as credential

### First-Time Wechange Setup

* navigate to `http://localhost:8000/admin` and log in with the email address and password you just created
  * navigate to `http://localhost:8000/admin/sites/site/1/` and change the default Site to 
    * domain: localhost:8000
    * name: Local Site (or anything you wish)
* restart the server using "ctrl+c" and `./manage.py runserver`

### First-Time Wagtail Setup

We use Wagtail as CMS, and it will show up automatically as a root URL dashboard. You can skip this step configuring it, but all you will see on your root URL will be a blank page. Navigate to a page like `http://localhost:8000/projects/` to see the wechange-page.

* navigate to `http://localhost:8000/cms-admin/pages/`
  * Delete the page "Welcome to your new Wagtail Site"
  * create new Subpage on the root level
    * Tab Inhalt (de): Title: enter "Root"
    * Tab Förderung: Kurtitel (slug): enter "root"
    * Tab Einstellungen: Portal: choose "Default Portal"
    * below in the drop-up: Click "Publish"
  * Hover over the new "Root" page and click "Add new Subpage"
    * Choose "Start-Page: Modular"
    * Tab Inhalt (de): Title: enter "Dashboard"
    * Tab Förderung: Kurtitel (slug): enter "dashboard"
    * below in the drop-up: Click "Publish"
  * In the left side menu, go to Settings > Sites
    * click "Add Site"
    * Hostname: localhost:8000
    * Port: 8000
    * click Choose Origin Site:
      * Navigate below Root using ">", choose page "Dashboard"
    * Check "Default Site" on
    * click "Save"
* navigate to `http://localhost:8000/`, you should see the blank CMS dashboard. 
  * Its content can be edited in the "Dashboard" Page you just created in http://localhost:8000/cms-admin/pages/. 

### Check if you're up-and-running and create the Forum Group

* navigate to `http://localhost:8000/groups/`
* click "Create Group" in the left sidebar
  * enter Group Name: "Forum" (must be exact!)
  * click "Save" below
* If you get redirected to the Forum's Group Dashboard and "Forum" appears in the top navigation bar, you're all set!


# Git Structure

Cosinnus-devops pulls Cosinnus-core and all cosinnus apps in directly from their Git repositories. See `requirements_staging.txt` for the repo locations and used branches.

# Testing Subportals

WECHANGE supports sub-portals that share the same database and can display the contents of other portals in the same "pool" in searches and map views. For this, create a new CosinnusPortal in the django admin, enter its portal name, site-id and settings in config_subportal.py.

Run the new portal using `./manage.py --cosinnus-portal <portalname>`.

For multiple subportals, duplicate the `wsgi_subportal.py` and `config_subportal.py`. 
