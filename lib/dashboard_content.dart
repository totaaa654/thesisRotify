import 'package:flutter/material.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Dummy list (backend later)
    final items = [
      DishCardData(
        name: 'CHICKEN CURRY',
        imagePath: 'assets/images/chicken_curry.png',
      ),
      DishCardData(
        name: 'BICOL EXPRESS',
        imagePath: 'assets/images/bicol_express.png',
      ),
      DishCardData(name: 'MENUDO', imagePath: 'assets/images/menudo.png'),
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

  // later: final String status; final int ppm;
  const DishCardData({required this.name, required this.imagePath});
}

class DishStatusCard extends StatelessWidget {
  final DishCardData data;
  const DishStatusCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // ✅ placeholders for now (backend later)
    const String statusText = 'Status: --';
    const String ppmText = '-- ppm';

    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: const Color(0xFF00B250), // green card color
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          // Left text
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 110, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    ppmText,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right circular photo area (like your screenshot)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Container(
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(data.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
