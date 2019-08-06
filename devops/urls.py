# -*- coding: utf-8 -*-
from django.conf import settings
from django.conf.urls import include, url
from django.conf.urls.static import static
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

from cosinnus.core.registries import url_registry

from wagtail.core import urls as wagtail_urls
from wagtail.admin import urls as wagtailadmin_urls
from wagtail.documents import urls as wagtaildocs_urls

from django.views.generic import TemplateView
from cosinnus.templatetags.cosinnus_tags import is_integrated_portal

admin.autodiscover()


urlpatterns = [
    url(r'^admin/', admin.site.urls),
]

"""
for url_key in group_model_registry:
    prefix = group_model_registry.get_url_name_prefix(url_key, '')
    urlpatterns += [
        # overwriting cosinnus-core urls.py:
        url(r'^%s/(?P<group>[^/]+)/$' % url_key, GroupDashboardView.as_view(), name=prefix+'group-dashboard'),
        url(r'^%s/(?P<group>[^/]+)/microsite/$' % url_key, GroupMicrositeView.as_view(), name=prefix+'group-microsite'),
    ]
"""

# postman messages not allowed in integrated mode
if not is_integrated_portal():
    urlpatterns += [
        url(r'^nachrichten/', include(('cosinnus_message.postman_urls', 'postman'), namespace='postman')),
    ]

urlpatterns += [
    url(r'^', include(('djajax.urls', 'djajax'), namespace='djajax')),
    url(r'^', include(('cosinnus.urls', 'cosinnus'), namespace='cosinnus')),
    url(r'^', include((url_registry.api_urlpatterns, 'cosinnus'), namespace='cosinnus-api')),

    url(r'^select2/', include('django_select2.urls')),
    url(r'^captcha/', include('captcha.urls')),
    url(r'^', include('cosinnus.utils.django_auth_urls')),
    # leave at the end
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += staticfiles_urlpatterns()

if getattr(settings, 'DEBUG_TOOLBAR_ENABLED', False) and settings.DEBUG:
    try:
        import debug_toolbar
        urlpatterns += [
            url(r'^__debug__/', include(debug_toolbar.urls)),
        ]
    except (ImportError, AttributeError):
        pass

urlpatterns += [
    url(r'^cms-admin/', include(wagtailadmin_urls)),
    url(r'^cms-documents/', include(wagtaildocs_urls)),
    url(r'', include(wagtail_urls)),
]


handler403 = 'cosinnus.views.common.view_403'
handler404 = 'cosinnus.views.common.view_404'
handler500 = 'cosinnus.views.common.view_500'