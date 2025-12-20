// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FinancialGoalAdapter extends TypeAdapter<FinancialGoal> {
  @override
  final typeId = 50;

  @override
  FinancialGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FinancialGoal(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      targetAmount: (fields[3] as num).toDouble(),
      currentAmount: fields[4] == null ? 0.0 : (fields[4] as num).toDouble(),
      type: fields[5] == null ? GoalType.savings : fields[5] as GoalType,
      status: fields[6] == null ? GoalStatus.active : fields[6] as GoalStatus,
      createdAt: fields[7] as DateTime,
      targetDate: fields[8] as DateTime?,
      completedAt: fields[9] as DateTime?,
      linkedDebtId: fields[10] as String?,
      linkedCategoryId: fields[11] as String?,
      milestones: (fields[12] as List?)?.cast<GoalMilestone>(),
      iconKey: (fields[13] as num?)?.toInt(),
      colorValue: (fields[14] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, FinancialGoal obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.targetAmount)
      ..writeByte(4)
      ..write(obj.currentAmount)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.targetDate)
      ..writeByte(9)
      ..write(obj.completedAt)
      ..writeByte(10)
      ..write(obj.linkedDebtId)
      ..writeByte(11)
      ..write(obj.linkedCategoryId)
      ..writeByte(12)
      ..write(obj.milestones)
      ..writeByte(13)
      ..write(obj.iconKey)
      ..writeByte(14)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalMilestoneAdapter extends TypeAdapter<GoalMilestone> {
  @override
  final typeId = 53;

  @override
  GoalMilestone read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalMilestone(
      id: fields[0] as String?,
      title: fields[1] as String,
      targetAmount: (fields[2] as num).toDouble(),
      isCompleted: fields[3] == null ? false : fields[3] as bool,
      completedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GoalMilestone obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetAmount)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMilestoneAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalTypeAdapter extends TypeAdapter<GoalType> {
  @override
  final typeId = 51;

  @override
  GoalType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalType.savings;
      case 1:
        return GoalType.debtPayoff;
      case 2:
        return GoalType.purchase;
      case 3:
        return GoalType.custom;
      default:
        return GoalType.savings;
    }
  }

  @override
  void write(BinaryWriter writer, GoalType obj) {
    switch (obj) {
      case GoalType.savings:
        writer.writeByte(0);
      case GoalType.debtPayoff:
        writer.writeByte(1);
      case GoalType.purchase:
        writer.writeByte(2);
      case GoalType.custom:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GoalStatusAdapter extends TypeAdapter<GoalStatus> {
  @override
  final typeId = 52;

  @override
  GoalStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalStatus.active;
      case 1:
        return GoalStatus.completed;
      case 2:
        return GoalStatus.paused;
      case 3:
        return GoalStatus.abandoned;
      default:
        return GoalStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, GoalStatus obj) {
    switch (obj) {
      case GoalStatus.active:
        writer.writeByte(0);
      case GoalStatus.completed:
        writer.writeByte(1);
      case GoalStatus.paused:
        writer.writeByte(2);
      case GoalStatus.abandoned:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetFinancialGoalCollection on Isar {
  IsarCollection<String, FinancialGoal> get financialGoals => this.collection();
}

final FinancialGoalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'FinancialGoal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'title',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'description',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'targetAmount',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'currentAmount',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.byte,
        enumMap: {"savings": 0, "debtPayoff": 1, "purchase": 2, "custom": 3},
      ),
      IsarPropertySchema(
        name: 'status',
        type: IsarType.byte,
        enumMap: {"active": 0, "completed": 1, "paused": 2, "abandoned": 3},
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'targetDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'completedAt',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'linkedDebtId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'linkedCategoryId',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'iconKey',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'colorValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'progressPercentage',
        type: IsarType.double,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, FinancialGoal>(
    serialize: serializeFinancialGoal,
    deserialize: deserializeFinancialGoal,
    deserializeProperty: deserializeFinancialGoalProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeFinancialGoal(IsarWriter writer, FinancialGoal object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.title);
  {
    final value = object.description;
    if (value == null) {
      IsarCore.writeNull(writer, 3);
    } else {
      IsarCore.writeString(writer, 3, value);
    }
  }
  IsarCore.writeDouble(writer, 4, object.targetAmount);
  IsarCore.writeDouble(writer, 5, object.currentAmount);
  IsarCore.writeByte(writer, 6, object.type.index);
  IsarCore.writeByte(writer, 7, object.status.index);
  IsarCore.writeLong(
      writer, 8, object.createdAt.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(
      writer,
      9,
      object.targetDate?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeLong(
      writer,
      10,
      object.completedAt?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  {
    final value = object.linkedDebtId;
    if (value == null) {
      IsarCore.writeNull(writer, 11);
    } else {
      IsarCore.writeString(writer, 11, value);
    }
  }
  {
    final value = object.linkedCategoryId;
    if (value == null) {
      IsarCore.writeNull(writer, 12);
    } else {
      IsarCore.writeString(writer, 12, value);
    }
  }
  IsarCore.writeLong(writer, 13, object.iconKey ?? -9223372036854775808);
  IsarCore.writeLong(writer, 14, object.colorValue ?? -9223372036854775808);
  IsarCore.writeDouble(writer, 15, object.progressPercentage);
  return Isar.fastHash(object.id);
}

@isarProtected
FinancialGoal deserializeFinancialGoal(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _title;
  _title = IsarCore.readString(reader, 2) ?? '';
  final String? _description;
  _description = IsarCore.readString(reader, 3);
  final double _targetAmount;
  _targetAmount = IsarCore.readDouble(reader, 4);
  final double _currentAmount;
  {
    final value = IsarCore.readDouble(reader, 5);
    if (value.isNaN) {
      _currentAmount = 0.0;
    } else {
      _currentAmount = value;
    }
  }
  final GoalType _type;
  {
    if (IsarCore.readNull(reader, 6)) {
      _type = GoalType.savings;
    } else {
      _type =
          _financialGoalType[IsarCore.readByte(reader, 6)] ?? GoalType.savings;
    }
  }
  final GoalStatus _status;
  {
    if (IsarCore.readNull(reader, 7)) {
      _status = GoalStatus.active;
    } else {
      _status = _financialGoalStatus[IsarCore.readByte(reader, 7)] ??
          GoalStatus.active;
    }
  }
  final DateTime _createdAt;
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      _createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final DateTime? _targetDate;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _targetDate = null;
    } else {
      _targetDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final DateTime? _completedAt;
  {
    final value = IsarCore.readLong(reader, 10);
    if (value == -9223372036854775808) {
      _completedAt = null;
    } else {
      _completedAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final String? _linkedDebtId;
  _linkedDebtId = IsarCore.readString(reader, 11);
  final String? _linkedCategoryId;
  _linkedCategoryId = IsarCore.readString(reader, 12);
  final int? _iconKey;
  {
    final value = IsarCore.readLong(reader, 13);
    if (value == -9223372036854775808) {
      _iconKey = null;
    } else {
      _iconKey = value;
    }
  }
  final int? _colorValue;
  {
    final value = IsarCore.readLong(reader, 14);
    if (value == -9223372036854775808) {
      _colorValue = null;
    } else {
      _colorValue = value;
    }
  }
  final object = FinancialGoal(
    id: _id,
    title: _title,
    description: _description,
    targetAmount: _targetAmount,
    currentAmount: _currentAmount,
    type: _type,
    status: _status,
    createdAt: _createdAt,
    targetDate: _targetDate,
    completedAt: _completedAt,
    linkedDebtId: _linkedDebtId,
    linkedCategoryId: _linkedCategoryId,
    iconKey: _iconKey,
    colorValue: _colorValue,
  );
  return object;
}

@isarProtected
dynamic deserializeFinancialGoalProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3);
    case 4:
      return IsarCore.readDouble(reader, 4);
    case 5:
      {
        final value = IsarCore.readDouble(reader, 5);
        if (value.isNaN) {
          return 0.0;
        } else {
          return value;
        }
      }
    case 6:
      {
        if (IsarCore.readNull(reader, 6)) {
          return GoalType.savings;
        } else {
          return _financialGoalType[IsarCore.readByte(reader, 6)] ??
              GoalType.savings;
        }
      }
    case 7:
      {
        if (IsarCore.readNull(reader, 7)) {
          return GoalStatus.active;
        } else {
          return _financialGoalStatus[IsarCore.readByte(reader, 7)] ??
              GoalStatus.active;
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 10:
      {
        final value = IsarCore.readLong(reader, 10);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 11:
      return IsarCore.readString(reader, 11);
    case 12:
      return IsarCore.readString(reader, 12);
    case 13:
      {
        final value = IsarCore.readLong(reader, 13);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 14:
      {
        final value = IsarCore.readLong(reader, 14);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 15:
      return IsarCore.readDouble(reader, 15);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _FinancialGoalUpdate {
  bool call({
    required String id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    GoalType? type,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? completedAt,
    String? linkedDebtId,
    String? linkedCategoryId,
    int? iconKey,
    int? colorValue,
    double? progressPercentage,
  });
}

class _FinancialGoalUpdateImpl implements _FinancialGoalUpdate {
  const _FinancialGoalUpdateImpl(this.collection);

  final IsarCollection<String, FinancialGoal> collection;

  @override
  bool call({
    required String id,
    Object? title = ignore,
    Object? description = ignore,
    Object? targetAmount = ignore,
    Object? currentAmount = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdAt = ignore,
    Object? targetDate = ignore,
    Object? completedAt = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedCategoryId = ignore,
    Object? iconKey = ignore,
    Object? colorValue = ignore,
    Object? progressPercentage = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (title != ignore) 2: title as String?,
          if (description != ignore) 3: description as String?,
          if (targetAmount != ignore) 4: targetAmount as double?,
          if (currentAmount != ignore) 5: currentAmount as double?,
          if (type != ignore) 6: type as GoalType?,
          if (status != ignore) 7: status as GoalStatus?,
          if (createdAt != ignore) 8: createdAt as DateTime?,
          if (targetDate != ignore) 9: targetDate as DateTime?,
          if (completedAt != ignore) 10: completedAt as DateTime?,
          if (linkedDebtId != ignore) 11: linkedDebtId as String?,
          if (linkedCategoryId != ignore) 12: linkedCategoryId as String?,
          if (iconKey != ignore) 13: iconKey as int?,
          if (colorValue != ignore) 14: colorValue as int?,
          if (progressPercentage != ignore) 15: progressPercentage as double?,
        }) >
        0;
  }
}

sealed class _FinancialGoalUpdateAll {
  int call({
    required List<String> id,
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    GoalType? type,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? completedAt,
    String? linkedDebtId,
    String? linkedCategoryId,
    int? iconKey,
    int? colorValue,
    double? progressPercentage,
  });
}

class _FinancialGoalUpdateAllImpl implements _FinancialGoalUpdateAll {
  const _FinancialGoalUpdateAllImpl(this.collection);

  final IsarCollection<String, FinancialGoal> collection;

  @override
  int call({
    required List<String> id,
    Object? title = ignore,
    Object? description = ignore,
    Object? targetAmount = ignore,
    Object? currentAmount = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdAt = ignore,
    Object? targetDate = ignore,
    Object? completedAt = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedCategoryId = ignore,
    Object? iconKey = ignore,
    Object? colorValue = ignore,
    Object? progressPercentage = ignore,
  }) {
    return collection.updateProperties(id, {
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (targetAmount != ignore) 4: targetAmount as double?,
      if (currentAmount != ignore) 5: currentAmount as double?,
      if (type != ignore) 6: type as GoalType?,
      if (status != ignore) 7: status as GoalStatus?,
      if (createdAt != ignore) 8: createdAt as DateTime?,
      if (targetDate != ignore) 9: targetDate as DateTime?,
      if (completedAt != ignore) 10: completedAt as DateTime?,
      if (linkedDebtId != ignore) 11: linkedDebtId as String?,
      if (linkedCategoryId != ignore) 12: linkedCategoryId as String?,
      if (iconKey != ignore) 13: iconKey as int?,
      if (colorValue != ignore) 14: colorValue as int?,
      if (progressPercentage != ignore) 15: progressPercentage as double?,
    });
  }
}

extension FinancialGoalUpdate on IsarCollection<String, FinancialGoal> {
  _FinancialGoalUpdate get update => _FinancialGoalUpdateImpl(this);

  _FinancialGoalUpdateAll get updateAll => _FinancialGoalUpdateAllImpl(this);
}

sealed class _FinancialGoalQueryUpdate {
  int call({
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    GoalType? type,
    GoalStatus? status,
    DateTime? createdAt,
    DateTime? targetDate,
    DateTime? completedAt,
    String? linkedDebtId,
    String? linkedCategoryId,
    int? iconKey,
    int? colorValue,
    double? progressPercentage,
  });
}

class _FinancialGoalQueryUpdateImpl implements _FinancialGoalQueryUpdate {
  const _FinancialGoalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<FinancialGoal> query;
  final int? limit;

  @override
  int call({
    Object? title = ignore,
    Object? description = ignore,
    Object? targetAmount = ignore,
    Object? currentAmount = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdAt = ignore,
    Object? targetDate = ignore,
    Object? completedAt = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedCategoryId = ignore,
    Object? iconKey = ignore,
    Object? colorValue = ignore,
    Object? progressPercentage = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (title != ignore) 2: title as String?,
      if (description != ignore) 3: description as String?,
      if (targetAmount != ignore) 4: targetAmount as double?,
      if (currentAmount != ignore) 5: currentAmount as double?,
      if (type != ignore) 6: type as GoalType?,
      if (status != ignore) 7: status as GoalStatus?,
      if (createdAt != ignore) 8: createdAt as DateTime?,
      if (targetDate != ignore) 9: targetDate as DateTime?,
      if (completedAt != ignore) 10: completedAt as DateTime?,
      if (linkedDebtId != ignore) 11: linkedDebtId as String?,
      if (linkedCategoryId != ignore) 12: linkedCategoryId as String?,
      if (iconKey != ignore) 13: iconKey as int?,
      if (colorValue != ignore) 14: colorValue as int?,
      if (progressPercentage != ignore) 15: progressPercentage as double?,
    });
  }
}

extension FinancialGoalQueryUpdate on IsarQuery<FinancialGoal> {
  _FinancialGoalQueryUpdate get updateFirst =>
      _FinancialGoalQueryUpdateImpl(this, limit: 1);

  _FinancialGoalQueryUpdate get updateAll =>
      _FinancialGoalQueryUpdateImpl(this);
}

class _FinancialGoalQueryBuilderUpdateImpl
    implements _FinancialGoalQueryUpdate {
  const _FinancialGoalQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<FinancialGoal, FinancialGoal, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? title = ignore,
    Object? description = ignore,
    Object? targetAmount = ignore,
    Object? currentAmount = ignore,
    Object? type = ignore,
    Object? status = ignore,
    Object? createdAt = ignore,
    Object? targetDate = ignore,
    Object? completedAt = ignore,
    Object? linkedDebtId = ignore,
    Object? linkedCategoryId = ignore,
    Object? iconKey = ignore,
    Object? colorValue = ignore,
    Object? progressPercentage = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (title != ignore) 2: title as String?,
        if (description != ignore) 3: description as String?,
        if (targetAmount != ignore) 4: targetAmount as double?,
        if (currentAmount != ignore) 5: currentAmount as double?,
        if (type != ignore) 6: type as GoalType?,
        if (status != ignore) 7: status as GoalStatus?,
        if (createdAt != ignore) 8: createdAt as DateTime?,
        if (targetDate != ignore) 9: targetDate as DateTime?,
        if (completedAt != ignore) 10: completedAt as DateTime?,
        if (linkedDebtId != ignore) 11: linkedDebtId as String?,
        if (linkedCategoryId != ignore) 12: linkedCategoryId as String?,
        if (iconKey != ignore) 13: iconKey as int?,
        if (colorValue != ignore) 14: colorValue as int?,
        if (progressPercentage != ignore) 15: progressPercentage as double?,
      });
    } finally {
      q.close();
    }
  }
}

extension FinancialGoalQueryBuilderUpdate
    on QueryBuilder<FinancialGoal, FinancialGoal, QOperations> {
  _FinancialGoalQueryUpdate get updateFirst =>
      _FinancialGoalQueryBuilderUpdateImpl(this, limit: 1);

  _FinancialGoalQueryUpdate get updateAll =>
      _FinancialGoalQueryBuilderUpdateImpl(this);
}

const _financialGoalType = {
  0: GoalType.savings,
  1: GoalType.debtPayoff,
  2: GoalType.purchase,
  3: GoalType.custom,
};
const _financialGoalStatus = {
  0: GoalStatus.active,
  1: GoalStatus.completed,
  2: GoalStatus.paused,
  3: GoalStatus.abandoned,
};

extension FinancialGoalQueryFilter
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idContains(
      String value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> idMatches(
      String pattern,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleGreaterThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleGreaterThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleLessThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleStartsWith(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleEndsWith(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 3));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionEqualTo(
    String? value, {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionGreaterThanOrEqualTo(
    String? value, {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionLessThan(
    String? value, {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionLessThanOrEqualTo(
    String? value, {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      descriptionBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountGreaterThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountGreaterThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountLessThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetAmountBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currentAmountEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currentAmountGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currentAmountGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currentAmountLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currentAmountLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      currentAmountBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> typeEqualTo(
    GoalType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      typeGreaterThan(
    GoalType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      typeGreaterThanOrEqualTo(
    GoalType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      typeLessThan(
    GoalType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      typeLessThanOrEqualTo(
    GoalType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value.index,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition> typeBetween(
    GoalType lower,
    GoalType upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower.index,
          upper: upper.index,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      statusEqualTo(
    GoalStatus value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      statusGreaterThan(
    GoalStatus value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      statusGreaterThanOrEqualTo(
    GoalStatus value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      statusLessThan(
    GoalStatus value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      statusLessThanOrEqualTo(
    GoalStatus value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      statusBetween(
    GoalStatus lower,
    GoalStatus upper,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateEqualTo(
    DateTime? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateGreaterThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateGreaterThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateLessThan(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateLessThanOrEqualTo(
    DateTime? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      targetDateBetween(
    DateTime? lower,
    DateTime? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtEqualTo(
    DateTime? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtGreaterThan(
    DateTime? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtGreaterThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtLessThan(
    DateTime? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtLessThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      completedAtBetween(
    DateTime? lower,
    DateTime? upper,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 11));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdGreaterThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdGreaterThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdLessThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdStartsWith(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdEndsWith(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedDebtIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 11,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 12));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdGreaterThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdGreaterThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdLessThan(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdLessThanOrEqualTo(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdBetween(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdStartsWith(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdEndsWith(
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      linkedCategoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 12,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 13));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyEqualTo(
    int? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyGreaterThan(
    int? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyGreaterThanOrEqualTo(
    int? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyLessThan(
    int? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyLessThanOrEqualTo(
    int? value,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      iconKeyBetween(
    int? lower,
    int? upper,
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

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 14));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 14));
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueGreaterThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueLessThanOrEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 14,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      colorValueBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 14,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      progressPercentageEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 15,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      progressPercentageGreaterThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 15,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      progressPercentageGreaterThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 15,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      progressPercentageLessThan(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 15,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      progressPercentageLessThanOrEqualTo(
    double value, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 15,
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterFilterCondition>
      progressPercentageBetween(
    double lower,
    double upper, {
    double epsilon = Filter.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 15,
          lower: lower,
          upper: upper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension FinancialGoalQueryObject
    on QueryBuilder<FinancialGoal, FinancialGoal, QFilterCondition> {}

extension FinancialGoalQuerySortBy
    on QueryBuilder<FinancialGoal, FinancialGoal, QSortBy> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByTitleDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByCurrentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByLinkedDebtId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByLinkedDebtIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        11,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByLinkedCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByLinkedCategoryIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        12,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByIconKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByIconKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByProgressPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      sortByProgressPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }
}

extension FinancialGoalQuerySortThenBy
    on QueryBuilder<FinancialGoal, FinancialGoal, QSortThenBy> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByTitleDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByCurrentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByTargetDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByCompletedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByLinkedDebtId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByLinkedDebtIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByLinkedCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByLinkedCategoryIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(12, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByIconKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByIconKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(13, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(14, sort: Sort.desc);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByProgressPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterSortBy>
      thenByProgressPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(15, sort: Sort.desc);
    });
  }
}

extension FinancialGoalQueryWhereDistinct
    on QueryBuilder<FinancialGoal, FinancialGoal, QDistinct> {
  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByCurrentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByTargetDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByCompletedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByLinkedDebtId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByLinkedCategoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(12, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByIconKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(13);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(14);
    });
  }

  QueryBuilder<FinancialGoal, FinancialGoal, QAfterDistinct>
      distinctByProgressPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(15);
    });
  }
}

extension FinancialGoalQueryProperty1
    on QueryBuilder<FinancialGoal, FinancialGoal, QProperty> {
  QueryBuilder<FinancialGoal, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FinancialGoal, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FinancialGoal, String?, QAfterProperty> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FinancialGoal, double, QAfterProperty> targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FinancialGoal, double, QAfterProperty> currentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FinancialGoal, GoalType, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FinancialGoal, GoalStatus, QAfterProperty> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FinancialGoal, DateTime, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FinancialGoal, DateTime?, QAfterProperty> targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<FinancialGoal, DateTime?, QAfterProperty> completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<FinancialGoal, String?, QAfterProperty> linkedDebtIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<FinancialGoal, String?, QAfterProperty>
      linkedCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<FinancialGoal, int?, QAfterProperty> iconKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<FinancialGoal, int?, QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<FinancialGoal, double, QAfterProperty>
      progressPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }
}

extension FinancialGoalQueryProperty2<R>
    on QueryBuilder<FinancialGoal, R, QAfterProperty> {
  QueryBuilder<FinancialGoal, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FinancialGoal, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FinancialGoal, (R, String?), QAfterProperty>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FinancialGoal, (R, double), QAfterProperty>
      targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FinancialGoal, (R, double), QAfterProperty>
      currentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FinancialGoal, (R, GoalType), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FinancialGoal, (R, GoalStatus), QAfterProperty>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FinancialGoal, (R, DateTime), QAfterProperty>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FinancialGoal, (R, DateTime?), QAfterProperty>
      targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<FinancialGoal, (R, DateTime?), QAfterProperty>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<FinancialGoal, (R, String?), QAfterProperty>
      linkedDebtIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<FinancialGoal, (R, String?), QAfterProperty>
      linkedCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<FinancialGoal, (R, int?), QAfterProperty> iconKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<FinancialGoal, (R, int?), QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<FinancialGoal, (R, double), QAfterProperty>
      progressPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }
}

extension FinancialGoalQueryProperty3<R1, R2>
    on QueryBuilder<FinancialGoal, (R1, R2), QAfterProperty> {
  QueryBuilder<FinancialGoal, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, String), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, String?), QOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, double), QOperations>
      targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, double), QOperations>
      currentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, GoalType), QOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, GoalStatus), QOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, DateTime?), QOperations>
      targetDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, DateTime?), QOperations>
      completedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, String?), QOperations>
      linkedDebtIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, String?), QOperations>
      linkedCategoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(12);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, int?), QOperations> iconKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(13);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, int?), QOperations>
      colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(14);
    });
  }

  QueryBuilder<FinancialGoal, (R1, R2, double), QOperations>
      progressPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(15);
    });
  }
}
