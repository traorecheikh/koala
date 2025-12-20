import 'package:get/get.dart';
import 'package:koaa/app/data/models/envelope.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:koaa/app/services/isar_service.dart';
import 'package:logger/logger.dart';

class EnvelopeService extends GetxService {
  final _logger = Logger();

  final envelopes = <Envelope>[].obs;
  final totalAllocated = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialization is called manually from ServiceInitializer usually,
    // or we can init here if not deferred.
  }

  Future<void> init() async {
    _logger.i('Initializing EnvelopeService...');

    // Load initial data
    _loadEnvelopes();

    // Listen to changes
    IsarService.watchEnvelopes().listen((data) {
      envelopes.assignAll(data);
      _recalculateTotalAllocated();
    });
  }

  void _loadEnvelopes() {
    try {
      final data = IsarService.getAllEnvelopes();
      envelopes.assignAll(data);
      _recalculateTotalAllocated();
    } catch (e) {
      _logger.e('Error loading envelopes', error: e);
    }
  }

  void _recalculateTotalAllocated() {
    totalAllocated.value =
        envelopes.fold(0.0, (sum, env) => sum + env.currentAmount);
    _updateFinancialContext();
  }

  void _updateFinancialContext() {
    if (Get.isRegistered<FinancialContextService>()) {
      Get.find<FinancialContextService>()
          .updateAllocatedBalance(totalAllocated.value);
    }
  }

  Future<void> createEnvelope({
    required String name,
    double targetAmount = 0.0,
    String? icon,
    String? color,
  }) async {
    final envelope = Envelope.create(
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0.0, // Start empty
      icon: icon,
      color: color,
    );
    await IsarService.addEnvelope(envelope);
  }

  Future<void> updateEnvelope(Envelope envelope) async {
    await IsarService.updateEnvelope(envelope);
  }

  Future<void> deleteEnvelope(String id) async {
    await IsarService.deleteEnvelope(id);
  }

  /// Allocates funds to an envelope.
  /// Returns true if successful, false if validation fails (e.g. not enough free funds).
  Future<bool> allocateFunds(String envelopeId, double amount,
      {bool force = false}) async {
    final envelope = IsarService.getEnvelopeById(envelopeId);
    if (envelope == null) return false;

    // Check availability if not forcing
    // This requires checking FinancialContextService for "Unallocated Balance"

    final newAmount = envelope.currentAmount + amount;
    if (newAmount < 0) return false; // Cannot have negative envelope balance

    final updated = envelope.copyWith(currentAmount: newAmount);
    await IsarService.updateEnvelope(updated);
    return true;
  }
}
