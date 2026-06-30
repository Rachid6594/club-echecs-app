from django.urls import path

from apps.admin_api.views import (
    AdminAuditLogListView,
    AdminBadgeListView,
    AdminDashboardView,
    AdminDisputeListView,
    AdminMemberListCreateView,
    AdminTournamentListCreateView,
)


urlpatterns = [
    path("admin/dashboard/", AdminDashboardView.as_view(), name="admin-dashboard"),
    path("admin/members/", AdminMemberListCreateView.as_view(), name="admin-members"),
    path("admin/tournaments/", AdminTournamentListCreateView.as_view(), name="admin-tournaments"),
    path("admin/disputes/", AdminDisputeListView.as_view(), name="admin-disputes"),
    path("admin/badges/", AdminBadgeListView.as_view(), name="admin-badges"),
    path("admin/audit-logs/", AdminAuditLogListView.as_view(), name="admin-audit-logs"),
]
