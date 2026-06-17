// import 'dart:convert';
// import 'package:bayader_teacher/core/lang/locale_keys.dart';
// import 'package:bayader_teacher/core/routes/app_routes.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage remoteMessage) async {
//   await Firebase.initializeApp();
//   debugPrint('Background Message: ${remoteMessage.messageId}');
// }

// late AndroidNotificationChannel channel;
// late FlutterLocalNotificationsPlugin localNotificationsPlugin;

// mixin FbNotifications {
//   static Future<void> initNotifications() async {
//     FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//     if (!kIsWeb) {
//       channel = const AndroidNotificationChannel(
//         'bayader_notifications_channel',
//         'Bayader Notifications',
//         description: 'This channel is used for Bayader Teacher notifications.',
//         importance: Importance.high,
//         enableLights: true,
//         enableVibration: true,
//         showBadge: true,
//         playSound: true,
//       );

//       localNotificationsPlugin = FlutterLocalNotificationsPlugin();
      
//       await localNotificationsPlugin
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.createNotificationChannel(channel);

//       const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
//       const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings();
//       const InitializationSettings initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsDarwin,
//       );

//       await localNotificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: (NotificationResponse response) {
//           if (response.payload != null) {
//             Map<String, dynamic> data = jsonDecode(response.payload!);
//             _staticControlNotificationNavigation(data);
//           }
//         },
//       );
//     }

//     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }

//   Future<void> requestNotificationPermissions() async {
//     NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (GetPlatform.isAndroid) {
//       await localNotificationsPlugin
//           .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestNotificationsPermission();
//     }

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       debugPrint('User granted permission');
//     }
//   }

//   void initializeForegroundNotification() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       debugPrint('Foreground Message: ${message.data}');
      
//       RemoteNotification? notification = message.notification;
      
//       String title = notification?.title ?? message.data['title'] ?? LocaleKeys.newAlert.tr;
//       String body = notification?.body ?? message.data['body'] ?? "";

//       Get.snackbar(
//         title,
//         body,
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.white.withAlpha(230),
//         margin: const EdgeInsets.all(10),
//         duration: const Duration(seconds: 4),
//         onTap: (_) {
//           _controlNotificationNavigation(message.data);
//         }
//       );

//       if (!kIsWeb) {
//         localNotificationsPlugin.show(
//           notification?.hashCode ?? message.hashCode,
//           title,
//           body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               channelDescription: channel.description,
//               icon: '@mipmap/ic_launcher',
//               importance: Importance.max,
//               priority: Priority.high,
//             ),
//           ),
//           payload: jsonEncode(message.data),
//         );
//       }
//     });
//   }

//   void manageNotificationAction() {
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _controlNotificationNavigation(message.data);
//     });

//     FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//       if (message != null) {
//         _controlNotificationNavigation(message.data);
//       }
//     });
//   }

//   void _controlNotificationNavigation(Map<String, dynamic> data) {
//     _staticControlNotificationNavigation(data);
//   }

//   static void _staticControlNotificationNavigation(Map<String, dynamic> data) {
//     debugPrint('Navigating with data: $data');
//     final String? type = data['type'];
    
//     if (type != null) {
//       switch (type) {
//         case 'request':
//           Get.toNamed(Routes.joinRequests);
//           break;
//         case 'points':
//           Get.toNamed(Routes.wallet);
//           break;
//         case 'followRequest':
//           Get.toNamed(Routes.profile);
//           break;
//         case 'notification':
//           Get.toNamed(Routes.notifications);
//           break;
//         default:
//           if (Get.currentRoute != '/notifications') {
//             Get.toNamed(Routes.notifications);
//           }
//       }
//     }
//   }

//   Future<void> sendNotify(String title, String body, String topic) async {
//     debugPrint("Info: Notifications should be sent from Laravel Backend for security.");
//   }

//   Future<String?> getToken() async {
//     try {
//       if (GetPlatform.isIOS) {
//         // Wait a bit for APNS token to be ready on iOS
//         String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
//         if (apnsToken == null) {
//           await Future.delayed(const Duration(seconds: 3));
//         }
//       }
//       String? token = await FirebaseMessaging.instance.getToken();
//       debugPrint("Device Token: $token");
//       return token;
//     } catch (e) {
//       debugPrint("FCM Token Error: $e");
//       return null;
//     }
//   }
// }
