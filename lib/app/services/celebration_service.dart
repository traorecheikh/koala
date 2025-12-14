import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:koaa/app/services/events/financial_events_service.dart';
import 'dart:async'; // Added import for StreamSubscription

class CelebrationService extends GetxService {
  late FinancialEventsService _financialEventsService;
  late StreamSubscription _eventSubscription; // Store the subscription
  
  // Controller for confetti animation, typically managed by a UI overlay
  // But we can emit events that UI components listen to to trigger animations.
  // For simplicity, we'll use Get.snackbar or dialogs with animations for now.

  @override
  void onInit() {
    super.onInit();
    _financialEventsService = Get.find<FinancialEventsService>();
    _listenToCelebrationEvents();
  }

  @override
  void onClose() {
    _eventSubscription.cancel(); // Cancel the subscription
    super.onClose();
  }

  void _listenToCelebrationEvents() {
    // Listen for Goal Completion
    _eventSubscription = _financialEventsService.onEvent().listen((event) {
      if (event.type == FinancialEventType.goalCompleted) {
        _showCelebration(
          title: 'Félicitations ! 🎉',
          message: 'Vous avez atteint votre objectif !',
          icon: Icons.emoji_events,
          color: Colors.amber,
        );
      } else if (event.type == FinancialEventType.goalMilestoneReached) {
        _showCelebration(
          title: 'Cap franchi ! 🚀',
          message: 'Vous progressez vers votre objectif.',
          icon: Icons.trending_up,
          color: Colors.blue,
        );
      } else if (event.type == FinancialEventType.debtPaidOff) {
        _showCelebration(
          title: 'Liberté ! 💸',
          message: 'Une dette a été entièrement remboursée.',
          icon: Icons.check_circle,
          color: Colors.green,
        );
      }
    });
  }

  void _showCelebration({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    // Show a top snackbar with celebration style
    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: Colors.white, size: 32),
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 16,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 500),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
    
    // In a more advanced implementation, we could trigger a confetti overlay here
    // using a global OverlayEntry or a dedicated CelebrationView wrapper.
  }
}
