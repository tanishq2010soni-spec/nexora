"""Locust load test for Nexora platform."""

import random
from locust import HttpUser, task, between, tag

class NexoraUser(HttpUser):
    wait_time = between(1, 3)
    token = None
    org_id = None

    def on_start(self):
        email = f"locust-{random.randint(0, 100000)}@nexora.ai"
        password = "LocustTest123!"
        org_name = f"LocustOrg-{random.randint(0, 1000)}"

        res = self.client.post("/api/v1/auth/signup", json={
            "email": email,
            "password": password,
            "organization_name": org_name,
        })
        if res.status_code == 201:
            self.token = res.json()["access_token"]
            self.org_id = res.json()["org_id"]
        else:
            res = self.client.post("/api/v1/auth/login", json={
                "email": email,
                "password": password,
            })
            if res.status_code == 200:
                self.token = res.json()["access_token"]
                self.org_id = res.json()["org_id"]

    @tag("health")
    @task(5)
    def health_check(self):
        self.client.get("/health")

    @tag("metrics")
    @task(3)
    def metrics(self):
        self.client.get("/metrics")

    @tag("api")
    @task(10)
    def leads_list(self):
        if not self.token:
            return
        self.client.get("/api/v1/leads?limit=10",
            headers={"Authorization": f"Bearer {self.token}"})

    @tag("api")
    @task(5)
    def dashboard(self):
        if not self.token:
            return
        self.client.get("/api/v1/dashboard",
            headers={"Authorization": f"Bearer {self.token}"})

    @tag("api")
    @task(3)
    def customers_list(self):
        if not self.token:
            return
        self.client.get("/api/v1/customers?limit=10",
            headers={"Authorization": f"Bearer {self.token}"})

    @tag("api")
    @task(2)
    def create_lead(self):
        if not self.token:
            return
        self.client.post("/api/v1/leads", json={
            "name": f"Lead-{random.randint(0, 100000)}",
            "email": f"lead-{random.randint(0, 100000)}@test.com",
            "status": "new",
        }, headers={"Authorization": f"Bearer {self.token}"})

    @tag("analytics")
    @task(1)
    def analytics(self):
        if not self.token:
            return
        self.client.get("/api/v1/analytics/reports",
            headers={"Authorization": f"Bearer {self.token}"})

    @tag("conversations")
    @task(2)
    def conversations(self):
        if not self.token:
            return
        self.client.get("/api/v1/conversations?limit=10",
            headers={"Authorization": f"Bearer {self.token}"})
