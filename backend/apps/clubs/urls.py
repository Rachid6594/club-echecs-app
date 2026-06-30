from django.urls import path

from apps.clubs.views import (
    InvitationActionView,
    InvitationCreateView,
    InvitationReceivedListView,
    InvitationSentListView,
    MemberDetailView,
    MemberInviteView,
    MemberListView,
    MemberStatsView,
)


urlpatterns = [
    path("members/", MemberListView.as_view(), name="member-list"),
    path("members/<uuid:member_id>/", MemberDetailView.as_view(), name="member-detail"),
    path("members/<uuid:member_id>/stats/", MemberStatsView.as_view(), name="member-stats"),
    path("members/<uuid:member_id>/invite/", MemberInviteView.as_view(), name="member-invite"),
    path("invitations/", InvitationCreateView.as_view(), name="invitation-create"),
    path("invitations/received/", InvitationReceivedListView.as_view(), name="invitation-received-list"),
    path("invitations/sent/", InvitationSentListView.as_view(), name="invitation-sent-list"),
    path("invitations/<uuid:invitation_id>/<str:action>/", InvitationActionView.as_view(), name="invitation-action"),
]

