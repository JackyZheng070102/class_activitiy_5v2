import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AquariumPage(),
    );
  }
}

class AquariumPage extends StatefulWidget {
  @override
  _AquariumPageState createState() => _AquariumPageState();
}

class _AquariumPageState extends State<AquariumPage> {
  List<Fish> fishList = [];
  double speed = 1.0;
  Color selectedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Aquarium')),
      body: Column(
        children: [
          Container(
            width: 300,
            height: 300,
            color: Colors.lightBlueAccent,
            child: Stack(
              children: fishList.map((fish) => fish.build(context)).toList(),
            ),
          ),
          Row(
            children: [
              ElevatedButton(onPressed: _addFish, child: Text('Add Fish')),
              ElevatedButton(onPressed: _saveSettings, child: Text('Save Settings')),
            ],
          ),
          Slider(
            value: speed,
            min: 0.5,
            max: 5.0,
            onChanged: (value) {
              setState(() {
                speed = value;
              });
            },
          ),
          DropdownButton<Color>(
            value: selectedColor,
            onChanged: (Color? newColor) {
              setState(() {
                if (newColor != null) {
                  selectedColor = newColor;
                }
              });
            },
            items: [
              DropdownMenuItem(value: Colors.blue, child: Text("Blue")),
              DropdownMenuItem(value: Colors.red, child: Text("Red")),
              DropdownMenuItem(value: Colors.green, child: Text("Green")),
            ],
          ),
        ],
      ),
    );
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: speed));
      });
    }
  }

  void _saveSettings() {
    // Save fish count, color, and speed using local storage (to be implemented in the next step)
  }
}

class Fish {
  final Color color;
  final double speed;
  Offset position;

  Fish({required this.color, required this.speed}) : position = Offset(150, 150);

  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: (1000 / speed).toInt()),
      top: position.dy,
      left: position.dx,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
