part of '../games.dart';

class EmotionMatchGame extends StatefulWidget {
  const EmotionMatchGame({Key? key}) : super(key: key);

  @override
  _EmotionMatchGameState createState() => _EmotionMatchGameState();
}

class _EmotionMatchGameState extends State<EmotionMatchGame> {
  final List<Map<String, dynamic>> emotions = [
    {'emotion': 'Happy', 'situation': 'Getting ice cream', 'icon': '😊'},
    {'emotion': 'Sad', 'situation': 'Lost a toy', 'icon': '😢'},
    {'emotion': 'Excited', 'situation': 'Going to the park', 'icon': '🎉'},
    {'emotion': 'Calm', 'situation': 'Reading a book', 'icon': '😌'},
  ];

  String? selectedEmotion;
  String? selectedSituation;
  int score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Match'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Score: $score', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: emotions.map((emotion) => Card(
                      child: ListTile(
                        leading: Text(emotion['icon'], style: const TextStyle(fontSize: 24)),
                        title: Text(emotion['emotion']),
                        onTap: () => setState(() => selectedEmotion = emotion['emotion']),
                        selected: selectedEmotion == emotion['emotion'],
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: emotions.map((emotion) => Card(
                      child: ListTile(
                        title: Text(emotion['situation']),
                        onTap: () {
                          setState(() {
                            selectedSituation = emotion['situation'];
                            checkMatch(emotion);
                          });
                        },
                        selected: selectedSituation == emotion['situation'],
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void checkMatch(Map<String, dynamic> emotion) {
    if (selectedEmotion == emotion['emotion'] &&
        selectedSituation == emotion['situation']) {
      setState(() {
        score += 1;
        selectedEmotion = null;
        selectedSituation = null;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Correct! 🎉'),
          content: Text('Great job matching ${emotion['emotion']}!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }
  }
}