part of '../detailed_metrics_page.dart';

class SleepTab extends StatelessWidget {
  const SleepTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSleepSummaryCard(),
          const SizedBox(height: 20),
          _buildSleepStagesCard(),
          const SizedBox(height: 20),
          _buildSleepTrendCard(),
        ],
      ),
    );
  }

  Widget _buildSleepSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sleep Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSleepMetric('Duration', '7h 30m'),
                _buildSleepMetric('Quality', '85%'),
                _buildSleepMetric('Efficiency', '92%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepMetric(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSleepStagesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sleep Stages',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.indigo,
                      value: 20,
                      title: 'Deep',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 45,
                      title: 'Light',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.purple,
                      value: 25,
                      title: 'REM',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.grey,
                      value: 10,
                      title: 'Awake',
                      radius: 50,
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

  Widget _buildSleepTrendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Sleep Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value.toInt() % 7],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 7.5),
                        const FlSpot(1, 6.8),
                        const FlSpot(2, 8.2),
                        const FlSpot(3, 7.0),
                        const FlSpot(4, 7.8),
                        const FlSpot(5, 8.5),
                        const FlSpot(6, 7.2),
                      ],
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
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
}

