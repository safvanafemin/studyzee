import 'package:flutter/material.dart';

enum SnackBarStatus { success, error, warning, normal }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarStatus status,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getSnackBarConfig(status);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: duration,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  static _SnackBarConfig _getSnackBarConfig(SnackBarStatus status) {
    switch (status) {
      case SnackBarStatus.success:
        return _SnackBarConfig(
          color: const Color(0xFF4CAF50),
          icon: Icons.check_circle,
        );
      case SnackBarStatus.error:
        return _SnackBarConfig(
          color: const Color(0xFFE53935),
          icon: Icons.error,
        );
      case SnackBarStatus.warning:
        return _SnackBarConfig(
          color: const Color(0xFFFFA726),
          icon: Icons.warning,
        );
      case SnackBarStatus.normal:
        return _SnackBarConfig(
          color: const Color(0xFF607D8B),
          icon: Icons.info,
        );
    }
  }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  _SnackBarConfig({
    required this.color,
    required this.icon,
  });
}

// Example usage
class SnackBarDemo extends StatelessWidget {
  const SnackBarDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom SnackBar Demo'),
        backgroundColor: const Color(0xFF6200EA),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: 'Operation completed successfully!',
                  status: SnackBarStatus.success,
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Show Success'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: 'Something went wrong!',
                  status: SnackBarStatus.error,
                );
              },
              icon: const Icon(Icons.error),
              label: const Text('Show Error'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: 'Please be careful with this action!',
                  status: SnackBarStatus.warning,
                );
              },
              icon: const Icon(Icons.warning),
              label: const Text('Show Warning'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA726),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                CustomSnackBar.show(
                  context,
                  message: 'This is a normal notification',
                  status: SnackBarStatus.normal,
                );
              },
              icon: const Icon(Icons.info),
              label: const Text('Show Normal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF607D8B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}