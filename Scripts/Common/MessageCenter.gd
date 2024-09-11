extends Node

var notifications : Array[Notification] = []
var all_msg_observers = {}

func distribute_msg(msg):
	var notification_name : String = msg["Type"]
	var current_notifications = notifications.filter(func(n): return n.name == notification_name)
	if current_notifications.size() > 0:
		var current_observers = current_notifications[0].observers
		for current_observer in current_observers:
			if current_observer.object.has_method(current_observer.action):
				current_observer.object.call(current_observer.action, msg)

func add_observer(object : Node, notification_name : String, action : String):
	var current_notifications : Array[Notification] = notifications.filter(func(n : Notification): return n.name == notification_name)
	var current_notification = null
	if current_notifications.size() < 1:
		current_notification = Notification.new(notification_name)
		notifications.append(current_notification)
	else:
		current_notification = current_notifications[0]
	current_notification.add_observer(object, action)

func post_msg(msg : Dictionary):
	distribute_msg(msg)
