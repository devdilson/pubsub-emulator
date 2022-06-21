from google.cloud import pubsub_v1
from concurrent.futures import TimeoutError
import sys



def create_topic(project_id, topic_id):
  publisher = pubsub_v1.PublisherClient()
  topic_path = publisher.topic_path(project_id, topic_id)
  topic = publisher.create_topic(request={"name": topic_path})
  print(f"Created topic: {topic.name}")
  sys.stdout.flush()

def create_subscription(project_id: str, topic_id: str, subscription_id: str) -> None:
    """Create a new pull subscription on the given topic."""
    publisher = pubsub_v1.PublisherClient()
    subscriber = pubsub_v1.SubscriberClient()
    topic_path = publisher.topic_path(project_id, topic_id)
    subscription_path = subscriber.subscription_path(project_id, subscription_id)

    with subscriber:
        subscription = subscriber.create_subscription(
            request={"name": subscription_path, "topic": topic_path}
        )

    print(f"Subscription created: {subscription}")
    sys.stdout.flush()

def print_messages(project_id, subscription_id):
  subscriber = pubsub_v1.SubscriberClient()
  subscription_path = subscriber.subscription_path(project_id, subscription_id)

  def callback(message: pubsub_v1.subscriber.message.Message) -> None:
      print(f"Received {message}.")
      message.ack()
      sys.stdout.flush()

  streaming_pull_future = subscriber.subscribe(subscription_path, callback=callback)
  print(f"Listening for messages on {subscription_path}..\n")

  with subscriber:
      try:
          streaming_pull_future.result()
      except TimeoutError:
          streaming_pull_future.cancel()  # Trigger the shutdown.
          streaming_pull_future.result()  # Block until the shutdown is complete.


project_id='test-container'
topic_id='test_topic'
subscription_id='subscription_id'

if __name__ == "__main__":
  create_topic(project_id, topic_id)
  create_subscription(project_id, topic_id, subscription_id)
  print_messages(project_id, subscription_id)


# create_subscriptionproject_id, subscription_id)