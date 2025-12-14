import 'package:get/get.dart';
import 'package:koaa/app/data/models/local_transaction.dart';
import 'package:koaa/app/services/ml/koala_ml_engine.dart';
import 'package:koaa/app/services/ml/models/insight_generator.dart';

// Export types for consumers
export 'package:koaa/app/services/ml/models/insight_generator.dart';
export 'package:koaa/app/services/ml/models/anomaly_detector.dart';

class MLService {
  KoalaMLEngine? _engine;
  bool _mlScheduled = false;

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
      // Avoid triggering analysis on every UI call. Schedule one run in 5s if not already scheduled.
      if (!_mlScheduled) {
        _mlScheduled = true;
        Future.delayed(const Duration(seconds: 5), () async {
          try {
            await engine.runFullAnalysis(transactions, []);
          } catch (e) {
            // Swallow - engine should log internally
            print('Background ML analysis error: $e');
          } finally {
            _mlScheduled = false;
          }
        });
      }

      return engine.getInsights();
    } catch (e) {
      print('Error generating insights: $e');
      return [];
    }
  }

  // Backward compatibility methods if needed
  // ...
}
