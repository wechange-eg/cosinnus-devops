# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from devops.settings import *


del SESSION_COOKIE_DOMAIN
del SESSION_COOKIE_NAME

del LOGGING

########## IN-MEMORY TEST DATABASE
"""
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
        "USER": "",
        "PASSWORD": "",
        "HOST": "",
        "PORT": "",
    },
}
"""