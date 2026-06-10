import rclpy
from rclpy.node import Node
from sensor_msgs.msg import BatteryState

class BatteryMonitorNode(Node):
    def __init__(self):
        super().__init__('battery_monitor_node')
        self.publisher = self.create_publisher(BatteryState, '/battery_state', 10)
        self.level = 1.0
        self.timer = self.create_timer(1.0, self.publish_battery)

    def publish_battery(self):
        self.level = max(0.0, self.level - 0.01)
        msg = BatteryState()
        msg.percentage = self.level
        self.publisher.publish(msg)

def main():
    rclpy.init()
    node = BatteryMonitorNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
