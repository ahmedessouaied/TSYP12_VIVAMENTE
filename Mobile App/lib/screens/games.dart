import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:confetti/confetti.dart';
import 'package:just_audio/just_audio.dart';

import '../widgets/widgets.dart';

part './games/emotion_match_game.dart';
part './games/pattern_game.dart';
part './games/memory_game.dart';
part './games/calm_corner_game.dart';
part './games/social_stories_game.dart';
part './games/sensory_sorting_game.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _CalmingGamesState();
}

class _CalmingGamesState extends State<GamesPage> {
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    init();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  Future<void> init() async {
    await _audioPlayer.setAsset('assets/music/pop.mp3');
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fun Games'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        padding: const EdgeInsets.all(16.0),
        children: [
          const GameCard(
            title: 'Emotion Match',
            description: 'Match emotions with situations',
            gameWidget: EmotionMatchGame(),
            icon: Icons.emoji_emotions,
          ),
          const GameCard(
            title: 'Pattern Play',
            description: 'Complete the pattern sequence',
            gameWidget: PatternGame(),
            icon: Icons.grid_on,
          ),
          const GameCard(
            title: 'Memory Cards',
            description: 'Find matching pairs',
            gameWidget: MemoryGame(),
            icon: Icons.memory,
          ),
          const GameCard(
            title: 'Calm Corner',
            description: 'Interactive relaxation activities',
            gameWidget: CalmCornerGame(),
            icon: Icons.spa,
          ),
          const GameCard(
            title: 'Social Stories',
            description: 'Learn about social situations',
            gameWidget: SocialStoriesGame(),
            icon: Icons.people,
          ),
          const GameCard(
            title: 'Sensory Sort',
            description: 'Sort items by how they feel',
            gameWidget: SensorySortingGame(),
            icon: Icons.category,
          ),
          _buildGameCard(
            'Bubble Pop',
            Icons.bubble_chart,
            'Pop peaceful bubbles',
                () => _showBubbleGame(context),
          ),
          _buildGameCard(
            'Memory Match 2.0',
            Icons.grid_view,
            'Match calming pairs',
                () => _showMemoryGame(context),
          ),
          _buildGameCard(
            'Paint Canvas',
            Icons.brush,
            'Create peaceful art',
                () => _showPaintGame(context),
          ),
          _buildGameCard(
            'Shape Sorter',
            Icons.format_shapes,
            'Sort shapes gently',
                () => _showShapeSorter(context),
          ),
          _buildGameCard(
            'Puzzle Slide',
            Icons.extension,
            'Arrange the pieces',
                () => _showPuzzleSlide(context),
          ),
          _buildGameCard(
            'Star Catcher',
            Icons.star,
            'Catch falling stars',
                () => _showStarCatcher(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(
      String title,
      IconData icon,
      String description,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.purpleAccent),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBubbleGame(BuildContext context) {
    List<Bubble> bubbles = [];
    final random = math.Random();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => Stack(
              children: [
                ...bubbles.map((bubble) => Positioned(
                  left: bubble.x,
                  top: bubble.y,
                  child: GestureDetector(
                    onTapDown: (_) {
                      setState(() {
                        bubbles.remove(bubble);
                        _confettiController.play();
                      });
                      _audioPlayer.setAsset('assets/music/pop.mp3');
                      _audioPlayer.play();
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: bubble.opacity,
                      child: Container(
                        width: bubble.size,
                        height: bubble.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purpleAccent.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                )),
                Positioned(
                  top: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (bubbles.length < 10) {
                          bubbles.add(
                            Bubble(
                              x: random.nextDouble() * 300,
                              y: random.nextDouble() * 400,
                              size: random.nextDouble() * 30 + 30,
                              opacity: random.nextDouble() * 0.5 + 0.5,
                            ),
                          );
                        }
                      });
                    },
                    child: const Text('Add Bubble'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMemoryGame(BuildContext context) {
    final List<String> emojis = ['🌸', '🌺', '🌻', '🌼', '🌷', '🌹', '🍀', '🌿'];
    final List<String> gameEmojis = [...emojis, ...emojis]..shuffle();
    List<bool> flipped = List.generate(16, (index) => false);
    List<bool> matched = List.generate(16, (index) => false);
    int? firstChoice;
    bool canFlip = true;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                const Text(
                  'Memory Match',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (!canFlip || flipped[index] || matched[index]) return;

                          setState(() {
                            flipped[index] = true;

                            if (firstChoice == null) {
                              firstChoice = index;
                            } else {
                              canFlip = false;
                              if (gameEmojis[firstChoice!] == gameEmojis[index]) {
                                matched[firstChoice!] = true;
                                matched[index] = true;
                                firstChoice = null;
                                canFlip = true;

                                // Check if all matched
                                if (matched.every((element) => element)) {
                                  _confettiController.play();
                                }
                              } else {
                                Future.delayed(const Duration(milliseconds: 1000), () {
                                  setState(() {
                                    flipped[firstChoice!] = false;
                                    flipped[index] = false;
                                    firstChoice = null;
                                    canFlip = true;
                                  });
                                });
                              }
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: matched[index]
                                ? Colors.green.withOpacity(0.3)
                                : flipped[index]
                                ? Colors.white
                                : Colors.purpleAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              flipped[index] || matched[index]
                                  ? gameEmojis[index]
                                  : '',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPaintGame(BuildContext context) {
    List<DrawingPoint> points = [];
    Color selectedColor = Colors.purpleAccent;
    double strokeWidth = 5;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final color in [
                      Colors.purple,
                      Colors.pink,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                    ])
                      GestureDetector(
                        onTap: () => setState(() => selectedColor = color),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: selectedColor == color ? 3 : 1,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => setState(() => points.clear()),
                    ),
                  ],
                ),
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        points.add(
                          DrawingPoint(
                            details.localPosition,
                            Paint()
                              ..color = selectedColor
                              ..strokeWidth = strokeWidth
                              ..strokeCap = StrokeCap.round,
                          ),
                        );
                      });
                    },
                    child: CustomPaint(
                      painter: DrawingPainter(points),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShapeSorter(BuildContext context) {
    final shapes = [
      {'shape': 'circle', 'color': Colors.red},
      {'shape': 'square', 'color': Colors.blue},
      {'shape': 'triangle', 'color': Colors.green},
    ];

    List<Map<String, dynamic>> currentShapes = [];
    int score = 0;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: shapes.map((shape) {
                            return DragTarget<Map<String, dynamic>>(
                              onAcceptWithDetails: (data) {
                                setState(() {
                                  if (data.data['shape'] == shape['shape']) {
                                    score += 10;
                                    currentShapes.remove(data.data);
                                    _confettiController.play();
                                  }
                                });
                              },
                              builder: (context, accepted, rejected) {
                                return Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: shape['color'] as Color,
                                      width: 2,
                                    ),
                                    shape: shape['shape'] == 'circle'
                                        ? BoxShape.circle
                                        : BoxShape.rectangle,
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      ...currentShapes.map((shape) {
                        return Positioned(
                          left: shape['x'] as double,
                          top: shape['y'] as double,
                          child: Draggable<Map<String, dynamic>>(
                            data: shape,
                            feedback: _buildShape(shape),
                            childWhenDragging: Container(),
                            child: _buildShape(shape),
                          ),
                        );
                      }),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (currentShapes.length < 5) {
                                final shape = shapes[math.Random().nextInt(shapes.length)];
                                currentShapes.add({
                                  ...shape,
                                  'x': math.Random().nextDouble() * 200,
                                  'y': math.Random().nextDouble() * 200,
                                });
                              }
                            });
                          },
                          child: const Text('Add Shape'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShape(Map<String, dynamic> shape) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: shape['color'] as Color,
        shape: shape['shape'] == 'circle' ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  void _showPuzzleSlide(BuildContext context) {
    const int gridSize = 3;
    List<int?> tiles = List.generate(gridSize * gridSize - 1, (index) => index + 1)..add(null);
    tiles.shuffle();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                const Text(
                  'Puzzle Slide',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: tiles.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          final emptyIndex = tiles.indexOf(null);
                          if (_canMoveTile(index, emptyIndex, gridSize)) {
                            setState(() {
                              tiles[emptyIndex] = tiles[index];
                              tiles[index] = null;

                              // Check if puzzle is solved
                              bool isSolved = true;
                              for (int i = 0; i < tiles.length - 1; i++) {
                                if (tiles[i] != i + 1) {
                                  isSolved = false;
                                  break;
                                }
                              }
                              if (isSolved) {
                                _confettiController.play();
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Congratulations! Puzzle solved!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: tiles[index] == null
                                ? Colors.white
                                : Colors.purpleAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              tiles[index]?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tiles.shuffle();
                    });
                  },
                  child: const Text('Shuffle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canMoveTile(int currentIndex, int emptyIndex, int gridSize) {
    // Check if the tile is adjacent to the empty space
    final row = currentIndex ~/ gridSize;
    final col = currentIndex % gridSize;
    final emptyRow = emptyIndex ~/ gridSize;
    final emptyCol = emptyIndex % gridSize;

    return (row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1);
  }

  void _showStarCatcher(BuildContext context) {
    List<Star> stars = [];
    int score = 0;
    double basketPosition = 0.5;
    bool isPlaying = false;
    Timer? gameTimer;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: StatefulBuilder(
            builder: (context, setState) {
              if (gameTimer == null && isPlaying) {
                gameTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
                  setState(() {
                    // Move stars down
                    for (var star in stars) {
                      star.y += 2;

                      // Check if star is caught
                      if (star.y > MediaQuery.of(context).size.height * 0.6 &&
                          star.y < MediaQuery.of(context).size.height * 0.7 &&
                          (star.x - basketPosition * MediaQuery.of(context).size.width).abs() < 50) {
                        score += 10;
                        stars.remove(star);
                        _confettiController.play();
                        break;
                      }

                      // Remove stars that fall off screen
                      if (star.y > MediaQuery.of(context).size.height) {
                        stars.remove(star);
                        break;
                      }
                    }

                    // Add new stars randomly
                    if (math.Random().nextDouble() < 0.02 && stars.length < 10) {
                      stars.add(Star(
                        x: math.Random().nextDouble() * MediaQuery.of(context).size.width,
                        y: 0,
                      ));
                    }
                  });
                });
              }

              return Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Text(
                      'Score: $score',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...stars.map((star) => Positioned(
                    left: star.x,
                    top: star.y,
                    child: const Icon(Icons.star, color: Colors.yellow, size: 30),
                  )),
                  Positioned(
                    bottom: 100,
                    left: basketPosition * MediaQuery.of(context).size.width - 25,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.purpleAccent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Slider(
                      value: basketPosition,
                      onChanged: (value) {
                        setState(() {
                          basketPosition = value;
                        });
                      },
                    ),
                  ),
                  if (!isPlaying)
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isPlaying = true;
                            score = 0;
                            stars.clear();
                          });
                        },
                        child: const Text('Start Game'),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    ).then((_) {
      gameTimer?.cancel();
    });
  }
}

class Bubble {
  final double x;
  final double y;
  final double size;
  final double opacity;

  Bubble({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint(this.offset, this.paint);
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (var point in points) {
      canvas.drawCircle(point.offset, point.paint.strokeWidth / 2, point.paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Star {
  double x;
  double y;

  Star({required this.x, required this.y});
}