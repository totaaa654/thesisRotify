import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      DishCardData(
        name: 'CHICKEN CURRY',
        imagePath: 'assets/images/chicken_curry.png',
        containerKey: 'container1',
      ),
      DishCardData(
        name: 'BICOL EXPRESS',
        imagePath: 'assets/images/bicol_express.png',
        containerKey: 'container2',
      ),
      DishCardData(
        name: 'MENUDO',
        imagePath: 'assets/images/menudo.png',
        containerKey: 'container3',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NotificationWatcher(),
        const Text(
          'Dishes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: DishStatusCard(data: d),
          ),
        ),
      ],
    );
  }
}

class NotificationWatcher extends StatefulWidget {
  const NotificationWatcher({super.key});

  @override
  State<NotificationWatcher> createState() => _NotificationWatcherState();
}

class _NotificationWatcherState extends State<NotificationWatcher> {
  StreamSubscription<DatabaseEvent>? _notifSub;

  final Map<String, String> _lastNotifiedPrediction = {};
  final Map<String, bool> _lastPollutionState = {};

  final Map<String, String> _containerDisplayNames = {
    'container1': 'Chicken Curry',
    'container2': 'Bicol Express',
    'container3': 'Menudo',
  };

  @override
  void initState() {
    super.initState();
    _startNotificationListener();
  }

  void _startNotificationListener() {
    final dbRef = FirebaseDatabase.instance.ref().child('containers');

    _notifSub = dbRef.onValue.listen((event) async {
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled =
          prefs.getBool('notifications_enabled') ?? false;

      if (!notificationsEnabled) return;

      final raw = event.snapshot.value;
      if (raw == null || raw is! Map) return;

      final allContainers = raw as Map<dynamic, dynamic>;

      for (final entry in allContainers.entries) {
        final containerKey = entry.key.toString();
        final containerData = entry.value;

        if (containerData is Map<dynamic, dynamic>) {
          final displayName =
              _containerDisplayNames[containerKey] ?? containerKey;

          final prediction =
              containerData['prediction']?.toString().toUpperCase() ?? '';

          final mq135Raw = containerData['mq135'];
          final int mq135 = int.tryParse(mq135Raw?.toString() ?? '0') ?? 0;

          // =========================
          // SPOILAGE ALERT
          // =========================
          if (prediction == 'MID' || prediction == 'SPOILED') {
            final lastPrediction = _lastNotifiedPrediction[containerKey];

            if (lastPrediction != prediction) {
              _lastNotifiedPrediction[containerKey] = prediction;

              await NotificationService.showSpoilageNotification(
                container: displayName,
                prediction: prediction,
              );
            }
          } else {
            _lastNotifiedPrediction.remove(containerKey);
          }

          // =========================
          // POLLUTION ALERT (MQ135)
          // =========================
          const int mq135Threshold = 1; // palitan if needed
          final bool pollutionDetected = mq135 >= mq135Threshold;
          final bool lastPollution = _lastPollutionState[containerKey] ?? false;

          if (pollutionDetected && !lastPollution) {
            _lastPollutionState[containerKey] = true;

            await NotificationService.showPollutionNotification(
              container: displayName,
              mq135Value: mq135,
            );
          } else if (!pollutionDetected) {
            _lastPollutionState[containerKey] = false;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class DishCardData {
  final String name;
  final String imagePath;
  final String containerKey;

  const DishCardData({
    required this.name,
    required this.imagePath,
    required this.containerKey,
  });
}

class DishStatusCard extends StatelessWidget {
  final DishCardData data;

  const DishStatusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final dbRef = FirebaseDatabase.instance
        .ref()
        .child('containers/${data.containerKey}');

    return StreamBuilder(
      stream: dbRef.onValue,
      builder: (context, snapshot) {
        String v135 = '--';
        String v136 = '--';
        String v137 = '--';
        String status = 'Monitoring';

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          v135 = values['mq135']?.toString() ?? '--';
          v136 = values['mq136']?.toString() ?? '--';
          v137 = values['mq137']?.toString() ?? '--';
          status = values['prediction']?.toString() ?? 'Monitoring';
        }

        return Container(
          height: 130,
          decoration: BoxDecoration(
            color: const Color(0xFF00B250),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 100, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Status: $status',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 12),
                      Row(
                        children: [
                          _sensorColumn('MQ135', v135),
                          const SizedBox(width: 12),
                          _sensorColumn('MQ136', v136),
                          const SizedBox(width: 12),
                          _sensorColumn('MQ137', v137),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(data.imagePath, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sensorColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
