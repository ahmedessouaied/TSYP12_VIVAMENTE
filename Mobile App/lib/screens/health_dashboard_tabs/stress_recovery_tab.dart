part of '../detailed_metrics_page.dart';

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDailyGoalsCard(),
          const SizedBox(height: 20),
          _buildActivityMetricsCard(),
          const SizedBox(height: 20),
          _buildWeeklyActivityChart(),
        ],
      ),
    );
  }

  Widget _buildDailyGoalsCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Goals',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _GoalProgressBar(
              label: 'Steps',
              current: 8500,
              target: 10000,
              color: Colors.blue,
            ),
            SizedBox(height: 12),
            _GoalProgressBar(
              label: 'Active Minutes',
              current: 45,
              target: 60,
              color: Colors.green,
            ),
            SizedBox(height: 12),
            _GoalProgressBar(
              label: 'Calories',
              current: 1800,
              target: 2500,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityMetricsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricColumn('Distance', '5.2', 'km'),
                _buildMetricColumn('Floors', '12', 'floors'),
                _buildMetricColumn('Active Time', '45', 'min'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(unit),
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

  Widget _buildWeeklyActivityChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 12000,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value.toInt()],
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeBarGroup(0, 8500),
                    _makeBarGroup(1, 10200),
                    _makeBarGroup(2, 7800),
                    _makeBarGroup(3, 9300),
                    _makeBarGroup(4, 11000),
                    _makeBarGroup(5, 6500),
                    _makeBarGroup(6, 8000),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue,
          width: 15,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
