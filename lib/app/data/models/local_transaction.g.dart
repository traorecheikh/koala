// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalTransactionAdapter extends TypeAdapter<LocalTransaction> {
  @override
  final typeId = 2;

  @override
  LocalTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalTransaction(
      id: fields[8] as String?,
      amount: (fields[0] as num).toDouble(),
      description: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as TransactionType,
      isRecurring: fields[4] == null ? false : fields[4] as bool,
      category: fields[5] as TransactionCategory?,
      categoryId: fields[6] as String?,
      isHidden: fields[7] == null ? false : fields[7] as bool,
      linkedDebtId: fields[9] as String?,
      linkedRecurringId: fields[10] as String?,
      linkedJobId: fields[11] as String?,
      isCatchUp: fields[12] == null ? false : fields[12] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTransaction obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.isRecurring)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.categoryId)
      ..writeByte(7)
      ..write(obj.isHidden)
      ..writeByte(8)
      ..write(obj.id)
      ..writeByte(9)
      ..write(obj.linkedDebtId)
      ..writeByte(10)
      ..write(obj.linkedRecurringId)
      ..writeByte(11)
      ..write(obj.linkedJobId)
      ..writeByte(12)
      ..write(obj.isCatchUp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final typeId = 1;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.income;
      case 1:
        return TransactionType.expense;
      default:
        return TransactionType.income;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.income:
        writer.writeByte(0);
      case TransactionType.expense:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionCategoryAdapter extends TypeAdapter<TransactionCategory> {
  @override
  final typeId = 7;

  @override
  TransactionCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionCategory.salary;
      case 1:
        return TransactionCategory.freelance;
      case 2:
        return TransactionCategory.investment;
      case 3:
        return TransactionCategory.business;
      case 4:
        return TransactionCategory.gift;
      case 5:
        return TransactionCategory.bonus;
      case 6:
        return TransactionCategory.refund;
      case 7:
        return TransactionCategory.rental;
      case 8:
        return TransactionCategory.otherIncome;
      case 9:
        return TransactionCategory.food;
      case 10:
        return TransactionCategory.transport;
      case 11:
        return TransactionCategory.shopping;
      case 12:
        return TransactionCategory.entertainment;
      case 13:
        return TransactionCategory.bills;
      case 14:
        return TransactionCategory.health;
      case 15:
        return TransactionCategory.education;
      case 16:
        return TransactionCategory.rent;
      case 17:
        return TransactionCategory.groceries;
      case 18:
        return TransactionCategory.utilities;
      case 19:
        return TransactionCategory.insurance;
      case 20:
        return TransactionCategory.travel;
      case 21:
        return TransactionCategory.clothing;
      case 22:
        return TransactionCategory.fitness;
      case 23:
        return TransactionCategory.beauty;
      case 24:
        return TransactionCategory.gifts;
      case 25:
        return TransactionCategory.charity;
      case 26:
        return TransactionCategory.subscriptions;
      case 27:
        return TransactionCategory.maintenance;
      case 28:
        return TransactionCategory.otherExpense;
      default:
        return TransactionCategory.salary;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionCategory obj) {
    switch (obj) {
      case TransactionCategory.salary:
        writer.writeByte(0);
      case TransactionCategory.freelance:
        writer.writeByte(1);
      case TransactionCategory.investment:
        writer.writeByte(2);
      case TransactionCategory.business:
        writer.writeByte(3);
      case TransactionCategory.gift:
        writer.writeByte(4);
      case TransactionCategory.bonus:
        writer.writeByte(5);
      case TransactionCategory.refund:
        writer.writeByte(6);
      case TransactionCategory.rental:
        writer.writeByte(7);
      case TransactionCategory.otherIncome:
        writer.writeByte(8);
      case TransactionCategory.food:
        writer.writeByte(9);
      case TransactionCategory.transport:
        writer.writeByte(10);
      case TransactionCategory.shopping:
        writer.writeByte(11);
      case TransactionCategory.entertainment:
        writer.writeByte(12);
      case TransactionCategory.bills:
        writer.writeByte(13);
      case TransactionCategory.health:
        writer.writeByte(14);
      case TransactionCategory.education:
        writer.writeByte(15);
      case TransactionCategory.rent:
        writer.writeByte(16);
      case TransactionCategory.groceries:
        writer.writeByte(17);
      case TransactionCategory.utilities:
        writer.writeByte(18);
      case TransactionCategory.insurance:
        writer.writeByte(19);
      case TransactionCategory.travel:
        writer.writeByte(20);
      case TransactionCategory.clothing:
        writer.writeByte(21);
      case TransactionCategory.fitness:
        writer.writeByte(22);
      case TransactionCategory.beauty:
        writer.writeByte(23);
      case TransactionCategory.gifts:
        writer.writeByte(24);
      case TransactionCategory.charity:
        writer.writeByte(25);
      case TransactionCategory.subscriptions:
        writer.writeByte(26);
      case TransactionCategory.maintenance:
        writer.writeByte(27);
      case TransactionCategory.otherExpense:
        writer.writeByte(28);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
