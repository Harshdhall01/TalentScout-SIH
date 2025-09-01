import 'package:flutter/material.dart';

class TestSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Fitness Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Choose a fitness test to begin',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            
            // Sit-ups Test
            Card(
              child: ListTile(
                leading: Icon(Icons.fitness_center, color: Colors.blue),
                title: Text('Sit-ups Test'),
                subtitle: Text('Measure your core strength'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _navigateToTest(context, 'situps');
                },
              ),
            ),
            SizedBox(height: 16),
            
            // Vertical Jump Test
            Card(
              child: ListTile(
                leading: Icon(Icons.vertical_align_top, color: Colors.green),
                title: Text('Vertical Jump Test'),
                subtitle: Text('Test your explosive power'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _navigateToTest(context, 'vertical_jump');
                },
              ),
            ),
            SizedBox(height: 16),
            
            // Shuttle Run Test
            Card(
              child: ListTile(
                leading: Icon(Icons.directions_run, color: Colors.orange),
                title: Text('Shuttle Run Test'),
                subtitle: Text('Measure your agility and speed'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _navigateToTest(context, 'shuttle_run');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTest(BuildContext context, String testType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$testType test selected. Camera screen would open here.')),
    );
  }
}