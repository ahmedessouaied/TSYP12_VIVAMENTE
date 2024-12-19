part of '../games.dart';

class CalmCornerGame extends StatefulWidget {
  const CalmCornerGame({super.key});

  @override
  State<CalmCornerGame> createState() => _CalmCornerGameState();
}

class _CalmCornerGameState extends State<CalmCornerGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  bool isBreathing = false;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOut,
      ),
    );

    _breathingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathingController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _breathingController.forward();
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calm Corner'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Welcome to your calm space',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  _buildActivityCard(
                    'Breathing Bubble',
                    Icons.circle_outlined,
                        () => _showBreathingExercise(context),
                  ),
                  _buildActivityCard(
                    'Calming Sounds',
                    Icons.music_note,
                        () => _showSoundBoard(context),
                  ),
                  _buildActivityCard(
                    'Color Flow',
                    Icons.palette,
                        () => _showColorFlow(context),
                  ),
                  _buildActivityCard(
                    'Gentle Garden',
                    Icons.local_florist,
                        () => _showGarden(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.purpleAccent),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showBreathingExercise(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Breathe with the bubble',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _breathingAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purpleAccent.withOpacity(0.3),
                        border: Border.all(
                          color: Colors.purpleAccent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isBreathing = !isBreathing;
                    if (isBreathing) {
                      _breathingController.forward();
                    } else {
                      _breathingController.stop();
                    }
                  });
                },
                child: Text(isBreathing ? 'Stop' : 'Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoundBoard(BuildContext context) {
    final sounds = [
      {'name': 'Rain', 'icon': Icons.water_drop},
      {'name': 'Ocean', 'icon': Icons.waves},
      {'name': 'Birds', 'icon': Icons.flutter_dash},
      {'name': 'White Noise', 'icon': Icons.noise_control_off},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Calming Sounds', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: sounds.map((sound) => Column(
                  children: [
                    IconButton(
                      icon: Icon(sound['icon'] as IconData),
                      onPressed: () {
                        // Implement sound playing functionality
                      },
                    ),
                    Text(sound['name'] as String),
                  ],
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorFlow(BuildContext context) {
    final colors = [
      Colors.purple[100],
      Colors.purple[200],
      Colors.purple[300],
      Colors.purple[400],
      Colors.purpleAccent,
    ];
    int currentColorIndex = 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Color Flow', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) => GestureDetector(
                  onTap: () {
                    setState(() {
                      currentColorIndex = (currentColorIndex + 1) % colors.length;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: colors[currentColorIndex],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Tap to change color',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Focus on the changing colors\nand let your mind relax',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGarden(BuildContext context) {
    final List<Map<String, dynamic>> plants = [
      {'name': 'Peaceful Lily', 'grown': false, 'icon': Icons.local_florist},
      {'name': 'Serene Sunflower', 'grown': false, 'icon': Icons.yard},
      {'name': 'Tranquil Tree', 'grown': false, 'icon': Icons.park},
      {'name': 'Calming Cactus', 'grown': false, 'icon': Icons.nature},
    ];

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gentle Garden', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) => Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: plants.map((plant) => Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            plant['grown'] = !plant['grown'];
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: plant['grown']
                                ? Colors.purpleAccent.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            plant['icon'] as IconData,
                            size: 40,
                            color: plant['grown']
                                ? Colors.purpleAccent
                                : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        plant['name'] as String,
                        style: TextStyle(
                          color: plant['grown']
                              ? Colors.purpleAccent
                              : Colors.grey,
                        ),
                      ),
                    ],
                  )).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tap to grow your garden\nWatch your peaceful space bloom',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
