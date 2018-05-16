# -*- coding: utf-8 -*-

from django.conf import settings
from django.conf.urls import patterns, include, url
from django.conf.urls.static import static
from django.contrib import admin
from django.contrib.staticfiles.urls import staticfiles_urlpatterns

from cosinnus.core.registries import url_registry

from wagtail.wagtailcore import urls as wagtail_urls
from wagtail.wagtailadmin import urls as wagtailadmin_urls
from wagtail.wagtaildocs import urls as wagtaildocs_urls
from wagtail.wagtailsearch import urls as wagtailsearch_urls

from cosinnus.templatetags.cosinnus_tags import is_integrated_portal

admin.autodiscover()


urlpatterns = patterns('',
    url(r'^admin/', include(admin.site.urls)),
)


# postman messages not allowed in integrated mode
if not is_integrated_portal():
    urlpatterns += patterns('',
        url(r'^nachrichten/', include('cosinnus_message.postman_urls', namespace='postman')),
        
    )

urlpatterns += patterns('',
    url(r'^', include('djajax.urls', namespace='djajax')),
    url(r'^', include('cosinnus.urls', namespace='cosinnus')),
    url(r'^', include(url_registry.api_urlpatterns, namespace='cosinnus-api')),

    url(r'^select2/', include('django_select2.urls')),
    url(r'^', include('cosinnus.utils.django_auth_urls')),
    # leave at the end
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),

)

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += staticfiles_urlpatterns()

if getattr(settings, 'DEBUG_TOOLBAR_ENABLED', False) and settings.DEBUG:
    try:
        import debug_toolbar
        urlpatterns += patterns('',
            url(r'^__debug__/', include(debug_toolbar.urls)),
        )
    except (ImportError, AttributeError):
        pass

urlpatterns += patterns('',
    url(r'^cms-admin/', include(wagtailadmin_urls)),
    url(r'^cms-search/', include(wagtailsearch_urls)),
    url(r'^cms-documents/', include(wagtaildocs_urls)),
    url(r'', include(wagtail_urls)),
)


handler403 = 'cosinnus.views.common.view_403'
handler404 = 'cosinnus.views.common.view_404'
handler500 = 'cosinnus.views.common.view_500'

