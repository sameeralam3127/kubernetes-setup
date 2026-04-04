from locust import HttpUser, task, between
import random

class MyUser(HttpUser):
    wait_time = between(1, 2)

    item_ids = []

    @task(3)
    def get_items(self):
        self.client.get("/items")

    @task(2)
    def create_item(self):
        response = self.client.post(
            "/items",
            params={"name": "test", "description": "test"}
        )
        if response.status_code == 200:
            try:
                data = response.json()
                self.item_ids.append(data["id"])
            except:
                pass

    @task(2)
    def get_single_item(self):
        if self.item_ids:
            item_id = random.choice(self.item_ids)
            self.client.get(f"/items/{item_id}")

    @task(1)
    def delete_item(self):
        if self.item_ids:
            item_id = random.choice(self.item_ids)
            self.client.delete(f"/items/{item_id}")
            try:
                self.item_ids.remove(item_id)
            except:
                pass