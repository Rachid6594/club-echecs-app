from django.db.models import Q
from django.shortcuts import get_object_or_404
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.clubs.models import ClubMember, Invitation
from apps.clubs.serializers import ClubMemberSerializer, InvitationSerializer, MemberStatsSerializer


class MemberListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        queryset = (
            ClubMember.objects.select_related("user", "user__profile")
            .filter(status=ClubMember.Status.ACTIVE)
            .order_by("user__username")
        )
        search = request.query_params.get("search")
        if search:
            queryset = queryset.filter(
                Q(user__username__icontains=search)
                | Q(user__email__icontains=search)
                | Q(user__profile__display_name__icontains=search)
            )
        return Response(ClubMemberSerializer(queryset, many=True).data)


class MemberDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, member_id):
        member = get_object_or_404(
            ClubMember.objects.select_related("user", "user__profile"),
            id=member_id,
            status=ClubMember.Status.ACTIVE,
        )
        return Response(ClubMemberSerializer(member).data)


class MemberStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, member_id):
        member = get_object_or_404(ClubMember.objects.select_related("user"), id=member_id)
        serializer = MemberStatsSerializer(
            {
                "user_id": member.user_id,
                "games_played": 0,
                "wins": 0,
                "draws": 0,
                "losses": 0,
                "points": 0,
            }
        )
        return Response(serializer.data)


class MemberInviteView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, member_id):
        member = get_object_or_404(ClubMember, id=member_id, status=ClubMember.Status.ACTIVE)
        serializer = InvitationSerializer(
            data={**request.data, "receiver_id": str(member.user_id)},
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        invitation = serializer.save()
        return Response(InvitationSerializer(invitation).data, status=status.HTTP_201_CREATED)


class InvitationCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = InvitationSerializer(data=request.data, context={"request": request})
        serializer.is_valid(raise_exception=True)
        invitation = serializer.save()
        return Response(InvitationSerializer(invitation).data, status=status.HTTP_201_CREATED)


class InvitationReceivedListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        invitations = Invitation.objects.select_related("sender", "sender__profile", "receiver", "receiver__profile").filter(
            receiver=request.user
        )
        for invitation in invitations:
            invitation.mark_expired_if_needed()
        invitations = invitations.order_by("-created_at")
        return Response(InvitationSerializer(invitations, many=True).data)


class InvitationSentListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        invitations = Invitation.objects.select_related("sender", "sender__profile", "receiver", "receiver__profile").filter(
            sender=request.user
        )
        for invitation in invitations:
            invitation.mark_expired_if_needed()
        invitations = invitations.order_by("-created_at")
        return Response(InvitationSerializer(invitations, many=True).data)


class InvitationActionView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, invitation_id, action):
        invitation = get_object_or_404(Invitation, id=invitation_id)
        invitation.mark_expired_if_needed()

        if invitation.status != Invitation.Status.PENDING:
            return Response({"detail": "Invitation non modifiable."}, status=status.HTTP_400_BAD_REQUEST)

        if action == "accept":
            if invitation.receiver_id != request.user.id:
                return Response({"detail": "Seul le destinataire peut accepter."}, status=status.HTTP_403_FORBIDDEN)
            invitation.status = Invitation.Status.ACCEPTED
        elif action == "reject":
            if invitation.receiver_id != request.user.id:
                return Response({"detail": "Seul le destinataire peut refuser."}, status=status.HTTP_403_FORBIDDEN)
            invitation.status = Invitation.Status.REJECTED
        elif action == "cancel":
            if invitation.sender_id != request.user.id:
                return Response({"detail": "Seul l'expediteur peut annuler."}, status=status.HTTP_403_FORBIDDEN)
            invitation.status = Invitation.Status.CANCELLED
        else:
            return Response({"detail": "Action inconnue."}, status=status.HTTP_404_NOT_FOUND)

        invitation.responded_at = timezone.now()
        invitation.save(update_fields=["status", "responded_at", "updated_at"])
        return Response(InvitationSerializer(invitation).data)

