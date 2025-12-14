import 'package:hive_ce/hive.dart';
import 'package:koaa/app/data/models/ml/financial_pattern.dart';
import 'package:koaa/app/data/models/ml/ml_model_state.dart';
import 'package:koaa/app/data/models/ml/user_financial_profile.dart';
import 'package:koaa/app/services/encryption_service.dart'; // Import encryption service

class MLModelStore {
  static const String _modelStateBoxName = 'ml_model_states';
  static const String _userProfileBoxName = 'ml_user_profile';
  static const String _patternsBoxName = 'ml_financial_patterns';

  Box<MLModelState>? _modelStateBox;
  Box<UserFinancialProfile>? _userProfileBox;
  Box<FinancialPattern>? _patternsBox;

  Future<void> init(HiveAesCipher? cipher) async {
    _modelStateBox = await Hive.openBox<MLModelState>(_modelStateBoxName, encryptionCipher: cipher);
    _userProfileBox = await Hive.openBox<UserFinancialProfile>(_userProfileBoxName, encryptionCipher: cipher);
    _patternsBox = await Hive.openBox<FinancialPattern>(_patternsBoxName, encryptionCipher: cipher);
  }

  // --- Model State ---

  Future<void> saveModelState(MLModelState state) async {
    await _modelStateBox?.put(state.modelName, state);
  }

  MLModelState? getModelState(String modelName) {
    return _modelStateBox?.get(modelName);
  }

  // --- User Profile ---

  Future<void> saveUserProfile(UserFinancialProfile profile) async {
    // We assume single user profile for now, key 'current_user'
    await _userProfileBox?.put('current_user', profile);
  }

  UserFinancialProfile? getUserProfile() {
    return _userProfileBox?.get('current_user');
  }

  // --- Patterns ---

  Future<void> savePattern(FinancialPattern pattern) async {
    // Key by pattern type + description hash or unique ID
    final key = '${pattern.patternType}_${pattern.description.hashCode}';
    await _patternsBox?.put(key, pattern);
  }

  List<FinancialPattern> getAllPatterns() {
    return _patternsBox?.values.toList() ?? [];
  }

  Future<void> clearPatterns() async {
    await _patternsBox?.clear();
  }

  Future<void> close() async {
    await _modelStateBox?.close();
    await _userProfileBox?.close();
    await _patternsBox?.close();
  }
}