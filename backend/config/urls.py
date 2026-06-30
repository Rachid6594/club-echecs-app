from django.contrib import admin
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from config.views import HealthCheckView


router = DefaultRouter()

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/health/", HealthCheckView.as_view(), name="health-check"),
    path("api/", include("apps.admin_api.urls")),
    path("api/auth/", include("apps.accounts.urls")),
    path("api/", include("apps.clubs.urls")),
    path("api/", include(router.urls)),
]
