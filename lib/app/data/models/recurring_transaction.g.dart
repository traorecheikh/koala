// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringTransactionAdapter extends TypeAdapter<RecurringTransaction> {
  @override
  final typeId = 4;

  @override
  RecurringTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringTransaction(
      id: fields[0] as String,
      amount: (fields[1] as num).toDouble(),
      description: fields[2] as String,
      frequency: fields[3] as Frequency,
      daysOfWeek:
          fields[4] == null ? const [] : (fields[4] as List).cast<int>(),
      dayOfMonth: fields[5] == null ? 1 : (fields[5] as num).toInt(),
      lastGeneratedDate: fields[6] as DateTime,
      category: fields[7] as TransactionCategory,
      type: fields[8] as TransactionType,
      categoryId: fields[9] as String?,
      endDate: fields[10] as DateTime?,
      isActive: fields[11] == null ? true : fields[11] as bool,
      createdAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringTransaction obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.daysOfWeek)
      ..writeByte(5)
      ..write(obj.dayOfMonth)
      ..writeByte(6)
      ..write(obj.lastGeneratedDate)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.categoryId)
      ..writeByte(10)
      ..write(obj.endDate)
      ..writeByte(11)
      ..write(obj.isActive)
      ..writeByte(12)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FrequencyAdapter extends TypeAdapter<Frequency> {
  @override
  final typeId = 3;

  @override
  Frequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Frequency.daily;
      case 1:
        return Frequency.weekly;
      case 2:
        return Frequency.monthly;
      case 3:
        return Frequency.biWeekly;
      case 4:
        return Frequency.yearly;
      default:
        return Frequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, Frequency obj) {
    switch (obj) {
      case Frequency.daily:
        writer.writeByte(0);
      case Frequency.weekly:
        writer.writeByte(1);
      case Frequency.monthly:
        writer.writeByte(2);
      case Frequency.biWeekly:
        writer.writeByte(3);
      case Frequency.yearly:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetRecurringTransactionCollection on Isar {
  IsarCollection<String, RecurringTransaction> get recurringTransactions =>
      this.collection();
}

final RecurringTransactionSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'RecurringTransaction',
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
        name: 'frequency',
        type: IsarType.byte,
        enumMap: {
          "daily": 0,
          "weekly": 1,
          "monthly": 2,
          "biWeekly": 3,
          "yearly": 4
        },
      ),
      IsarPropertySchema(
        name: 'daysOfWeek',
        type: IsarType.longList,
      ),
      IsarPropertySchema(
        name: 'dayOfMonth',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'lastGeneratedDate',
        type: IsarType.dateTime,
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
        name: 'type',
        type: IsarType.byte,
        enumMap: {"income": 0, "expense": 1},
      ),
      IsarPropertySchema(
        name: 'categoryId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'endDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'isActive',
        type: IsarType.bool,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'categoryId',
        properties: [
          "categoryId",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'isActive',
        properties: [
          "isActive",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, RecurringTransaction>(
    serialize: serializeRecurringTransaction,
    deserialize: deserializeRecurringTransaction,
    deserializeProperty: deserializeRecurringTransactionProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeRecurringTransaction(
    IsarWriter writer, RecurringTransaction object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeDouble(writer, 2, object.amount);
  IsarCore.writeString(writer, 3, object.description);
  IsarCore.writeByte(writer, 4, object.frequency.index);
  {
    final list = object.daysOfWeek;
    final listWriter = IsarCore.beginList(writer, 5, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeLong(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeLong(writer, 6, object.dayOfMonth);
  IsarCore.writeLong(
      writer, 7, object.lastGeneratedDate.toUtc().microsecondsSinceEpoch);
  IsarCore.writeByte(writer, 8, object.category.index);
  IsarCore.writeByte(writer, 9, object.type.index);
  {
    final value = object.categoryId;
    if (value == null) {
      IsarCore.writeNull(writer, 10);
    } else {
      IsarCore.writeString(writer, 10, value);
    }
  }
  IsarCore.writeLong(writer, 11,
      object.endDate?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808);
  IsarCore.writeBool(writer, 12, value: object.isActive);
  IsarCore.writeLong(
      writer, 13, object.createdAt.toUtc().microsecondsSinceEpoch);
  return Isar.fastHash(object.id);
}

@isarProtected
RecurringTransaction deserializeRecurringTransaction(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final double _amount;
  _amount = IsarCore.readDouble(reader, 2);
  final String _description;
  _description = IsarCore.readString(reader, 3) ?? '';
  final Frequency _frequency;
  {
    if (IsarCore.readNull(reader, 4)) {
      _frequency = Frequency.daily;
    } else {
      _frequency =
          _recurringTransactionFrequency[IsarCore.readByte(reader, 4)] ??
              Frequency.daily;
    }
  }
  final List<int> _daysOfWeek;
  {
    final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _daysOfWeek = const [];
      } else {
        final list =
            List<int>.filled(length, -9223372036854775808, growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readLong(reader, i);
        }
        IsarCore.freeReader(reader);
        _daysOfWeek = list;
      }
    }
  }
  final int _dayOfMonth;
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      _dayOfMonth = 1;
    } else {
      _dayOfMonth = value;
    }
  }
  final DateTime _lastGeneratedDate;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _lastGeneratedDate =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _lastGeneratedDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final TransactionCategory _category;
  {
    if (IsarCore.readNull(reader, 8)) {
      _category = TransactionCategory.salary;
    } else {
      _category = _recurringTransactionCategory[IsarCore.readByte(reader, 8)] ??
          TransactionCategory.salary;
    }
  }
  final TransactionType _type;
  {
    if (IsarCore.readNull(reader, 9)) {
      _type = TransactionType.income;
    } else {
      _type = _recurringTransactionType[IsarCore.readByte(reader, 9)] ??
          TransactionType.income;
    }
  }
  final String? _categoryId;
  _categoryId = IsarCore.readString(reader, 10);
  final DateTime? _endDate;
  {
    final value = IsarCore.readLong(reader, 11);
    if (value == -9223372036854775808) {
      _endDate = null;
    } else {
      _endDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final bool _isActive;
  {
    if (IsarCore.readNull(reader, 12)) {
      _isActive = true;
    } else {
      _isActive = IsarCore.readBool(reader, 12);
    }
  }
  final DateTime _createdAt;
  {
    final value = IsarCore.readLong(reader, 13);
    if (value == -9223372036854775808) {
      _createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final object = RecurringTransaction(
    id: _id,
    amount: _amount,
    description: _description,
    frequency: _frequency,
    daysOfWeek: _daysOfWeek,
    dayOfMonth: _dayOfMonth,
    lastGeneratedDate: _lastGeneratedDate,
    category: _category,
    type: _type,
    categoryId: _categoryId,
    endDate: _endDate,
    isActive: _isActive,
    createdAt: _createdAt,
  );
  return object;
}

@isarProtected
dynamic deserializeRecurringTransactionProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readDouble(reader, 2);
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      {
        if (IsarCore.readNull(reader, 4)) {
          return Frequency.daily;
        } else {
          return _recurringTransactionFrequency[IsarCore.readByte(reader, 4)] ??
              Frequency.daily;
        }
      }
    case 5:
      {
        final length = IsarCore.readList(reader, 5, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const [];
          } else {
            final list =
                List<int>.filled(length, -9223372036854775808, growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readLong(reader, i);
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return 1;
        } else {
          return value;
        }
      }
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 8:
      {
        if (IsarCore.readNull(reader, 8)) {
          return TransactionCategory.salary;
        } else {
          return _recurringTransactionCategory[IsarCore.readByte(reader, 8)] ??
              TransactionCategory.salary;
        }
      }
    case 9:
      {
        if (IsarCore.readNull(reader, 9)) {
          return TransactionType.income;
        } else {
          return _recurringTransactionType[IsarCore.readByte(reader, 9)] ??
              TransactionType.income;
        }
      }
    case 10:
      return IsarCore.readString(reader, 10);
    case 11:
      {
        final value = IsarCore.readLong(reader, 11);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 12:
      {
        if (IsarCore.readNull(reader, 12)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 12);
        }
      }
    case 13:
      {
        final value = IsarCore.readLong(reader, 13);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _RecurringTransactionUpdate {
  bool call({
    required String id,
    double? amount,
    String? description,
    Frequency? frequency,
    int? dayOfMonth,
    DateTime? lastGeneratedDate,
    TransactionCategory? category,
    TransactionType? type,
    String? categoryId,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  });
}

class _RecurringTransactionUpdateImpl implements _RecurringTransactionUpdate {
  const _RecurringTransactionUpdateImpl(this.collection);

  final IsarCollection<String, RecurringTransaction> collection;

  @override
  bool call({
    required String id,
    Object? amount = ignore,
    Object? description = ignore,
    Object? frequency = ignore,
    Object? dayOfMonth = ignore,
    Object? lastGeneratedDate = ignore,
    Object? category = ignore,
    Object? type = ignore,
    Object? categoryId = ignore,
    Object? endDate = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (amount != ignore) 2: amount as double?,
          if (description != ignore) 3: description as String?,
          if (frequency != ignore) 4: frequency as Frequency?,
          if (dayOfMonth != ignore) 6: dayOfMonth as int?,
          if (lastGeneratedDate != ignore) 7: lastGeneratedDate as DateTime?,
          if (category != ignore) 8: category as TransactionCategory?,
          if (type != ignore) 9: type as TransactionType?,
          if (categoryId != ignore) 10: categoryId as String?,
          if (endDate != ignore) 11: endDate as DateTime?,
          if (isActive != ignore) 12: isActive as bool?,
          if (createdAt != ignore) 13: createdAt as DateTime?,
        }) >
        0;
  }
}

sealed class _RecurringTransactionUpdateAll {
  int call({
    required List<String> id,
    double? amount,
    String? description,
    Frequency? frequency,
    int? dayOfMonth,
    DateTime? lastGeneratedDate,
    TransactionCategory? category,
    TransactionType? type,
    String? categoryId,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  });
}

class _RecurringTransactionUpdateAllImpl
    implements _RecurringTransactionUpdateAll {
  const _RecurringTransactionUpdateAllImpl(this.collection);

  final IsarCollection<String, RecurringTransaction> collection;

  @override
  int call({
    required List<String> id,
    Object? amount = ignore,
    Object? description = ignore,
    Object? frequency = ignore,
    Object? dayOfMonth = ignore,
    Object? lastGeneratedDate = ignore,
    Object? category = ignore,
    Object? type = ignore,
    Object? categoryId = ignore,
    Object? endDate = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (amount != ignore) 2: amount as double?,
      if (description != ignore) 3: description as String?,
      if (frequency != ignore) 4: frequency as Frequency?,
      if (dayOfMonth != ignore) 6: dayOfMonth as int?,
      if (lastGeneratedDate != ignore) 7: lastGeneratedDate as DateTime?,
      if (category != ignore) 8: category as TransactionCategory?,
      if (type != ignore) 9: type as TransactionType?,
      if (categoryId != ignore) 10: categoryId as String?,
      if (endDate != ignore) 11: endDate as DateTime?,
      if (isActive != ignore) 12: isActive as bool?,
      if (createdAt != ignore) 13: createdAt as DateTime?,
    });
  }
}

extension RecurringTransactionUpdate
    on IsarCollection<String, RecurringTransaction> {
  _RecurringTransactionUpdate get update =>
      _RecurringTransactionUpdateImpl(this);

  _RecurringTransactionUpdateAll get updateAll =>
      _RecurringTransactionUpdateAllImpl(this);
}

sealed class _RecurringTransactionQueryUpdate {
  int call({
    double? amount,
    String? description,
    Frequency? frequency,
    int? dayOfMonth,
    DateTime? lastGeneratedDate,
    TransactionCategory? category,
    TransactionType? type,
    String? categoryId,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  });
}

class _RecurringTransactionQueryUpdateImpl
    implements _RecurringTransactionQueryUpdate {
  const _RecurringTransactionQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<RecurringTransaction> query;
  final int? limit;

  @override
  int call({
    Object? amount = ignore,
    Object? description = ignore,
    Object? frequency = ignore,
    Object? dayOfMonth = ignore,
    Object? lastGeneratedDate = ignore,
    Object? category = ignore,
    Object? type = ignore,
    Object? categoryId = ignore,
    Object? endDate = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (amount != ignore) 2: amount as double?,
      if (description != ignore) 3: description as String?,
      if (frequency != ignore) 4: frequency as Frequency?,
      if (dayOfMonth != ignore) 6: dayOfMonth as int?,
      if (lastGeneratedDate != ignore) 7: lastGeneratedDate as DateTime?,
      if (category != ignore) 8: category as TransactionCategory?,
      if (type != ignore) 9: type as TransactionType?,
      if (categoryId != ignore) 10: categoryId as String?,
      if (endDate != ignore) 11: endDate as DateTime?,
      if (isActive != ignore) 12: isActive as bool?,
      if (createdAt != ignore) 13: createdAt as DateTime?,
    });
  }
}

extension RecurringTransactionQueryUpdate on IsarQuery<RecurringTransaction> {
  _RecurringTransactionQueryUpdate get updateFirst =>
      _RecurringTransactionQueryUpdateImpl(this, limit: 1);

  _RecurringTransactionQueryUpdate get updateAll =>
      _RecurringTransactionQueryUpdateImpl(this);
}

class _RecurringTransactionQueryBuilderUpdateImpl
    implements _RecurringTransactionQueryUpdate {
  const _RecurringTransactionQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<RecurringTransaction, RecurringTransaction, QOperations>
      query;
  final int? limit;

  @override
  int call({
    Object? amount = ignore,
    Object? description = ignore,
    Object? frequency = ignore,
    Object? dayOfMonth = ignore,
    Object? lastGeneratedDate = ignore,
    Object? category = ignore,
    Object? type = ignore,
    Object? categoryId = ignore,
    Object? endDate = ignore,
    Object? isActive = ignore,
    Object? createdAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (amount != ignore) 2: amount as double?,
        if (description != ignore) 3: description as String?,
        if (frequency != ignore) 4: frequency as Frequency?,
        if (dayOfMonth != ignore) 6: dayOfMonth as int?,
        if (lastGeneratedDate != ignore) 7: lastGeneratedDate as DateTime?,
        if (category != ignore) 8: category as TransactionCategory?,
        if (type != ignore) 9: type as TransactionType?,
        if (categoryId != ignore) 10: categoryId as String?,
        if (endDate != ignore) 11: endDate as DateTime?,
        if (isActive != ignore) 12: isActive as bool?,
        if (createdAt != ignore) 13: createdAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension RecurringTransactionQueryBuilderUpdate
    on QueryBuilder<RecurringTransaction, RecurringTransaction, QOperations> {
  _RecurringTransactionQueryUpdate get updateFirst =>
      _RecurringTransactionQueryBuilderUpdateImpl(this, limit: 1);

  _RecurringTransactionQueryUpdate get updateAll =>
      _RecurringTransactionQueryBuilderUpdateImpl(this);
}

const _recurringTransactionFrequency = {
  0: Frequency.daily,
  1: Frequency.weekly,
  2: Frequency.monthly,
  3: Frequency.biWeekly,
  4: Frequency.yearly,
};
const _recurringTransactionCategory = {
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
const _recurringTransactionType = {
  0: TransactionType.income,
  1: TransactionType.expense,
};

extension RecurringTransactionQueryFilter on QueryBuilder<RecurringTransaction,
    RecurringTransaction, QFilterCondition> {
  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idGreaterThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idLessThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
          QAfterFilterCondition>
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
          QAfterFilterCondition>
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> amountEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> amountGreaterThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> amountGreaterThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> amountLessThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> amountLessThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> amountBetween(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionGreaterThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionGreaterThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionLessThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionLessThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionBetween(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionStartsWith(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionEndsWith(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
          QAfterFilterCondition>
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
          QAfterFilterCondition>
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> frequencyEqualTo(
    Frequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> frequencyGreaterThan(
    Frequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> frequencyGreaterThanOrEqualTo(
    Frequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> frequencyLessThan(
    Frequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> frequencyLessThanOrEqualTo(
    Frequency value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> frequencyBetween(
    Frequency lower,
    Frequency upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekElementEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekElementGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekElementGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekElementLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekElementLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekElementBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekIsEmpty() {
    return not().daysOfWeekIsNotEmpty();
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> daysOfWeekIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 5, value: null),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> dayOfMonthEqualTo(
    int value,
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> dayOfMonthGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> dayOfMonthGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> dayOfMonthLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> dayOfMonthLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> dayOfMonthBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> lastGeneratedDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> lastGeneratedDateGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> lastGeneratedDateGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> lastGeneratedDateLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> lastGeneratedDateLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> lastGeneratedDateBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryEqualTo(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryGreaterThan(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryGreaterThanOrEqualTo(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryLessThan(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryLessThanOrEqualTo(
    TransactionCategory value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryBetween(
    TransactionCategory lower,
    TransactionCategory upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> typeEqualTo(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> typeGreaterThan(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> typeGreaterThanOrEqualTo(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> typeLessThan(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> typeLessThanOrEqualTo(
    TransactionType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> typeBetween(
    TransactionType lower,
    TransactionType upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdGreaterThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdGreaterThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdLessThan(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdLessThanOrEqualTo(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdBetween(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdStartsWith(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdEndsWith(
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
          QAfterFilterCondition>
      categoryIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
          QAfterFilterCondition>
      categoryIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> categoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 10,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 11,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 11,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> isActiveEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 12,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> createdAtEqualTo(
    DateTime value,
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

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> createdAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> createdAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> createdAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 13,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction,
      QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 13,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension RecurringTransactionQueryObject on QueryBuilder<RecurringTransaction,
    RecurringTransaction, QFilterCondition> {}

extension RecurringTransactionQuerySortBy
    on QueryBuilder<RecurringTransaction, RecurringTransaction, QSortBy> {
  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByLastGeneratedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByLastGeneratedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByCategoryIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        10,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }
}

extension RecurringTransactionQuerySortThenBy
    on QueryBuilder<RecurringTransaction, RecurringTransaction, QSortThenBy> {
  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByLastGeneratedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByLastGeneratedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByCategoryIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }
}

extension RecurringTransactionQueryWhereDistinct
    on QueryBuilder<RecurringTransaction, RecurringTransaction, QDistinct> {
  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByDaysOfWeek() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByLastGeneratedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12);
    });
  }

  QueryBuilder<RecurringTransaction, RecurringTransaction, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }
}

extension RecurringTransactionQueryProperty1
    on QueryBuilder<RecurringTransaction, RecurringTransaction, QProperty> {
  QueryBuilder<RecurringTransaction, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<RecurringTransaction, double, QAfterProperty> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<RecurringTransaction, String, QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<RecurringTransaction, Frequency, QAfterProperty>
      frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<RecurringTransaction, List<int>, QAfterProperty>
      daysOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<RecurringTransaction, int, QAfterProperty> dayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<RecurringTransaction, DateTime, QAfterProperty>
      lastGeneratedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<RecurringTransaction, TransactionCategory, QAfterProperty>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<RecurringTransaction, TransactionType, QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<RecurringTransaction, String?, QAfterProperty>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<RecurringTransaction, DateTime?, QAfterProperty>
      endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<RecurringTransaction, bool, QAfterProperty> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<RecurringTransaction, DateTime, QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}

extension RecurringTransactionQueryProperty2<R>
    on QueryBuilder<RecurringTransaction, R, QAfterProperty> {
  QueryBuilder<RecurringTransaction, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<RecurringTransaction, (R, double), QAfterProperty>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<RecurringTransaction, (R, String), QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<RecurringTransaction, (R, Frequency), QAfterProperty>
      frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<RecurringTransaction, (R, List<int>), QAfterProperty>
      daysOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<RecurringTransaction, (R, int), QAfterProperty>
      dayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<RecurringTransaction, (R, DateTime), QAfterProperty>
      lastGeneratedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<RecurringTransaction, (R, TransactionCategory), QAfterProperty>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<RecurringTransaction, (R, TransactionType), QAfterProperty>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<RecurringTransaction, (R, String?), QAfterProperty>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<RecurringTransaction, (R, DateTime?), QAfterProperty>
      endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<RecurringTransaction, (R, bool), QAfterProperty>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<RecurringTransaction, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}

extension RecurringTransactionQueryProperty3<R1, R2>
    on QueryBuilder<RecurringTransaction, (R1, R2), QAfterProperty> {
  QueryBuilder<RecurringTransaction, (R1, R2, String), QOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, double), QOperations>
      amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, String), QOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, Frequency), QOperations>
      frequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, List<int>), QOperations>
      daysOfWeekProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, int), QOperations>
      dayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, DateTime), QOperations>
      lastGeneratedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, TransactionCategory), QOperations>
      categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, TransactionType), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, String?), QOperations>
      categoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, DateTime?), QOperations>
      endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, bool), QOperations>
      isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<RecurringTransaction, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }
}
