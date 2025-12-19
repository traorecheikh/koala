import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:koaa/app/core/theme.dart'; // Import AppTheme

/// Static version of EnhancedBalanceCard for Homescreen Widget
class NativeBalanceWidget extends StatelessWidget {
  final double balance;
  final bool isDark;

  const NativeBalanceWidget({
    super.key,
    required this.balance,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Create a local theme wrapper to ensure consistent rendering
    final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    final gradient = LinearGradient(
      colors: isDark
          ? [Color(0xFF2E3B55), Color(0xFF1A1F2C)]
          : [Color(0xFF4C6EF5), Color(0xFF364FC7)], // Koala Primary Gradient
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Material(
        color: Colors.transparent,
        child: Container(
          width: 320, // Standard widget width approx
          height: 160,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(22), // 22dp matching Android XML
            gradient: gradient,
          ),
          child: Stack(
            children: [
              // Subtle particles static
              Positioned(
                right: -20,
                top: -20,
                child: Icon(CupertinoIcons.sparkles,
                    size: 80, color: Colors.white.withOpacity(0.05)),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SOLDE ACTUEL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Spacer(),
                        Icon(CupertinoIcons.chart_pie_fill,
                            color: Colors.white70, size: 16),
                      ],
                    ),
                    Text(
                      NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA')
                          .format(balance),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32, // Large readable
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Row(
                      children: [
                        Icon(CupertinoIcons.arrow_up_right,
                            color: Color(0xFF40C057), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Mis à jour à l\'instant',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static Action Button for QuickAdd Widget (Expense/Income)
class NativeQuickAddButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const NativeQuickAddButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // We render this as a small 100x100 or similar square to be placed in the widget
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: Container(
          height: 100,
          width: 100, // Aspect ratio 1:1 roughly
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static Today Spending Widget
class NativeTodayWidget extends StatelessWidget {
  final double amount;
  final bool isDark;

  const NativeTodayWidget({
    super.key,
    required this.amount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? Color(0xFF2B2C30) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          height: 100,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DÉPENSES DU JOUR',
                    style: TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(locale: 'fr_FR', symbol: '')
                            .format(amount) +
                        ' F',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFA5252).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.graph_square_fill,
                    color: Color(0xFFFA5252), size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
