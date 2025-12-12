import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/models/insight_generator.dart';

// Export types for consumers
export 'package:koaa/app/services/ml/models/insight_generator.dart';
export 'package:koaa/app/services/ml/models/anomaly_detector.dart';

class MLService {
  KoalaMLEngine? _engine;

  KoalaMLEngine get engine {
    if (_engine == null) {
      try {
        _engine = Get.find<KoalaMLEngine>();
      } catch (e) {
        // Fallback or rethrow. If initialized in main, should be found.
        print('KoalaMLEngine not found: $e');
      }
    }
    return _engine!;
  }

  /// Generate insights based on transactions
  /// This bridges the synchronous call from HomeController to the async Engine
  List<MLInsight> generateInsights(List<LocalTransaction> transactions) {
    if (transactions.isEmpty) return [];

    try {
      // Trigger analysis in background
      // In a real app, we'd want to avoid running this on every UI rebuild
      // But KoalaMLEngine should handle debouncing or efficiency
      
      // We assume the engine has been initialized and maybe run once.
      // If we want real-time updates, we should await this or use a stream.
      // For now, return whatever is current, and trigger an update.
      
      // We can't await here because the signature is synchronous to match old API.
      // But we can fire-and-forget an update.
      engine.runFullAnalysis(transactions, []); // Goals missing for now
      
      return engine.getInsights();
    } catch (e) {
      print('Error generating insights: $e');
      return [];
    }
  }

  // Backward compatibility methods if needed
  // ...
}
