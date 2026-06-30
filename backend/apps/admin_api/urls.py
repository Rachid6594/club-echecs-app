from django.urls import path

from apps.admin_api.views import (
    AppLoginView,
    AppRegisterView,
    AdminAuditLogListView,
    AdminBadgeListView,
    AdminDashboardView,
    AdminDisputeListView,
    AdminMemberListCreateView,
    AdminTournamentListCreateView,
)


urlpatterns = [
    path("app/auth/register/", AppRegisterView.as_view(), name="app-auth-register"),
    path("app/auth/login/", AppLoginView.as_view(), name="app-auth-login"),
    path("admin/dashboard/", AdminDashboardView.as_view(), name="admin-dashboard"),
    path("admin/members/", AdminMemberListCreateView.as_view(), name="admin-members"),
    path("admin/tournaments/", AdminTournamentListCreateView.as_view(), name="admin-tournaments"),
    path("admin/disputes/", AdminDisputeListView.as_view(), name="admin-disputes"),
    path("admin/badges/", AdminBadgeListView.as_view(), name="admin-badges"),
    path("admin/audit-logs/", AdminAuditLogListView.as_view(), name="admin-audit-logs"),
]
