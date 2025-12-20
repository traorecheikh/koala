// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final typeId = 42;

  @override
  Debt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debt(
      id: fields[0] as String,
      personName: fields[1] as String,
      originalAmount: (fields[2] as num).toDouble(),
      remainingAmount: (fields[3] as num).toDouble(),
      type: fields[4] as DebtType,
      dueDate: fields[5] as DateTime?,
      createdAt: fields[6] as DateTime,
      transactionIds:
          fields[7] == null ? const [] : (fields[7] as List).cast<String>(),
      minPayment: fields[8] == null ? 0.0 : (fields[8] as num).toDouble(),
      dueDayOfMonth: (fields[9] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.personName)
      ..writeByte(2)
      ..write(obj.originalAmount)
      ..writeByte(3)
      ..write(obj.remainingAmount)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.transactionIds)
      ..writeByte(8)
      ..write(obj.minPayment)
      ..writeByte(9)
      ..write(obj.dueDayOfMonth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DebtTypeAdapter extends TypeAdapter<DebtType> {
  @override
  final typeId = 41;

  @override
  DebtType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DebtType.lent;
      case 1:
        return DebtType.borrowed;
      default:
        return DebtType.lent;
    }
  }

  @override
  void write(BinaryWriter writer, DebtType obj) {
    switch (obj) {
      case DebtType.lent:
        writer.writeByte(0);
      case DebtType.borrowed:
        writer.writeByte(1);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDebtCollection on Isar {
  IsarCollection<String, Debt> get debts => this.collection();
}

final DebtSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'Debt',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'personName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'originalAmount',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'remainingAmount',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.byte,
        enumMap: {"lent": 0, "borrowed": 1},
      ),
      IsarPropertySchema(
        name: 'dueDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'transactionIds',
        type: IsarType.stringList,
      ),
      IsarPropertySchema(
        name: 'minPayment',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'dueDayOfMonth',
        type: IsarType.long,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'personName',
        properties: [
          "personName",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'type',
        properties: [
          "type",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, Debt>(
    serialize: serializeDebt,
    deserialize: deserializeDebt,
    deserializeProperty: deserializeDebtProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeDebt(IsarWriter writer, Debt object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.personName);
  IsarCore.writeDouble(writer, 3, object.originalAmount);
  IsarCore.writeDouble(writer, 4, object.remainingAmount);
  IsarCore.writeByte(writer, 5, object.type.index);
  IsarCore.writeLong(writer, 6,
      object.dueDate?.toUtc().microsecondsSinceEpoch ?? -9223372036854775808);
  IsarCore.writeLong(
      writer, 7, object.createdAt.toUtc().microsecondsSinceEpoch);
  {
    final list = object.transactionIds;
    final listWriter = IsarCore.beginList(writer, 8, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeDouble(writer, 9, object.minPayment);
  IsarCore.writeLong(writer, 10, object.dueDayOfMonth ?? -9223372036854775808);
  return Isar.fastHash(object.id);
}

@isarProtected
Debt deserializeDebt(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _personName;
  _personName = IsarCore.readString(reader, 2) ?? '';
  final double _originalAmount;
  _originalAmount = IsarCore.readDouble(reader, 3);
  final double _remainingAmount;
  _remainingAmount = IsarCore.readDouble(reader, 4);
  final DebtType _type;
  {
    if (IsarCore.readNull(reader, 5)) {
      _type = DebtType.lent;
    } else {
      _type = _debtType[IsarCore.readByte(reader, 5)] ?? DebtType.lent;
    }
  }
  final DateTime? _dueDate;
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      _dueDate = null;
    } else {
      _dueDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final DateTime _createdAt;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final List<String> _transactionIds;
  {
    final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _transactionIds = const [];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        _transactionIds = list;
      }
    }
  }
  final double _minPayment;
  {
    final value = IsarCore.readDouble(reader, 9);
    if (value.isNaN) {
      _minPayment = 0.0;
    } else {
      _minPayment = value;
    }
  }
  final int? _dueDayOfMonth;
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      _dueDayOfMonth = null;
    } else {
      _dueDayOfMonth = value;
    }
  }
  final object = Debt(
    id: _id,
    personName: _personName,
    originalAmount: _originalAmount,
    remainingAmount: _remainingAmount,
    type: _type,
    dueDate: _dueDate,
    createdAt: _createdAt,
    transactionIds: _transactionIds,
    minPayment: _minPayment,
    dueDayOfMonth: _dueDayOfMonth,
  );
  return object;
}

@isarProtected
dynamic deserializeDebtProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readDouble(reader, 3);
    case 4:
      return IsarCore.readDouble(reader, 4);
    case 5:
      {
        if (IsarCore.readNull(reader, 5)) {
          return DebtType.lent;
        } else {
          return _debtType[IsarCore.readByte(reader, 5)] ?? DebtType.lent;
        }
      }
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
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
        final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const [];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 9:
      {
        final value = IsarCore.readDouble(reader, 9);
        if (value.isNaN) {
          return 0.0;
        } else {
          return value;
        }
      }
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DebtUpdate {
  bool call({
    required String id,
    String? personName,
    double? originalAmount,
    double? remainingAmount,
    DebtType? type,
    DateTime? dueDate,
    DateTime? createdAt,
    double? minPayment,
    int? dueDayOfMonth,
  });
}

class _DebtUpdateImpl implements _DebtUpdate {
  const _DebtUpdateImpl(this.collection);

  final IsarCollection<String, Debt> collection;

  @override
  bool call({
    required String id,
    Object? personName = ignore,
    Object? originalAmount = ignore,
    Object? remainingAmount = ignore,
    Object? type = ignore,
    Object? dueDate = ignore,
    Object? createdAt = ignore,
    Object? minPayment = ignore,
    Object? dueDayOfMonth = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (personName != ignore) 2: personName as String?,
          if (originalAmount != ignore) 3: originalAmount as double?,
          if (remainingAmount != ignore) 4: remainingAmount as double?,
          if (type != ignore) 5: type as DebtType?,
          if (dueDate != ignore) 6: dueDate as DateTime?,
          if (createdAt != ignore) 7: createdAt as DateTime?,
          if (minPayment != ignore) 9: minPayment as double?,
          if (dueDayOfMonth != ignore) 10: dueDayOfMonth as int?,
        }) >
        0;
  }
}

sealed class _DebtUpdateAll {
  int call({
    required List<String> id,
    String? personName,
    double? originalAmount,
    double? remainingAmount,
    DebtType? type,
    DateTime? dueDate,
    DateTime? createdAt,
    double? minPayment,
    int? dueDayOfMonth,
  });
}

class _DebtUpdateAllImpl implements _DebtUpdateAll {
  const _DebtUpdateAllImpl(this.collection);

  final IsarCollection<String, Debt> collection;

  @override
  int call({
    required List<String> id,
    Object? personName = ignore,
    Object? originalAmount = ignore,
    Object? remainingAmount = ignore,
    Object? type = ignore,
    Object? dueDate = ignore,
    Object? createdAt = ignore,
    Object? minPayment = ignore,
    Object? dueDayOfMonth = ignore,
  }) {
    return collection.updateProperties(id, {
      if (personName != ignore) 2: personName as String?,
      if (originalAmount != ignore) 3: originalAmount as double?,
      if (remainingAmount != ignore) 4: remainingAmount as double?,
      if (type != ignore) 5: type as DebtType?,
      if (dueDate != ignore) 6: dueDate as DateTime?,
      if (createdAt != ignore) 7: createdAt as DateTime?,
      if (minPayment != ignore) 9: minPayment as double?,
      if (dueDayOfMonth != ignore) 10: dueDayOfMonth as int?,
    });
  }
}

extension DebtUpdate on IsarCollection<String, Debt> {
  _DebtUpdate get update => _DebtUpdateImpl(this);

  _DebtUpdateAll get updateAll => _DebtUpdateAllImpl(this);
}

sealed class _DebtQueryUpdate {
  int call({
    String? personName,
    double? originalAmount,
    double? remainingAmount,
    DebtType? type,
    DateTime? dueDate,
    DateTime? createdAt,
    double? minPayment,
    int? dueDayOfMonth,
  });
}

class _DebtQueryUpdateImpl implements _DebtQueryUpdate {
  const _DebtQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<Debt> query;
  final int? limit;

  @override
  int call({
    Object? personName = ignore,
    Object? originalAmount = ignore,
    Object? remainingAmount = ignore,
    Object? type = ignore,
    Object? dueDate = ignore,
    Object? createdAt = ignore,
    Object? minPayment = ignore,
    Object? dueDayOfMonth = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (personName != ignore) 2: personName as String?,
      if (originalAmount != ignore) 3: originalAmount as double?,
      if (remainingAmount != ignore) 4: remainingAmount as double?,
      if (type != ignore) 5: type as DebtType?,
      if (dueDate != ignore) 6: dueDate as DateTime?,
      if (createdAt != ignore) 7: createdAt as DateTime?,
      if (minPayment != ignore) 9: minPayment as double?,
      if (dueDayOfMonth != ignore) 10: dueDayOfMonth as int?,
    });
  }
}

extension DebtQueryUpdate on IsarQuery<Debt> {
  _DebtQueryUpdate get updateFirst => _DebtQueryUpdateImpl(this, limit: 1);

  _DebtQueryUpdate get updateAll => _DebtQueryUpdateImpl(this);
}

class _DebtQueryBuilderUpdateImpl implements _DebtQueryUpdate {
  const _DebtQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<Debt, Debt, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? personName = ignore,
    Object? originalAmount = ignore,
    Object? remainingAmount = ignore,
    Object? type = ignore,
    Object? dueDate = ignore,
    Object? createdAt = ignore,
    Object? minPayment = ignore,
    Object? dueDayOfMonth = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (personName != ignore) 2: personName as String?,
        if (originalAmount != ignore) 3: originalAmount as double?,
        if (remainingAmount != ignore) 4: remainingAmount as double?,
        if (type != ignore) 5: type as DebtType?,
        if (dueDate != ignore) 6: dueDate as DateTime?,
        if (createdAt != ignore) 7: createdAt as DateTime?,
        if (minPayment != ignore) 9: minPayment as double?,
        if (dueDayOfMonth != ignore) 10: dueDayOfMonth as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension DebtQueryBuilderUpdate on QueryBuilder<Debt, Debt, QOperations> {
  _DebtQueryUpdate get updateFirst =>
      _DebtQueryBuilderUpdateImpl(this, limit: 1);

  _DebtQueryUpdate get updateAll => _DebtQueryBuilderUpdateImpl(this);
}

const _debtType = {
  0: DebtType.lent,
  1: DebtType.borrowed,
};

extension DebtQueryFilter on QueryBuilder<Debt, Debt, QFilterCondition> {
  QueryBuilder<Debt, Debt, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idGreaterThanOrEqualTo(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idLessThanOrEqualTo(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idContains(String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idMatches(String pattern,
      {bool caseSensitive = true}) {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      personNameGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> personNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> originalAmountEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> originalAmountGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      originalAmountGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> originalAmountLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      originalAmountLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> originalAmountBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> remainingAmountEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> remainingAmountGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      remainingAmountGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> remainingAmountLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      remainingAmountLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> remainingAmountBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> typeEqualTo(
    DebtType value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> typeGreaterThan(
    DebtType value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> typeGreaterThanOrEqualTo(
    DebtType value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> typeLessThan(
    DebtType value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> typeLessThanOrEqualTo(
    DebtType value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> typeBetween(
    DebtType lower,
    DebtType upper,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateEqualTo(
    DateTime? value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateGreaterThan(
    DateTime? value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateGreaterThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateLessThan(
    DateTime? value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateLessThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDateBetween(
    DateTime? lower,
    DateTime? upper,
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> createdAtEqualTo(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> createdAtGreaterThanOrEqualTo(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> createdAtLessThanOrEqualTo(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsElementEqualTo(
    String value, {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      transactionIdsElementGreaterThan(
    String value, {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      transactionIdsElementGreaterThanOrEqualTo(
    String value, {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsElementLessThan(
    String value, {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      transactionIdsElementLessThanOrEqualTo(
    String value, {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsElementBetween(
    String lower,
    String upper, {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      transactionIdsElementStartsWith(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsElementEndsWith(
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsElementContains(
      String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
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

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      transactionIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      transactionIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 8,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsIsEmpty() {
    return not().transactionIdsIsNotEmpty();
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> transactionIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 8, value: null),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> minPaymentEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> minPaymentGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      minPaymentGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> minPaymentLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> minPaymentLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> minPaymentBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDayOfMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDayOfMonthIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDayOfMonthEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDayOfMonthGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      dueDayOfMonthGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDayOfMonthLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition>
      dueDayOfMonthLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterFilterCondition> dueDayOfMonthBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }
}

extension DebtQueryObject on QueryBuilder<Debt, Debt, QFilterCondition> {}

extension DebtQuerySortBy on QueryBuilder<Debt, Debt, QSortBy> {
  QueryBuilder<Debt, Debt, QAfterSortBy> sortById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByPersonName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByPersonNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByOriginalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByOriginalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByRemainingAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByRemainingAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByMinPayment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByMinPaymentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByDueDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> sortByDueDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension DebtQuerySortThenBy on QueryBuilder<Debt, Debt, QSortThenBy> {
  QueryBuilder<Debt, Debt, QAfterSortBy> thenById({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByPersonName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByPersonNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByOriginalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByOriginalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByRemainingAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByRemainingAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByMinPayment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByMinPaymentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByDueDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<Debt, Debt, QAfterSortBy> thenByDueDayOfMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }
}

extension DebtQueryWhereDistinct on QueryBuilder<Debt, Debt, QDistinct> {
  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByPersonName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByOriginalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByRemainingAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByTransactionIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByMinPayment() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<Debt, Debt, QAfterDistinct> distinctByDueDayOfMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }
}

extension DebtQueryProperty1 on QueryBuilder<Debt, Debt, QProperty> {
  QueryBuilder<Debt, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Debt, String, QAfterProperty> personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Debt, double, QAfterProperty> originalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Debt, double, QAfterProperty> remainingAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Debt, DebtType, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Debt, DateTime?, QAfterProperty> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<Debt, DateTime, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<Debt, List<String>, QAfterProperty> transactionIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<Debt, double, QAfterProperty> minPaymentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<Debt, int?, QAfterProperty> dueDayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension DebtQueryProperty2<R> on QueryBuilder<Debt, R, QAfterProperty> {
  QueryBuilder<Debt, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Debt, (R, String), QAfterProperty> personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Debt, (R, double), QAfterProperty> originalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Debt, (R, double), QAfterProperty> remainingAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Debt, (R, DebtType), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Debt, (R, DateTime?), QAfterProperty> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<Debt, (R, DateTime), QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<Debt, (R, List<String>), QAfterProperty>
      transactionIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<Debt, (R, double), QAfterProperty> minPaymentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<Debt, (R, int?), QAfterProperty> dueDayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension DebtQueryProperty3<R1, R2>
    on QueryBuilder<Debt, (R1, R2), QAfterProperty> {
  QueryBuilder<Debt, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Debt, (R1, R2, String), QOperations> personNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Debt, (R1, R2, double), QOperations> originalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Debt, (R1, R2, double), QOperations> remainingAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Debt, (R1, R2, DebtType), QOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Debt, (R1, R2, DateTime?), QOperations> dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<Debt, (R1, R2, DateTime), QOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<Debt, (R1, R2, List<String>), QOperations>
      transactionIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<Debt, (R1, R2, double), QOperations> minPaymentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<Debt, (R1, R2, int?), QOperations> dueDayOfMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}
