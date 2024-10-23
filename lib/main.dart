import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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
    _startFishMovement();
  }

  void _startFishMovement() {
    // Move fish periodically every 50 milliseconds
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
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Aquarium')),
      body: Column(
        children: [
          // The container representing the aquarium
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
              // Button to add a new fish
              ElevatedButton(onPressed: _addFish, child: Text('Add Fish')),
              // Button to remove the last fish
              ElevatedButton(onPressed: _removeFish, child: Text('Remove Fish')),
              ElevatedButton(onPressed: _saveSettings, child: Text('Save Settings')),
            ],
          ),
          // Slider to adjust the fish swimming speed
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
          // Dropdown menu to select the fish color
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
    // Limit the number of fish to 10
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: speed));
      });
    } else {
      // Display a message when the fish limit is reached
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fish limit reached!')),
      );
    }
  }

  void _removeFish() {
    if (fishList.isNotEmpty) {
      setState(() {
        fishList.removeLast(); // Removes the last fish added
      });
    } else {
      // Display a message when there are no fish to remove
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No fish to remove!')),
      );
    }
  }

  void _saveSettings() {
    // Save fish count, color, and speed using local storage (to be implemented in next steps)
  }
}

class Fish {
  final Color color;
  final double speed;
  Offset position;
  Offset direction;

  Fish({required this.color, required this.speed})
      : position = Offset(150, 150), // Initial position at the center of the aquarium
        direction = Offset(
            Random().nextDouble() * 2 - 1, Random().nextDouble() * 2 - 1); // Random direction

  void move() {
    // Move the fish by its speed and direction
    position = Offset(
      position.dx + direction.dx * speed,
      position.dy + direction.dy * speed,
    );

    // Check if the fish hits the container boundaries (300x300)
    if (position.dx <= 0 || position.dx >= 280) {
      direction = Offset(-direction.dx, direction.dy); // Reverse horizontal direction
    }
    if (position.dy <= 0 || position.dy >= 280) {
      direction = Offset(direction.dx, -direction.dy); // Reverse vertical direction
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
