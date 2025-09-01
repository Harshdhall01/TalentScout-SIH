// widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsets? padding;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          padding: padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// widgets/test_card.dart
import 'package:flutter/material.dart';

class TestCard extends StatelessWidget {
  final String testName;
  final String description;
  final String duration;
  final IconData icon;
  final String instructions;
  final VoidCallback onTap;
  final bool isCompleted;
  final int? completedCount;

  const TestCard({
    Key? key,
    required this.testName,
    required this.description,
    required this.duration,
    required this.icon,
    required this.instructions,
    required this.onTap,
    this.isCompleted = false,
    this.completedCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Test Icon
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  
                  SizedBox(width: 16),
                  
                  // Test Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              testName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCompleted) ...[
                              SizedBox(width: 8),
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Duration Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Instructions
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        instructions,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Action Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (completedCount != null && completedCount! > 0)
                    Text(
                      'Completed $completedCount times',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    SizedBox(),
                  
                  Row(
                    children: [
                      Text(
                        'Start Test',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// widgets/loading_overlay.dart
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  if (message != null) ...[
                    SizedBox(height: 16),
                    Text(
                      message!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// widgets/performance_chart.dart
import 'package:flutter/material.dart';

class PerformanceChart extends StatelessWidget {
  final List<Map<String, dynamic>> testResults;
  final String testType;

  const PerformanceChart({
    Key? key,
    required this.testResults,
    required this.testType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredResults = testResults
        .where((result) => result['testType'] == testType)
        .toList();

    if (filteredResults.isEmpty) {
      return _buildNoDataWidget();
    }

    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Trend - ${_getTestDisplayName(testType)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _buildChart(filteredResults),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 50,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            Text(
              'No data for ${_getTestDisplayName(testType)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> results) {
    // Simple bar chart representation
    final maxScore = results
        .where((r) => r['score'] != null)
        .fold(0.0, (max, r) => r['score'] > max ? r['score'] : max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: results.asMap().entries.map((entry) {
        final index = entry.key;
        final result = entry.value;
        final score = result['score'] ?? 0.0;
        final height = maxScore > 0 ? (score / maxScore) * 120 : 20.0;

        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  score.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _getTestDisplayName(String testType) {
    switch (testType) {
      case 'situps':
        return 'Sit-ups';
      case 'vertical_jump':
        return 'Vertical Jump';
      case 'shuttle_run':
        return 'Shuttle Run';
      default:
        return testType;
    }
  }
}

// widgets/stats_card.dart
import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;

  const StatsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Colors.blue;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardColor.withOpacity(0.1),
              cardColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Spacer(),
                if (subtitle != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cardColor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// widgets/achievement_badge.dart
import 'package:flutter/material.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color? color;

  const AchievementBadge({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? Colors.orange;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? badgeColor : Colors.grey[300],
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: badgeColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? Colors.white : Colors.grey[500],
              size: 30,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.black : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2),
          Text(
            description,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}