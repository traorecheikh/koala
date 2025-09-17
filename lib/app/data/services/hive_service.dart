import 'package:hive_ce/hive.dart';
import 'package:koala/app/data/models/account_model.dart';
import 'package:koala/app/data/models/loan_model.dart';
import 'package:koala/app/data/models/recurring_model.dart';
import 'package:koala/app/data/models/transaction_model.dart';
import 'package:koala/app/data/models/user_model.dart';

class HiveService {
  static const String userBox = 'userBox';
  static const String accountBox = 'accountBox';
  static const String transactionBox = 'transactionBox';
  static const String loanBox = 'loanBox';
  static const String recurringBox = 'recurringBox';

  static Future<void> init() async {
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(AccountModelAdapter());
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(LoanModelAdapter());
    Hive.registerAdapter(RecurringModelAdapter());
    Hive.registerAdapter(RecurrenceFrequencyAdapter());

    await Hive.openBox<UserModel>(userBox);
    await Hive.openBox<AccountModel>(accountBox);
    await Hive.openBox<TransactionModel>(transactionBox);
    await Hive.openBox<LoanModel>(loanBox);
    await Hive.openBox<RecurringModel>(recurringBox);
  }

  static Box<UserModel> get users => Hive.box<UserModel>(userBox);
  static Box<AccountModel> get accounts => Hive.box<AccountModel>(accountBox);
  static Box<TransactionModel> get transactions =>
      Hive.box<TransactionModel>(transactionBox);
  static Box<LoanModel> get loans => Hive.box<LoanModel>(loanBox);
  static Box<RecurringModel> get recurrings =>
      Hive.box<RecurringModel>(recurringBox);

  static Future<void> clearAll() async {
    await users.clear();
    await accounts.clear();
    await transactions.clear();
    await loans.clear();
    await recurrings.clear();
  }

  static Future<void> close() async {
    await users.close();
    await accounts.close();
    await transactions.close();
    await loans.close();
    await recurrings.close();
  }
}
