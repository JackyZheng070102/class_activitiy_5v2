import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_helper.dart'; // Import the database helper

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _startFishMovement();
  }

  void _startFishMovement() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        for (var fish in fishList) {
          fish.move();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    await DatabaseHelper().saveSettings(
      fishList.length,
      speed,
      selectedColor.toString(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Settings saved!')),
    );
  }

  Future<void> _loadSettings() async {
    Map<String, dynamic> settings = await DatabaseHelper().loadSettings();
    if (settings.isNotEmpty) {
      setState(() {
        int fishCount = settings['fishCount'];
        speed = settings['speed'];
        selectedColor = _stringToColor(settings['color']);

        // Repopulate the fish list based on saved settings
        fishList = List.generate(fishCount, (index) {
          return Fish(color: selectedColor, speed: speed);
        });
      });
    }
  }

  Color _stringToColor(String colorString) {
    switch (colorString) {
      case 'Color(0xff2196f3)':
        return Colors.blue;
      case 'Color(0xfff44336)':
        return Colors.red;
      case 'Color(0xff4caf50)':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

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
              ElevatedButton(onPressed: _removeFish, child: Text('Remove Fish')),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fish limit reached!')),
      );
    }
  }

  void _removeFish() {
    if (fishList.isNotEmpty) {
      setState(() {
        fishList.removeLast();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fish to remove!')),
      );
    }
  }
}

class Fish {
  final Color color;
  final double speed;
  Offset position;
  Offset direction;

  Fish({required this.color, required this.speed})
      : position = Offset(150, 150),
        direction = Offset(
            Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1);

  void move() {
    position = Offset(
      position.dx + direction.dx * speed,
      position.dy + direction.dy * speed,
    );
    if (position.dx <= 0 || position.dx >= 280) {
      direction = Offset(-direction.dx, direction.dy);
    }
    if (position.dy <= 0 || position.dy >= 280) {
      direction = Offset(direction.dx, -direction.dy);
    }
  }

  Widget build(BuildContext context) {
    return Positioned(
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
