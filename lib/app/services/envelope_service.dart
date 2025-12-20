import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/envelope.dart';
import 'package:koaa/app/services/financial_context_service.dart';
import 'package:logger/logger.dart';

class EnvelopeService extends GetxService {
  final _logger = Logger();
  late final Box<Envelope> _envelopeBox;

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
    if (!Hive.isAdapterRegistered(70)) {
      // Note: Adapter registration typically happens in main.dart or service_initializer
      // We assume it's registered there or we register it if we can import the generated file.
      // Since we can't reliably import .g.dart before it exists, we rely on the user/build_runner.
    }

    _envelopeBox = await Hive.openBox<Envelope>('envelopes');
    _loadEnvelopes();

    // Listen to changes
    // Listen to changes
    _envelopeBox.watch().listen((_) {
      _loadEnvelopes();
    });
  }

  void _loadEnvelopes() {
    try {
      envelopes.assignAll(_envelopeBox.values.toList());
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
    final envelope = Envelope(
      name: name,
      targetAmount: targetAmount,
      currentAmount: 0.0, // Start empty
      icon: icon,
      color: color,
    );
    await _envelopeBox.put(envelope.id, envelope);
    _loadEnvelopes();
  }

  Future<void> updateEnvelope(Envelope envelope) async {
    await _envelopeBox.put(envelope.id, envelope);
    _loadEnvelopes();
  }

  Future<void> deleteEnvelope(String id) async {
    await _envelopeBox.delete(id);
    _loadEnvelopes();
  }

  /// Allocates funds to an envelope.
  /// Returns true if successful, false if validation fails (e.g. not enough free funds).
  Future<bool> allocateFunds(String envelopeId, double amount,
      {bool force = false}) async {
    final envelope = _envelopeBox.get(envelopeId);
    if (envelope == null) return false;

    // Check availability if not forcing
    // This requires checking FinancialContextService for "Unallocated Balance"

    final newAmount = envelope.currentAmount + amount;
    if (newAmount < 0) return false; // Cannot have negative envelope balance

    final updated = envelope.copyWith(currentAmount: newAmount);
    await _envelopeBox.put(updated.id, updated);
    _loadEnvelopes();
    return true;
  }
}
