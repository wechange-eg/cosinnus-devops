# -*- coding: utf-8 -*-

from .settings import *
import django

""" *** These are the most important settings, definitely customise these for your sub-portal *** """

# this links the django instance running on this settings module to the portal:
SITE_ID = 2
# this MUST be the URL subdomain part. eg. if you're setting up a portal at http://myportal.example.com, set this to 'myportal'
COSINNUS_PORTAL_NAME = 'subportal'

# i18n string that is used as the base page title for this portal
COSINNUS_BASE_PAGE_TITLE_TRANS = 'subportal'

SESSION_COOKIE_DOMAIN = '.yourserver.com'
SESSION_COOKIE_NAME = 'subportal'

""" *** Add any custom portal-specific settings that affect cosinnus apps here: *** """

COSINNUS_ETHERPAD_BASE_URL = 'https://pad.yourserver.com/api'

COSINNUS_ETHERPAD_ENABLE_ETHERCALC = True
COSINNUS_ETHERPAD_ETHERCALC_BASE_URL = 'https://calc.yourserver.com'

COSINNUS_SITE_PROTOCOL = 'http'

# default from-email:
COSINNUS_DEFAULT_FROM_EMAIL = 'noreply@yourserver.com'
DEFAULT_FROM_EMAIL = COSINNUS_DEFAULT_FROM_EMAIL



# user visibility setting is "logged in only" for this portal!
COSINNUS_USER_DEFAULT_VISIBLE_WHEN_CREATED = False

# PIWIK site id, if wished
PIWIK_SITE_ID = None # 2

# showing data from the main portal
COSINNUS_SEARCH_DISPLAY_FOREIGN_PORTALS = [1]




""" *** These settings don't usually have to be changed for any portal, so only tamper
    with them if you know what you are doing *** """

# this overrides the default setting, and is meant to! (a custom django command takes care of the proper static file collection for the right paths)
STATIC_ROOT = join(BASE_PATH, 'static-collected-%s' % COSINNUS_PORTAL_NAME)

# set to use the memcache instance of this portal ID. can be overridden.
if 'memcached' in CACHES['default']['BACKEND']:
    CACHES['default']['LOCATION'] = '127.0.0.1:113%02d' % SITE_ID

# We're adding overriding template dirs for each custom subdomain here, 
# in line with django's philosophy of same paths overriding and cascading downwards.
TEMPLATES[0]['DIRS'] = [
    join(BASE_PATH, 'devops', 'templates_subdomain', COSINNUS_PORTAL_NAME),
] +  TEMPLATES[0]['DIRS']

# Additional locations of static files
STATICFILES_DIRS = (
    join(BASE_PATH, 'static_subdomain', COSINNUS_PORTAL_NAME),
) + STATICFILES_DIRS

# try to load the local `config_portal_extra.py` settings file,
# so we can override settings for each portal individually
try:
    import os
    extra_settings_module = '.%s_extra' % os.path.basename(__file__).split('.')[0]
    exec 'from %s import *' % extra_settings_module
except:
    pass

