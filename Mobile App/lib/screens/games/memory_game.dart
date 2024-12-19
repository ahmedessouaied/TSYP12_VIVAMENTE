part of '../games.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> emojis = ['🐶', '🐱', '🐰', '🐨', '🐯', '🦁', '🐸', '🐢'];
  late List<String> cards;
  List<bool> flipped = [];
  int? firstFlippedIndex;
  bool canFlip = true;
  int matches = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    cards = [...emojis, ...emojis];
    cards.shuffle();
    flipped = List.generate(cards.length, (_) => false);
    matches = 0;
    firstFlippedIndex = null;
    canFlip = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Cards'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Matches: $matches', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => flipCard(index),
                  child: Card(
                    color: flipped[index] ? Colors.white : Colors.purpleAccent,
                    child: Center(
                      child: flipped[index]
                          ? Text(cards[index],
                          style: const TextStyle(fontSize: 32))
                          : const Text('?',
                          style: TextStyle(fontSize: 32, color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void flipCard(int index) {
    if (!canFlip || flipped[index]) return;

    setState(() {
      flipped[index] = true;

      if (firstFlippedIndex == null) {
        firstFlippedIndex = index;
      } else {
        canFlip = false;
        checkMatch(firstFlippedIndex!, index);
      }
    });
  }

  void checkMatch(int first, int second) {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (cards[first] == cards[second]) {
          matches++;
          if (matches == emojis.length) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Congratulations! 🎉'),
                content: const Text('You won! Want to play again?'),
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
        } else {
          flipped[first] = false;
          flipped[second] = false;
        }
        firstFlippedIndex = null;
        canFlip = true;
      });
    });
  }
}