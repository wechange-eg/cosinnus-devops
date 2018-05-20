# -*- coding: utf-8 -*-

#from __future__ import unicode_literals
# we cannot use unicode_literals here, or smtplib will crash, expecting a str when reading the secret key

from .default_settings import *
import dj_database_url

# change this in production!
ALLOWED_HOSTS = ['*']

DATABASES['default'] = dj_database_url.config(conn_max_age=600)
if not DATABASES['default']:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': 'postgres',
            'USER': 'postgres',
            #'PASSWORD': '',
            'HOST': 'db',
            'PORT': '',
        }
    }

ADMINS = (
)
MANAGERS = ADMINS

DEBUG = True  # <<<<< SET TO `False` ON staging AND production
# extra-aggressive Exception raising, disable this for any environment other than local!
DEBUG_LOCAL = True
# convenience switch for debugging with django-debug-toolbar
DEBUG_TOOLBAR_ENABLED = False

TEMPLATES[0]['OPTIONS']['debug'] = DEBUG
THUMBNAIL_DEBUG = DEBUG


if DEBUG:
    del LOGGING

### !!! WARNING !!! CHANGE THIS IN THE PRODUCTION ENVIRONMENT
SECRET_KEY = 'TODO:key' # needs to be set in local settings.py

COSINNUS_ETHERPAD_BASE_URL = 'https://pad.yourserver.com'
COSINNUS_ETHERPAD_API_KEY = ''  # needs to be set in local settings.py

COSINNUS_ETHERPAD_ENABLE_ETHERCALC = True
COSINNUS_ETHERPAD_ETHERCALC_BASE_URL = 'https://calc.yourserver.com'
COSINNUS_ETHERPAD_ETHERCALC_API_KEY = ''  # needs to be set in local settings.py


# recaptcha
RECAPTCHA_PUBLIC_KEY = ''  # needs to be set in local settings.py
RECAPTCHA_PRIVATE_KEY = ''  # needs to be set in local settings.py

# note: this will use the most basic, in-memory haystack backend that gives no useful search results
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'haystack.backends.simple_backend.SimpleEngine',
    },
}
# enable this haystack setting if you have actually set up elastic search on your system
"""
HAYSTACK_CONNECTIONS = {
    'default': {
        'ENGINE': 'cosinnus.backends.RobustElasticSearchEngine',  # replaces 'haystack.backends.elasticsearch_backend.ElasticsearchSearchEngine',
        'URL': 'http://127.0.0.1:9200/',
        'INDEX_NAME': 'wechange',
    },
}
"""

# save mail as local text files
# remove this for production!
EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
EMAIL_FILE_PATH = 'mail_local' # change this to a proper location or mkdir


""" ---------------- MISC SETTINGS ------------------- """

if DEBUG_TOOLBAR_ENABLED:

    INSTALLED_APPS = INSTALLED_APPS + [
        'django_extensions',
        'debug_toolbar',
        'werkzeug_debugger_runserver',
    ]
    
    INTERNAL_IPS = ['127.0.0.1']
    DEBUG_TOOLBAR_PATCH_SETTINGS = False
    MIDDLEWARE_CLASSES = (
        'debug_toolbar.middleware.DebugToolbarMiddleware',
    ) + MIDDLEWARE_CLASSES
    DEBUG_TOOLBAR_PANELS = [
        'debug_toolbar.panels.versions.VersionsPanel',
        'debug_toolbar.panels.timer.TimerPanel',
        'debug_toolbar.panels.settings.SettingsPanel',
        'debug_toolbar.panels.headers.HeadersPanel',
        'debug_toolbar.panels.request.RequestPanel',
        'debug_toolbar.panels.sql.SQLPanel',
        'debug_toolbar.panels.staticfiles.StaticFilesPanel',
        'debug_toolbar.panels.templates.TemplatesPanel',
        'debug_toolbar.panels.cache.CachePanel',
        'debug_toolbar.panels.signals.SignalsPanel',
        'debug_toolbar.panels.logging.LoggingPanel',
        'debug_toolbar.panels.redirects.RedirectsPanel',
        #'haystack.panels.HaystackDebugPanel',
    ]


""" --------------- COSINNUS SETTINGS ---------------- """

COSINNUS_SITE_PROTOCOL = 'http'

# this links the django instance running on this settings module to the portal:
SITE_ID = 1

