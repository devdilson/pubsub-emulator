from topic import create_topic, create_subscription, send_message, receive_message
import json
import sys



project_id='test-container'
topic_id='test_topic'
subscription_id='subscription_id'

if __name__ == "__main__":
  create_topic(project_id, topic_id)
  sys.stdout.flush()
  create_subscription(project_id, topic_id, subscription_id)

  data = {
    'test': 'test'
  }
  json_data = json.dumps(data)

  send_message(project_id, topic_id, json_data)
  receive_message(project_id, subscription_id)

