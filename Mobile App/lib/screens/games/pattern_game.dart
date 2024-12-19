part of '../games.dart';

class PatternGame extends StatefulWidget {
  const PatternGame({Key? key}) : super(key: key);

  @override
  _PatternGameState createState() => _PatternGameState();
}

class _PatternGameState extends State<PatternGame> {
  final List<String> shapes = ['🔵', '🔴', '🟡', '🟢'];
  List<String> pattern = [];
  List<String> userPattern = [];
  int level = 1;

  @override
  void initState() {
    super.initState();
    generatePattern();
  }

  void generatePattern() {
    pattern = List.generate(
      level + 2,
          (_) => shapes[math.Random().nextInt(shapes.length)],
    );
    userPattern = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Play'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Level $level', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pattern
                  .map((shape) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(shape, style: const TextStyle(fontSize: 40)),
              ))
                  .toList(),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: shapes.map((shape) => GestureDetector(
                onTap: () => addToPattern(shape),
                child: Text(shape, style: const TextStyle(fontSize: 40)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void addToPattern(String shape) {
    setState(() {
      userPattern.add(shape);
      if (userPattern.length == pattern.length) {
        checkPattern();
      }
    });
  }

  void checkPattern() {
    bool correct = true;
    for (int i = 0; i < pattern.length; i++) {
      if (pattern[i] != userPattern[i]) {
        correct = false;
        break;
      }
    }

    if (correct) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correct! 🎉'),
          content: const Text('Moving to next level!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  level++;
                  generatePattern();
                });
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Try Again'),
          content: const Text('Keep practicing!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  generatePattern();
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }
}