def test_admin_dashboard_requires_admin_token(client):
    response = client.get("/api/admin/dashboard/")

    assert response.status_code == 403
    assert response.json()["detail"] == "Authentification admin requise."


def test_admin_members_requires_admin_token(client):
    response = client.get("/api/admin/members/")

    assert response.status_code == 403
    assert response.json()["detail"] == "Authentification admin requise."
