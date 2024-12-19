part of '../detailed_metrics_page.dart';

class VitalSignsTab extends StatelessWidget {
  const VitalSignsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildVitalSignsGrid(),
          const SizedBox(height: 20),
          _buildVitalsTrendCard(),
        ],
      ),
    );
  }

  Widget _buildVitalSignsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: const [
        _VitalCard(
          title: 'Heart Rate',
          value: '72',
          unit: 'BPM',
          icon: Icons.favorite,
          color: Colors.red,
          trend: '+2',
        ),
        _VitalCard(
          title: 'Blood Pressure',
          value: '120/80',
          unit: 'mmHg',
          icon: Icons.speed,
          color: Colors.blue,
          trend: 'Normal',
        ),
        _VitalCard(
          title: 'SpO2',
          value: '98',
          unit: '%',
          icon: Icons.air,
          color: Colors.purple,
          trend: 'Optimal',
        ),
        _VitalCard(
          title: 'Temperature',
          value: '98.6',
          unit: '°F',
          icon: Icons.thermostat,
          color: Colors.orange,
          trend: 'Normal',
        ),
      ],
    );
  }

  Widget _buildVitalsTrendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Heart Rate Trend',
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
                            ['6am', '9am', '12pm', '3pm', '6pm', '9pm'][value.toInt() % 6],
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
                        const FlSpot(0, 70),
                        const FlSpot(1, 72),
                        const FlSpot(2, 75),
                        const FlSpot(3, 74),
                        const FlSpot(4, 71),
                        const FlSpot(5, 69),
                      ],
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
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
