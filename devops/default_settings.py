# -*- coding: utf-8 -*-

from os.path import dirname, join, realpath
from django.conf.global_settings import *

BASE_PATH = realpath(join(dirname(__file__), '..'))

# Absolute filesystem path to the directory that will hold user-uploaded files.
# Example: "/home/media/media.lawrence.com/media/"
MEDIA_ROOT = join(BASE_PATH, 'media')

# this might be overridden in an out settings file to match the cosinnus Portal's static dir
STATIC_ROOT = join(BASE_PATH, 'static-collected')

# Additional locations of static files
STATICFILES_DIRS = (
    # Put strings here, like "/home/html/static" or "C:/www/django/static".
    # Always use forward slashes, even on Windows.
    # Don't forget to use absolute paths, not relative paths.
    join(BASE_PATH, 'static'),
)

LOCALE_PATHS = LOCALE_PATHS + (
    join(BASE_PATH, 'locale'),
)


ROOT_URLCONF = 'devops.urls'

# Python dotted path to the WSGI application used by Django's runserver.
WSGI_APPLICATION = 'devops.wsgi.application'


""" Import django settings from cosinnus-core.
    Override or add to specific settings here! 
"""

INTERNAL_INSTALLED_APPS = [
   'devops',
]

# we dynamically set the installed apps by which cosinnus-apps are found
from cosinnus.default_settings import *
INSTALLED_APPS = compile_installed_apps(internal_apps=INTERNAL_INSTALLED_APPS)

# templates setting is missing base directory. must come after cosinnus.default_settings import!
TEMPLATES[0]['DIRS'] = [join(BASE_PATH, 'templates'),]

# yes, it's dumb, but we need the ids of all integrated Portals in this list, and this needs to
# be set in the default_settings.py so that ALL portals know that
# this setting is overwritten in a seperate file which is imported by ALL portal settings files
try:
    from .settings_all_portals import COSINNUS_INTEGRATED_PORTAL_IDS
except ImportError:
    COSINNUS_INTEGRATED_PORTAL_IDS = []


# If you run into trouble, update your HAYSTACK_CONNECTIONS on your local settings as
# explained on
# http://django-haystack.readthedocs.org/en/latest/tutorial.html#modify-your-settings-py 
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'cosinnus.backends.RobustElasticSearchEngine',  # replaces 'haystack.backends.elasticsearch_backend.ElasticsearchSearchEngine',
        'URL': 'http://127.0.0.1:9200/',
        'INDEX_NAME': 'wechange',
    },
}


# Make this unique, and don't share it with anybody.
SECRET_KEY = None

# recaptcha
RECAPTCHA_PUBLIC_KEY = None  # needs to be set in local settings.py
RECAPTCHA_PRIVATE_KEY = None  # needs to be set in local settings.py
RECAPTCHA_USE_SSL = True

# determines which apps public objects are shown on a microsite
# e.g: ['cosinnus_file', 'cosinnus_event', ]
COSINNUS_MICROSITE_DEFAULT_PUBLIC_APPS = ['cosinnus_file', 'cosinnus_event', 'cosinnus_etherpad', 'cosinnus_poll', 'cosinnus_marketplace',]

COSINNUS_ETHERPAD_ENABLE_ETHERCALC = True
COSINNUS_ETHERPAD_ETHERCALC_BASE_URL = 'https://calc.wachstumswende.de'

# PIWIK site id, if wished
PIWIK_SITE_ID = None # 2

