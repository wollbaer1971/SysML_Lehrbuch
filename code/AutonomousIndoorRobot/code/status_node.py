import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class StatusNode(Node):
    def __init__(self):
        super().__init__('status_node')
        self.publisher = self.create_publisher(String, '/robot/status', 10)
        self.timer = self.create_timer(1.0, self.publish_status)

    def publish_status(self):
        msg = String()
        msg.data = 'Robot is running'
        self.publisher.publish(msg)

def main():
    rclpy.init()
    node = StatusNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
