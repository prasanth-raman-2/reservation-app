{"is_source_file": true, "format": "Dart", "description": "Service for handling Firebase Cloud Messaging notifications", "external_files": ["firebase_messaging.dart", "logger.dart"], "external_methods": ["FirebaseMessaging.instance.requestPermission", "FirebaseMessaging.instance.getToken", "FirebaseMessaging.onMessage.listen", "FirebaseMessaging.instance.getInitialMessage", "FirebaseMessaging.onMessageOpenedApp.listen", "FirebaseMessaging.instance.subscribeToTopic", "FirebaseMessaging.instance.unsubscribeFromTopic"], "published": ["NotificationService", "subscribeToTopic", "unsubscribeFromTopic", "getToken", "initialize"], "classes": [{"name": "NotificationService", "description": "Handles Firebase Cloud Messaging notifications as a singleton service."}], "methods": [{"name": "initialize", "description": "Initializes the notification service, requests permission, obtains the FCM token, and sets up message handlers."}, {"name": "subscribeToTopic", "description": "Subscribes the client to a specified FCM topic."}, {"name": "unsubscribeFromTopic", "description": "Unsubscribes the client from a specified FCM topic."}, {"name": "getToken", "description": "Retrieves the current FCM token for the device."}], "calls": ["FirebaseMessaging.instance.requestPermission", "FirebaseMessaging.instance.getToken", "FirebaseMessaging.onMessage.listen", "FirebaseMessaging.instance.getInitialMessage", "FirebaseMessaging.onMessageOpenedApp.listen", "FirebaseMessaging.instance.subscribeToTopic", "FirebaseMessaging.instance.unsubscribeFromTopic"], "search-terms": ["FirebaseCloudMessaging", "NotificationService", "FCM"], "state": 2, "file_id": 61, "knowledge_revision": 153, "git_revision": "", "revision_history": [{"129": ""}, {"145": ""}, {"146": ""}, {"147": ""}, {"148": ""}, {"149": ""}, {"150": ""}, {"151": ""}, {"153": ""}], "filename": "/home/kavia/workspace/reservation-app/reservation_management/lib/services/notification_service.dart", "hash": "e5e6d37f158c3ef43e538596862ec071", "format-version": 4, "code-base-name": "default"}