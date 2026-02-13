import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class LiveSensorGraph extends StatefulWidget {
  const LiveSensorGraph({super.key});

  @override
  State<LiveSensorGraph> createState() => _LiveSensorGraphState();
}

class _LiveSensorGraphState extends State<LiveSensorGraph> {
  // --- DATA STORAGE (3 Containers x 3 Sensors) ---
  final Map<String, List<FlSpot>> _data = {
    'c1_135': [], 'c1_136': [], 'c1_137': [],
    'c2_135': [], 'c2_136': [], 'c2_137': [],
    'c3_135': [], 'c3_136': [], 'c3_137': [],
  };

  int _selectedContainer = 1; // 1, 2, or 3
  bool _show135 = true;
  bool _show136 = true;
  bool _show137 = true;

  double _xValue = 0;
  final int _windowSize = 60; 
  late final DatabaseReference _dbRef;

  @override
  void initState() {
    super.initState();
    _dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://thesis-rotify-default-rtdb.asia-southeast1.firebasedatabase.app/',
    ).ref();
    _setupAllListeners();
  }

  void _setupAllListeners() {
    for (int c = 1; c <= 3; c++) {
      for (int s in [135, 136, 137]) {
        _dbRef.child('containers/container$c/mq$s').onValue.listen((event) {
          if (event.snapshot.value != null) {
            _updateData('c${c}_$s', double.parse(event.snapshot.value.toString()));
          }
        });
      }
    }
  }

  void _updateData(String key, double value) {
    if (!mounted) return;
    setState(() {
      _data[key]!.add(FlSpot(_xValue, value));
      if (_data[key]!.length > _windowSize) _data[key]!.removeAt(0);
      _xValue += 0.11; // Small increment to keep 9 listeners synced on X-axis
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- 1. CONTAINER SELECTOR ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ToggleButtons(
            isSelected: [_selectedContainer == 1, _selectedContainer == 2, _selectedContainer == 3],
            onPressed: (index) => setState(() => _selectedContainer = index + 1),
            borderRadius: BorderRadius.circular(8),
            constraints: const BoxConstraints(minHeight: 35, minWidth: 100),
            children: const [Text("Container 1"), Text("Container 2"), Text("Container 3")],
          ),
        ),

        // --- 2. SENSOR CHECKBOXES ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggle("MQ135", const Color(0xFF0072B2), _show135, (v) => setState(() => _show135 = v)),
            _buildToggle("MQ136", const Color(0xFFD55E00), _show136, (v) => setState(() => _show136 = v)),
            _buildToggle("MQ137", const Color(0xFF009E73), _show137, (v) => setState(() => _show137 = v)),
          ],
        ),

        // --- 3. THE PLOTTER ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: true),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.3))),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  if (_show135) _buildLine(_data['c${_selectedContainer}_135']!, const Color(0xFF0072B2)),
                  if (_show136) _buildLine(_data['c${_selectedContainer}_136']!, const Color(0xFFD55E00)),
                  if (_show137) _buildLine(_data['c${_selectedContainer}_137']!, const Color(0xFF009E73)),
                ],
                minY: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, Color color, bool isActive, Function(bool) onTap) {
    return InkWell(
      onTap: () => onTap(!isActive),
      child: Row(
        children: [
          Checkbox(value: isActive, activeColor: color, onChanged: (v) => onTap(v ?? true)),
          Text(label, style: TextStyle(color: isActive ? Colors.black : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 1.5,
      dotData: const FlDotData(show: false),
    );
  }
}