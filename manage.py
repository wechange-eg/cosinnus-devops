#!/usr/bin/env python
import os
import sys

if __name__ == '__main__':
    from django.core.management import execute_from_command_line
    
    COSINNUS_PORTAL_ARG = '--cosinnus-portal'
    portal = None
    
    # collect the portal arg, if given. this arg is used to redirect the used settings
    # file to a portal-specific one
    args = list(sys.argv)
    if COSINNUS_PORTAL_ARG in args:
        index = args.index(COSINNUS_PORTAL_ARG)
        try:
            portal = args[index+1]
        except IndexError:
            raise Exception('You must supply the name of a cosinnus portal when ' + \
                'using the %s flag!' % COSINNUS_PORTAL_ARG)
        args = args[:index] + args[index+2:]

    settings_path = ('devops.config_%s' % portal) if portal else 'devops.settings'
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', settings_path)
        
    execute_from_command_line(args)
