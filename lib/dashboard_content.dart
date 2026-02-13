import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Needed for Firebase.app()
import 'package:firebase_database/firebase_database.dart';
import 'constants.dart'; // Import the file with the shared URL

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 1. WE ADDED 'containerKey' TO LINK DISHES TO DATABASE
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
        const Text(
          'Dishes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),

        // Cards
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
    // 2. CONNECT TO THE SPECIFIC CONTAINER USING THE SHARED URL
    // We use instanceFor + kDatabaseURL to match graph.dart perfectly
    final dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: kDatabaseURL, // <--- THE FIX IS HERE
    ).ref().child('containers/${data.containerKey}');

    return StreamBuilder(
      stream: dbRef.onValue, 
      builder: (context, snapshot) {
        
        // Default placeholders 
        String v135 = '--';
        String v136 = '--';
        String v137 = '--';

        // 3. EXTRACT REAL DATA
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final values = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          v135 = values['mq135']?.toString() ?? '--';
          v136 = values['mq136']?.toString() ?? '--';
          v137 = values['mq137']?.toString() ?? '--';
        }

        return Container(
          height: 120, 
          decoration: BoxDecoration(
            color: const Color(0xFF00B250),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            children: [
              // Left text area
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 100, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TITLE
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
                      
                      // STATUS 
                      const Text(
                        'Status: Monitoring',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 12),

                      // REAL SENSOR DATA ROW
                      Row(
                        children: [
                          _sensorColumn('MQ135', v135),
                          const SizedBox(width: 12),
                          _sensorColumn('MQ136', v136),
                          const SizedBox(width: 12),
                          _sensorColumn('MQ137', v137),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              // Right circular photo
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

  // Helper widget 
  Widget _sensorColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)
        ),
        Text(
          value, 
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}