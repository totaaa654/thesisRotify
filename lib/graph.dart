import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'constants.dart'; // ✅ Import this to prevent the "Red Screen" crash

class LiveSensorGraph extends StatefulWidget {
  const LiveSensorGraph({super.key});

  @override
  State<LiveSensorGraph> createState() => _LiveSensorGraphState();
}

class _LiveSensorGraphState extends State<LiveSensorGraph> {
  // --- 1. STATIC MEMORY (These survive even when you switch tabs!) ---
  static final Map<String, List<FlSpot>> _globalData = {
    'c1_135': [], 'c1_136': [], 'c1_137': [],
    'c2_135': [], 'c2_136': [], 'c2_137': [],
    'c3_135': [], 'c3_136': [], 'c3_137': [],
  };
  
  static double _globalXValue = 0;
  static bool _hasStartedListening = false; // Ensures we don't start 2 listeners
  
  // This is a "Phone Line" for the background data to call the UI
  static Function()? _refreshUI; 

  // --- UI STATE (These reset when you switch tabs, which is normal) ---
  int _selectedContainer = 1; 
  bool _show135 = true;
  bool _show136 = true;
  bool _show137 = true;

  final int _windowSize = 60; 

  @override
  void initState() {
    super.initState();
    
    // 1. Connect the "Phone Line" so the data can update THIS screen
    _refreshUI = () {
      if (mounted) setState(() {});
    };

    // 2. Start Listening (Only once per app launch)
    if (!_hasStartedListening) {
      _setupBackgroundListeners();
      _hasStartedListening = true;
    }
  }

  @override
  void dispose() {
    // Disconnect the phone line when we leave the screen
    _refreshUI = null;
    super.dispose();
  }

  void _setupBackgroundListeners() {
    // Use the SAFE constant URL
    final dbRef = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: kDatabaseURL, 
    ).ref();

    for (int c = 1; c <= 3; c++) {
      for (int s in [135, 136, 137]) {
        dbRef.child('containers/container$c/mq$s').onValue.listen((event) {
          if (event.snapshot.value != null) {
            _updateGlobalData('c${c}_$s', double.parse(event.snapshot.value.toString()));
          }
        });
      }
    }
  }

  void _updateGlobalData(String key, double value) {
    // 1. Always update the permanent memory
    _globalData[key]!.add(FlSpot(_globalXValue, value));
    
    // Keep history clean (prevent infinite growth)
    if (_globalData[key]!.length > 60) {
      _globalData[key]!.removeAt(0);
    }
    
    _globalXValue += 0.11; 

    // 2. If the screen is open, tell it to repaint!
    if (_refreshUI != null) {
      _refreshUI!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- CONTAINER SELECTOR ---
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

        // --- SENSOR CHECKBOXES ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggle("MQ135", const Color(0xFF0072B2), _show135, (v) => setState(() => _show135 = v)),
            _buildToggle("MQ136", const Color(0xFFD55E00), _show136, (v) => setState(() => _show136 = v)),
            _buildToggle("MQ137", const Color(0xFF009E73), _show137, (v) => setState(() => _show137 = v)),
          ],
        ),

        // --- THE PLOTTER ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 20, 10),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: true),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.3))),
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  // Added Left Titles back so you can read the values
                   leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: _leftTitleWidgets,
                    ),
                  ),
                ),
                lineBarsData: [
                  if (_show135) _buildLine(_globalData['c${_selectedContainer}_135']!, const Color(0xFF0072B2)),
                  if (_show136) _buildLine(_globalData['c${_selectedContainer}_136']!, const Color(0xFFD55E00)),
                  if (_show137) _buildLine(_globalData['c${_selectedContainer}_137']!, const Color(0xFF009E73)),
                ],
                minY: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Text(
        value.toInt().toString(),
        style: const TextStyle(fontSize: 10, color: Colors.grey),
        textAlign: TextAlign.right,
      ),
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