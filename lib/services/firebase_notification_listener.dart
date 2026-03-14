import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class FirebaseNotificationListener {
  final DatabaseReference _db = FirebaseDatabase.instance.ref('containers');
  StreamSubscription<DatabaseEvent>? _subscription;

  final Map<String, String> _lastNotifiedPrediction = {};

  void start() {
    _subscription = _db.onValue.listen((event) async {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;

      if (!notificationsEnabled) return;

      final data = event.snapshot.value;

      if (data == null || data is! Map) return;

      for (final entry in data.entries) {
        final containerName = entry.key.toString();
        final containerData = entry.value;

        if (containerData is Map) {
          final prediction =
              containerData['prediction']?.toString().toUpperCase() ?? '';

          if (prediction == 'MID' || prediction == 'SPOILED') {
            final lastPrediction = _lastNotifiedPrediction[containerName];

            // para hindi paulit-ulit magnotif kung same status lang
            if (lastPrediction != prediction) {
              _lastNotifiedPrediction[containerName] = prediction;

              await NotificationService.showSpoilageNotification(
                container: containerName,
                prediction: prediction,
              );
            }
          } else {
            // reset kapag bumalik sa FRESH
            _lastNotifiedPrediction.remove(containerName);
          }
        }
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
