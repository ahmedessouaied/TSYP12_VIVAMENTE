part of '../games.dart';

class SensorySortingGame extends StatefulWidget {
  const SensorySortingGame({Key? key}) : super(key: key);

  @override
  _SensorySortingGameState createState() => _SensorySortingGameState();
}

class _SensorySortingGameState extends State<SensorySortingGame> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Soft Things',
      'items': ['Pillow', 'Cotton', 'Feather', 'Blanket'],
      'icon': '🧸',
    },
    {
      'name': 'Hard Things',
      'items': ['Rock', 'Wood', 'Metal', 'Plastic'],
      'icon': '🪨',
    },
    {
      'name': 'Smooth Things',
      'items': ['Glass', 'Ice', 'Mirror', 'Silk'],
      'icon': '🪞',
    },
  ];

  Map<String, List<String>> sortedItems = {};
  List<String> unsortedItems = [];

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    sortedItems = {for (var cat in categories) cat['name']: []};
    unsortedItems = categories
        .expand((cat) => cat['items'] as List<String>)
        .toList()..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensory Sorting'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return DragTarget<String>(
                  onWillAccept: (data) => true,
                  onAccept: (data) {
                    setState(() {
                      if ((category['items'] as List<String>).contains(data)) {
                        sortedItems[category['name']]!.add(data);
                        unsortedItems.remove(data);
                        checkGameCompletion();
                      }
                    });
                  },
                  builder: (context, candidates, rejects) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: candidates.isNotEmpty
                              ? Colors.purpleAccent
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Text(category['icon'], style: const TextStyle(fontSize: 24)),
                        title: Text(category['name']),
                        subtitle: Wrap(
                          children: sortedItems[category['name']]!
                              .map((item) => Chip(label: Text(item)))
                              .toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: unsortedItems.map((item) => Draggable<String>(
                data: item,
                feedback: Material(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                childWhenDragging: Container(),
                child: Chip(label: Text(item)),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void checkGameCompletion() {
    bool allSorted = unsortedItems.isEmpty;
    if (allSorted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fantastic! 🎉'),
          content: const Text('You\'ve sorted everything correctly!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  initializeGame();
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }
}
