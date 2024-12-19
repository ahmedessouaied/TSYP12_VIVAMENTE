part of '../games.dart';

class SocialStoriesGame extends StatefulWidget {
  const SocialStoriesGame({Key? key}) : super(key: key);

  @override
  _SocialStoriesGameState createState() => _SocialStoriesGameState();
}

class _SocialStoriesGameState extends State<SocialStoriesGame> {
  final List<Map<String, dynamic>> stories = [
    {
      'title': 'Making Friends',
      'scenario': 'You see someone playing with your favorite toy at school.',
      'options': [
        'Take the toy without asking',
        'Ask if you can play together',
        'Walk away sadly',
      ],
      'correctIndex': 1,
      'explanation': 'Asking to play together is a friendly way to make new friends!',
    },
    // Add more social scenarios
  ];

  int currentStoryIndex = 0;
  int? selectedOption;
  bool showExplanation = false;

  @override
  Widget build(BuildContext context) {
    final currentStory = stories[currentStoryIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Stories'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentStory['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              currentStory['scenario'],
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              currentStory['options'].length,
                  (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () => selectOption(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedOption == index
                        ? Colors.purpleAccent
                        : null,
                  ),
                  child: Text(currentStory['options'][index]),
                ),
              ),
            ),
            if (showExplanation) ...[
              const SizedBox(height: 20),
              Text(
                currentStory['explanation'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: nextStory,
                child: const Text('Next Story'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void selectOption(int index) {
    setState(() {
      selectedOption = index;
      showExplanation = true;
    });
  }

  void nextStory() {
    setState(() {
      if (currentStoryIndex < stories.length - 1) {
        currentStoryIndex++;
        selectedOption = null;
        showExplanation = false;
      } else {
        // Game completed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Great Job! 🎉'),
            content: const Text('You\'ve completed all the stories!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    currentStoryIndex = 0;
                    selectedOption = null;
                    showExplanation = false;
                  });
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
        );
      }
    });
  }
}
