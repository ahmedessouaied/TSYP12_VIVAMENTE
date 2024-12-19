part of 'widgets.dart';

class CustomLoadingScreen extends StatelessWidget {
  final String message;
  final Color indicatorColor;

  const CustomLoadingScreen({
    super.key,
    this.message = "...",
    this.indicatorColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.cardColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo at the top
            Image.asset(
              'assets/images/logo.png',
              height: 100, // Adjust the height based on your logo size
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24), // Space between logo and the progress indicator
            CircularProgressIndicator(
              color: indicatorColor,
              strokeWidth: 4.0, // Optional: Adjust thickness
            ),
            const SizedBox(height: 24), // Space between indicator and message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500, // Slightly bolder text for better visibility
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
