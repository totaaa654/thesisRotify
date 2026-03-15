import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'constants.dart';

class LiveSensorGraph extends StatefulWidget {
  const LiveSensorGraph({super.key});

  static final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  static final Map<String, List<FlSpot>> _globalData = {
    'c1_135': [], 'c1_136': [], 'c1_137': [],
    'c2_135': [], 'c2_136': [], 'c2_137': [],
    'c3_135': [], 'c3_136': [], 'c3_137': [],
  };
  
  static double _globalXValue = 0;
  static bool _hasStartedListening = false;
  static Function()? _refreshUI; 

  static void startListeningInstantly() {
    if (_hasStartedListening) return; 
    _hasStartedListening = true;

    for (int c = 1; c <= 3; c++) {
      for (int s in [135, 136, 137]) {
        _dbRef.child('containers/container$c/mq$s').onValue.listen((event) {
          if (event.snapshot.value != null) {
            _updateGlobalDataStatic('c${c}_$s', double.parse(event.snapshot.value.toString()));
          }
        });
      }
    }
  }

  static void _updateGlobalDataStatic(String key, double value) {
    // ✅ 1. THE INVISIBILITY CLOAK: 
    // If the sensor reads 0, we just push the timeline forward but we DO NOT draw anything!
    if (value <= 0) {
      _globalXValue += 0.11; 
      return; 
    }

    // 2. We only record REAL data!
    _globalData[key]!.add(FlSpot(_globalXValue, value));
    
    if (_globalData[key]!.length > 60) {
      _globalData[key]!.removeAt(0);
    }
    
    _globalXValue += 0.11; 

    if (_refreshUI != null) {
      _refreshUI!();
    }
  }

  @override
  State<LiveSensorGraph> createState() => _LiveSensorGraphState();
}

class _LiveSensorGraphState extends State<LiveSensorGraph> {

  int _selectedContainer = 1; 
  bool _show135 = true;
  bool _show136 = true;
  bool _show137 = true;

  @override
  void initState() {
    super.initState();
    LiveSensorGraph._refreshUI = () {
      if (mounted) setState(() {});
    };
    LiveSensorGraph.startListeningInstantly();
  }

  @override
  void dispose() {
    LiveSensorGraph._refreshUI = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: ToggleButtons(
            isSelected: [_selectedContainer == 1, _selectedContainer == 2, _selectedContainer == 3],
            onPressed: (index) => setState(() => _selectedContainer = index + 1),
            borderRadius: BorderRadius.circular(8),
            constraints: const BoxConstraints(minHeight: 35, minWidth: 100),
            children: const [Text("Chicken Curry"), Text("Bicol Express"), Text("Menudo")],
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToggle("MQ135", const Color(0xFF0072B2), _show135, (v) => setState(() => _show135 = v)),
            _buildToggle("MQ136", const Color(0xFFD55E00), _show136, (v) => setState(() => _show136 = v)),
            _buildToggle("MQ137", const Color(0xFF009E73), _show137, (v) => setState(() => _show137 = v)),
          ],
        ),

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
                   leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: _leftTitleWidgets,
                    ),
                  ),
                ),
                lineBarsData: [
                  // ✅ 3. THE CRASH PREVENTER: 
                  // If a sensor is invisible (has 0 data), we don't try to draw it!
                  if (_show135 && LiveSensorGraph._globalData['c${_selectedContainer}_135']!.isNotEmpty) 
                    _buildLine(LiveSensorGraph._globalData['c${_selectedContainer}_135']!, const Color(0xFF0072B2)),
                    
                  if (_show136 && LiveSensorGraph._globalData['c${_selectedContainer}_136']!.isNotEmpty) 
                    _buildLine(LiveSensorGraph._globalData['c${_selectedContainer}_136']!, const Color(0xFFD55E00)),
                    
                  if (_show137 && LiveSensorGraph._globalData['c${_selectedContainer}_137']!.isNotEmpty) 
                    _buildLine(LiveSensorGraph._globalData['c${_selectedContainer}_137']!, const Color(0xFF009E73)),
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
      barWidth: 2, // Made the line slightly thicker so it's easier to see!
      
      // ✅ 4. THE DOT REVEALER: 
      // If a sensor gets exactly ONE reading before going back to zero, it will draw a nice dot so you can actually see it!
      dotData: const FlDotData(show: true), 
    );
  }
}