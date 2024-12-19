part of 'widgets.dart';

Widget buildWelcomeMessage() {
  return Expanded(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: 0.6 + (value * 0.4),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              'assets/butterflies.gif',
              width: 150,
              height: 150,
            ),
          ),
          const SizedBox(height: 30),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "👋 Hi there! I'm B-BOT",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "You can interact with me in multiple ways:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureItem(Icons.mic, "Voice"),
                      const SizedBox(width: 30),
                      _buildFeatureItem(Icons.camera_alt, "Camera"),
                      const SizedBox(width: 30),
                      _buildFeatureItem(Icons.message, "Text"),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildFeatureItem(IconData icon, String label) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Colors.purple,
          size: 24,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(
          color: Colors.purple,
          fontSize: 14,
        ),
      ),
    ],
  );
}