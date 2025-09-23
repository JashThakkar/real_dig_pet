import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  final TextEditingController _nameController = TextEditingController();
  String petName = "Your Pet";
  static int happinessLevel = 50;
  int hungerLevel = 50;
  Timer? _hungerTimer;
  static const int _winThreshold = 80;
  static const Duration _winDuration = Duration(seconds: 60);
  Timer? _winTimer;
  bool _hasWon = false;
  bool _hasLost = false;
  int _energyLevel = 100;

  void _checkLoss() {
    if (_hasLost || _hasWon) return;

    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _hasLost = true;

      _hungerTimer?.cancel();
      _winTimer?.cancel();
      _winTimer = null;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text('Game Over 💀'),
            content: const Text('Your pet got too hungry and too sad.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Ok'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _updateWinTimer() {
    if (_hasWon) return;
    if (happinessLevel > _winThreshold) {
      _winTimer ??= Timer(_winDuration, _declareWin);
    } else {
      _winTimer?.cancel();
      _winTimer = null;
    }
  }

  void _declareWin() {
    _hasWon = true;
    _winTimer?.cancel();
    _winTimer = null;

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('You Win! 🎉'),
          content: const Text('Your pet stayed happy for 60 seconds!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Awesome'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateHunger();
    });
    _updateWinTimer();
  }

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      _energyLevel = (_energyLevel - 10).clamp(0, 100);
      _updateHunger();
    });
    _updateWinTimer();
    _checkLoss();
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 10;
      _energyLevel = (_energyLevel + 5).clamp(0, 100);
      _updateHappiness();
    });
    _updateWinTimer();
    _checkLoss();
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel -= 20;
    } else {
      happinessLevel += 10;
    }
    _updateWinTimer();
    _checkLoss();
  }

  void _updateHunger() {
    setState(() {
      hungerLevel += 5;
      _energyLevel = (_energyLevel - 5).clamp(0, 100);
      if (hungerLevel > 100) {
        hungerLevel = 100;
        happinessLevel -= 20;
      }
      _updateWinTimer();
    });
    _checkLoss();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 12.0),
            _moodShower(),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                _moodColor(_DigitalPetAppState.happinessLevel),
                BlendMode.modulate,
              ),
              child: Image.asset(
                'lib/assets/doggy.png',
                width: 200,
                height: 200,
              ),
            ),
            Text(
              'Name: $petName',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'New Name',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  petName = _nameController.text.isEmpty
                      ? petName
                      : _nameController.text;
                  _nameController.clear();
                });
              },
              child: Text('Update Name'),
            ),
            _energyBar(),
          ],
        ),
      ),
    );
  }

  IconData _moodIcon(int level) {
    if (level > 70) {
      return Icons.sentiment_very_satisfied;
    } else if (level >= 30) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_very_dissatisfied;
    }
  }

  Color _moodColor(happinessLevel) {
    if (happinessLevel > 70) {
      return Colors.green;
    } else if (happinessLevel >= 30) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  Widget _energyBar() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      const SizedBox(height: 16),
      const Text(
        'Energy',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: 260,
        child: LinearProgressIndicator(
          value: _energyLevel / 100.0,
          minHeight: 12,
          backgroundColor: Colors.black12,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
        ),
      ),
      const SizedBox(height: 8),
      Text('Energy Level: $_energyLevel'),
    ],
  );
}

  Widget _moodShower() {
    final level = happinessLevel;
    final color = _moodColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_moodIcon(level), color: color, size: 28),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
