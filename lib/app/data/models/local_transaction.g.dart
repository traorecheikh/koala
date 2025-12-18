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
      id: fields[8] as String,
      amount: (fields[0] as num).toDouble(),
      description: fields[1] as String,
      date: fields[2] as DateTime,
      type: fields[3] as TransactionType,
      isRecurring: fields[4] == null ? false : fields[4] as bool,
      category: fields[5] as TransactionCategory,
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

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetLocalTransactionCollection on Isar {
  IsarCollection<String, LocalTransaction> get localTransactions =>
      this.collection();
}

final LocalTransactionSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'LocalTransaction',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'amount',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'description',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'date',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.byte,
        enumMap: {"income": 0, "expense": 1},
      ),
      IsarPropertySchema(
        name: 'isRecurring',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'category',
        type: IsarType.byte,
        enumMap: {
          "salary": 0,
          "freelance": 1,
          "investment": 2,
          "business": 3,
          "gift": 4,
          "bonus": 5,
          "refund": 6,
          "rental": 7,
          "otherIncome": 8,
          "food": 9,
          "transport": 10,
          "shopping": 11,
          "entertainment": 12,
          "bills": 13,
          "health": 14,
          "education": 15,
          "rent": 16,
          "groceries": 17,
          "utilities": 18,
          "insurance": 19,
          "travel": 20,
          "clothing": 21,
          "fitness": 22,
          "beauty": 23,
          "gifts": 24,
          "charity": 25,
          "subscriptions": 26,
          "maintenance": 27,
          "otherExpense": 28
        },
      ),
      IsarPropertySchema(
        name: 'categoryId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'isHidden',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'linkedDebtId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'linkedRecurringId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'linkedJobId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'isCatchUp',
        type: IsarType.bool,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, LocalTransaction>(
    serialize: serializeLocalTransaction,
    deserialize: deserializeLocalTransaction,
    deserializeProperty: deserializeLocalTransactionProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeLocalTransaction(IsarWriter writer, LocalTransaction object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeDouble(writer, 2, object.amount);
  IsarCore.writeString(writer, 3, object.description);
  IsarCore.writeLong(writer, 4, object.date.toUtc().microsecondsSinceEpoch);
  IsarCore.writeByte(writer, 5, object.type.index);
  IsarCore.writeBool(writer, 6, value: object.isRecurring);
  IsarCore.writeByte(writer, 7, object.category.index);
  {
    final value = object.categoryId;
    if (value == null) {
      IsarCore.writeNull(writer, 8);
    } else {
      IsarCore.writeString(writer, 8, value);
    }
  }
  IsarCore.writeBool(writer, 9, value: object.isHidden);
  {
    final value = object.linkedDebtId;
    if (value == null) {
      IsarCore.writeNull(writer, 10);
    } else {
      IsarCore.writeString(writer, 10, value);
    }
  }
  {
    final value = object.linkedRecurringId;
    if (value == null) {
      IsarCore.writeNull(writer, 11);
    } else {
      IsarCore.writeString(writer, 11, value);
    }
  }
  {
    final value = object.linkedJobId;
    if (value == null) {
      IsarCore.writeNull(writer, 12);
    } else {
      IsarCore.writeString(writer, 12, value);
    }
  }
  IsarCore.writeBool(writer, 13, value: object.isCatchUp);
  return Isar.fastHash(object.id);
}

@isarProtected
LocalTransaction deserializeLocalTransaction(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final double _amount;
  _amount = IsarCore.readDouble(reader, 2);
  final String _description;
  _description = IsarCore.readString(reader, 3) ?? '';
  final DateTime _date;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _date = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _date = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final TransactionType _type;
  {
    if (IsarCore.readNull(reader, 5)) {
      _type = TransactionType.income;
    } else {
      _type = _localTransactionType[IsarCore.readByte(reader, 5)] ??
          TransactionType.income;
    }
  }
  final bool _isRecurring;
  _isRecurring = IsarCore.readBool(reader, 6);
  final TransactionCategory _category;
  {
    if (IsarCore.readNull(reader, 7)) {
      _category = TransactionCategory.salary;
    } else {
      _category = _localTransactionCategory[IsarCore.readByte(reader, 7)] ??
          TransactionCategory.salary;
    }
  }
  final String? _categoryId;
  _categoryId = IsarCore.readString(reader, 8);
  final bool _isHidden;
  _isHidden = IsarCore.readBool(reader, 9);
  final String? _linkedDebtId;
  _linkedDebtId = IsarCore.readString(reader, 10);
  final String? _linkedRecurringId;
  _linkedRecurringId = IsarCore.readString(reader, 11);
  final String? _linkedJobId;
  _linkedJobId = IsarCore.readString(reader, 12);
  final bool _isCatchUp;
  _isCatchUp = IsarCore.readBool(reader, 13);
  final object = LocalTransaction(
    id: _id,
    amount: _amount,
    description: _description,
    date: _date,
    type: _type,
    isRecurring: _isRecurring,
    category: _category,
    categoryId: _categoryId,
    isHidden: _isHidden,
    linkedDebtId: _linkedDebtId,
    linkedRecurringId: _linkedRecurringId,
    linkedJobId: _linkedJobId,
    isCatchUp: _isCatchUp,
  );
  return object;
}

@isarProtected
dynamic deserializeLocalTransactionProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readDouble(reader, 2);
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 5:
      {
        if (IsarCore.readNull(reader, 5)) {
          return TransactionType.income;
        } else {
          return _localTransactionType[IsarCore.readByte(reader, 5)] ??
              TransactionType.income;
        }
      }
    case 6:
      return IsarCore.readBool(reader, 6);
    case 7:
      {
        if (IsarCore.readNull(reader, 7)) {
          return TransactionCategory.salary;
        } else {
          return _localTransactionCategory[IsarCore.readByte(reader, 7)] ??
              TransactionCategory.salary;
        }
      }
    case 8:
      return IsarCore.readString(reader, 8);
    case 9:
      return IsarCore.readBool(reader, 9);
    case 10:
      return IsarCore.readString(reader, 10);
    case 11:
      return IsarCore.readString(reader, 11);
    case 12:
      return IsarCore.readString(reader, 12);
    case 13:
      return IsarCore.readBool(reader, 13);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _LocalTransactionUpdate {
  bool call({
    required String id,
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
    bool? isRecurring,
    TransactionCategory? category,
    String? categoryId,
    bool? isHidden,
    String? linkedDebtId,
    String? linkedRecurringId,
    String? linkedJobId,
    bool? isCatchUp,
  });
}

class _LocalTransactionUpdateImpl implements _LocalTransactionUpdate {
  const _LocalTransactionUpdateImpl(this.collection);

  final IsarCollection<String, LocalTransaction> collection;

  @override
  bool call({
    required String id,
    Object? amount = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? type = ignore,
    Object? isRecurring = ignore,
    Object? category = ignore,
    Object? categoryId = ignore,
    Object? isHidden = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedRecurringId = ignore,
    Object? linkedJobId = ignore,
    Object? isCatchUp = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (amount != ignore) 2: amount as double?,
          if (description != ignore) 3: description as String?,
          if (date != ignore) 4: date as DateTime?,
          if (type != ignore) 5: type as TransactionType?,
          if (isRecurring != ignore) 6: isRecurring as bool?,
          if (category != ignore) 7: category as TransactionCategory?,
          if (categoryId != ignore) 8: categoryId as String?,
          if (isHidden != ignore) 9: isHidden as bool?,
          if (linkedDebtId != ignore) 10: linkedDebtId as String?,
          if (linkedRecurringId != ignore) 11: linkedRecurringId as String?,
          if (linkedJobId != ignore) 12: linkedJobId as String?,
          if (isCatchUp != ignore) 13: isCatchUp as bool?,
        }) >
        0;
  }
}

sealed class _LocalTransactionUpdateAll {
  int call({
    required List<String> id,
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
    bool? isRecurring,
    TransactionCategory? category,
    String? categoryId,
    bool? isHidden,
    String? linkedDebtId,
    String? linkedRecurringId,
    String? linkedJobId,
    bool? isCatchUp,
  });
}

class _LocalTransactionUpdateAllImpl implements _LocalTransactionUpdateAll {
  const _LocalTransactionUpdateAllImpl(this.collection);

  final IsarCollection<String, LocalTransaction> collection;

  @override
  int call({
    required List<String> id,
    Object? amount = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? type = ignore,
    Object? isRecurring = ignore,
    Object? category = ignore,
    Object? categoryId = ignore,
    Object? isHidden = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedRecurringId = ignore,
    Object? linkedJobId = ignore,
    Object? isCatchUp = ignore,
  }) {
    return collection.updateProperties(id, {
      if (amount != ignore) 2: amount as double?,
      if (description != ignore) 3: description as String?,
      if (date != ignore) 4: date as DateTime?,
      if (type != ignore) 5: type as TransactionType?,
      if (isRecurring != ignore) 6: isRecurring as bool?,
      if (category != ignore) 7: category as TransactionCategory?,
      if (categoryId != ignore) 8: categoryId as String?,
      if (isHidden != ignore) 9: isHidden as bool?,
      if (linkedDebtId != ignore) 10: linkedDebtId as String?,
      if (linkedRecurringId != ignore) 11: linkedRecurringId as String?,
      if (linkedJobId != ignore) 12: linkedJobId as String?,
      if (isCatchUp != ignore) 13: isCatchUp as bool?,
    });
  }
}

extension LocalTransactionUpdate on IsarCollection<String, LocalTransaction> {
  _LocalTransactionUpdate get update => _LocalTransactionUpdateImpl(this);

  _LocalTransactionUpdateAll get updateAll =>
      _LocalTransactionUpdateAllImpl(this);
}

sealed class _LocalTransactionQueryUpdate {
  int call({
    double? amount,
    String? description,
    DateTime? date,
    TransactionType? type,
    bool? isRecurring,
    TransactionCategory? category,
    String? categoryId,
    bool? isHidden,
    String? linkedDebtId,
    String? linkedRecurringId,
    String? linkedJobId,
    bool? isCatchUp,
  });
}

class _LocalTransactionQueryUpdateImpl implements _LocalTransactionQueryUpdate {
  const _LocalTransactionQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<LocalTransaction> query;
  final int? limit;

  @override
  int call({
    Object? amount = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? type = ignore,
    Object? isRecurring = ignore,
    Object? category = ignore,
    Object? categoryId = ignore,
    Object? isHidden = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedRecurringId = ignore,
    Object? linkedJobId = ignore,
    Object? isCatchUp = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (amount != ignore) 2: amount as double?,
      if (description != ignore) 3: description as String?,
      if (date != ignore) 4: date as DateTime?,
      if (type != ignore) 5: type as TransactionType?,
      if (isRecurring != ignore) 6: isRecurring as bool?,
      if (category != ignore) 7: category as TransactionCategory?,
      if (categoryId != ignore) 8: categoryId as String?,
      if (isHidden != ignore) 9: isHidden as bool?,
      if (linkedDebtId != ignore) 10: linkedDebtId as String?,
      if (linkedRecurringId != ignore) 11: linkedRecurringId as String?,
      if (linkedJobId != ignore) 12: linkedJobId as String?,
      if (isCatchUp != ignore) 13: isCatchUp as bool?,
    });
  }
}

extension LocalTransactionQueryUpdate on IsarQuery<LocalTransaction> {
  _LocalTransactionQueryUpdate get updateFirst =>
      _LocalTransactionQueryUpdateImpl(this, limit: 1);

  _LocalTransactionQueryUpdate get updateAll =>
      _LocalTransactionQueryUpdateImpl(this);
}

class _LocalTransactionQueryBuilderUpdateImpl
    implements _LocalTransactionQueryUpdate {
  const _LocalTransactionQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<LocalTransaction, LocalTransaction, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? amount = ignore,
    Object? description = ignore,
    Object? date = ignore,
    Object? type = ignore,
    Object? isRecurring = ignore,
    Object? category = ignore,
    Object? categoryId = ignore,
    Object? isHidden = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedRecurringId = ignore,
    Object? linkedJobId = ignore,
    Object? isCatchUp = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (amount != ignore) 2: amount as double?,
        if (description != ignore) 3: description as String?,
        if (date != ignore) 4: date as DateTime?,
        if (type != ignore) 5: type as TransactionType?,
        if (isRecurring != ignore) 6: isRecurring as bool?,
        if (category != ignore) 7: category as TransactionCategory?,
        if (categoryId != ignore) 8: categoryId as String?,
        if (isHidden != ignore) 9: isHidden as bool?,
        if (linkedDebtId != ignore) 10: linkedDebtId as String?,
        if (linkedRecurringId != ignore) 11: linkedRecurringId as String?,
        if (linkedJobId != ignore) 12: linkedJobId as String?,
        if (isCatchUp != ignore) 13: isCatchUp as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension LocalTransactionQueryBuilderUpdate
    on QueryBuilder<LocalTransaction, LocalTransaction, QOperations> {
  _LocalTransactionQueryUpdate get updateFirst =>
      _LocalTransactionQueryBuilderUpdateImpl(this, limit: 1);

  _LocalTransactionQueryUpdate get updateAll =>
      _LocalTransactionQueryBuilderUpdateImpl(this);
}

const _localTransactionType = {
  0: TransactionType.income,
  1: TransactionType.expense,
};
const _localTransactionCategory = {
  0: TransactionCategory.salary,
  1: TransactionCategory.freelance,
  2: TransactionCategory.investment,
  3: TransactionCategory.business,
  4: TransactionCategory.gift,
  5: TransactionCategory.bonus,
  6: TransactionCategory.refund,
  7: TransactionCategory.rental,
  8: TransactionCategory.otherIncome,
  9: TransactionCategory.food,
  10: TransactionCategory.transport,
  11: TransactionCategory.shopping,
  12: TransactionCategory.entertainment,
  13: TransactionCategory.bills,
  14: TransactionCategory.health,
  15: TransactionCategory.education,
  16: TransactionCategory.rent,
  17: TransactionCategory.groceries,
  18: TransactionCategory.utilities,
  19: TransactionCategory.insurance,
  20: TransactionCategory.travel,
  21: TransactionCategory.clothing,
  22: TransactionCategory.fitness,
  23: TransactionCategory.beauty,
  24: TransactionCategory.gifts,
  25: TransactionCategory.charity,
  26: TransactionCategory.subscriptions,
  27: TransactionCategory.maintenance,
  28: TransactionCategory.otherExpense,
};

extension LocalTransactionQueryFilter
    on QueryBuilder<LocalTransaction, LocalTransaction, QFilterCondition> {
  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      amountGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      amountLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      amountLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      dateGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      dateLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      dateLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      typeEqualTo(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      typeGreaterThan(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      typeGreaterThanOrEqualTo(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      typeLessThan(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      typeLessThanOrEqualTo(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      typeBetween(
    TransactionType lower,
    TransactionType upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      isRecurringEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryEqualTo(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryGreaterThan(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryGreaterThanOrEqualTo(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryLessThan(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryLessThanOrEqualTo(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryBetween(
    TransactionCategory lower,
    TransactionCategory upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 8));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 8,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      isHiddenEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 10,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedDebtIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 11,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 11,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedRecurringIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdGreaterThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdLessThanOrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 12,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 12,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 12,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      linkedJobIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterFilterCondition>
      isCatchUpEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }
}

extension LocalTransactionQueryObject
    on QueryBuilder<LocalTransaction, LocalTransaction, QFilterCondition> {}

extension LocalTransactionQuerySortBy
    on QueryBuilder<LocalTransaction, LocalTransaction, QSortBy> {
  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByIsRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByCategoryIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        8,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByIsHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByLinkedDebtId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByLinkedDebtIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByLinkedRecurringId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByLinkedRecurringIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByLinkedJobId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByLinkedJobIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByIsCatchUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      sortByIsCatchUpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }
}

extension LocalTransactionQuerySortThenBy
    on QueryBuilder<LocalTransaction, LocalTransaction, QSortThenBy> {
  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByIsRecurringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByCategoryIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByIsHiddenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByLinkedDebtId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByLinkedDebtIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByLinkedRecurringId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByLinkedRecurringIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByLinkedJobId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByLinkedJobIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByIsCatchUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterSortBy>
      thenByIsCatchUpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }
}

extension LocalTransactionQueryWhereDistinct
    on QueryBuilder<LocalTransaction, LocalTransaction, QDistinct> {
  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByIsRecurring() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByIsHidden() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByLinkedDebtId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByLinkedRecurringId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByLinkedJobId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTransaction, LocalTransaction, QAfterDistinct>
      distinctByIsCatchUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }
}

extension LocalTransactionQueryProperty1
    on QueryBuilder<LocalTransaction, LocalTransaction, QProperty> {
  QueryBuilder<LocalTransaction, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalTransaction, double, QAfterProperty> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalTransaction, String, QAfterProperty> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalTransaction, DateTime, QAfterProperty> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalTransaction, TransactionType, QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalTransaction, bool, QAfterProperty> isRecurringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalTransaction, TransactionCategory, QAfterProperty>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalTransaction, String?, QAfterProperty> categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<LocalTransaction, bool, QAfterProperty> isHiddenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<LocalTransaction, String?, QAfterProperty>
      linkedDebtIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<LocalTransaction, String?, QAfterProperty>
      linkedRecurringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<LocalTransaction, String?, QAfterProperty>
      linkedJobIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<LocalTransaction, bool, QAfterProperty> isCatchUpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}

extension LocalTransactionQueryProperty2<R>
    on QueryBuilder<LocalTransaction, R, QAfterProperty> {
  QueryBuilder<LocalTransaction, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalTransaction, (R, double), QAfterProperty> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalTransaction, (R, String), QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalTransaction, (R, DateTime), QAfterProperty> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalTransaction, (R, TransactionType), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalTransaction, (R, bool), QAfterProperty>
      isRecurringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalTransaction, (R, TransactionCategory), QAfterProperty>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalTransaction, (R, String?), QAfterProperty>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<LocalTransaction, (R, bool), QAfterProperty> isHiddenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<LocalTransaction, (R, String?), QAfterProperty>
      linkedDebtIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<LocalTransaction, (R, String?), QAfterProperty>
      linkedRecurringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<LocalTransaction, (R, String?), QAfterProperty>
      linkedJobIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<LocalTransaction, (R, bool), QAfterProperty>
      isCatchUpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}

extension LocalTransactionQueryProperty3<R1, R2>
    on QueryBuilder<LocalTransaction, (R1, R2), QAfterProperty> {
  QueryBuilder<LocalTransaction, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, double), QOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, String), QOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, DateTime), QOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, TransactionType), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, bool), QOperations>
      isRecurringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, TransactionCategory), QOperations>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, String?), QOperations>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, bool), QOperations>
      isHiddenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, String?), QOperations>
      linkedDebtIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, String?), QOperations>
      linkedRecurringIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, String?), QOperations>
      linkedJobIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<LocalTransaction, (R1, R2, bool), QOperations>
      isCatchUpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}
