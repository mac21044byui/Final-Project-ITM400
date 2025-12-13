import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_page_loads(client):
    """Test that the home page loads successfully (Status Code 200)."""
    response = client.get('/')
    assert response.status_code == 200

def test_content_verification(client):
    """Test that the game title exists in the response."""
    response = client.get('/')
    assert b"DevOps Match Game" in response.data

def test_health_check(client):
    """Integration style test: Ensure the health endpoint is reachable."""
    response = client.get('/health')
    assert response.status_code == 200
    assert b"OK" in response.data