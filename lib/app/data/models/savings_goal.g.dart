// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsGoalAdapter extends TypeAdapter<SavingsGoal> {
  @override
  final typeId = 11;

  @override
  SavingsGoal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavingsGoal(
      id: fields[0] as String,
      targetAmount: (fields[1] as num).toDouble(),
      year: (fields[3] as num).toInt(),
      month: (fields[4] as num).toInt(),
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsGoal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.targetAmount)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.month);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsGoalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSavingsGoalCollection on Isar {
  IsarCollection<String, SavingsGoal> get savingsGoals => this.collection();
}

final SavingsGoalSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SavingsGoal',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'year',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'month',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'targetAmount',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'createdAt',
        type: IsarType.dateTime,
      ),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'year',
        properties: [
          "year",
        ],
        unique: false,
        hash: false,
      ),
      IsarIndexSchema(
        name: 'month',
        properties: [
          "month",
        ],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, SavingsGoal>(
    serialize: serializeSavingsGoal,
    deserialize: deserializeSavingsGoal,
    deserializeProperty: deserializeSavingsGoalProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeSavingsGoal(IsarWriter writer, SavingsGoal object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeLong(writer, 2, object.year);
  IsarCore.writeLong(writer, 3, object.month);
  IsarCore.writeDouble(writer, 4, object.targetAmount);
  IsarCore.writeLong(
      writer, 5, object.createdAt.toUtc().microsecondsSinceEpoch);
  return Isar.fastHash(object.id);
}

@isarProtected
SavingsGoal deserializeSavingsGoal(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final int _year;
  _year = IsarCore.readLong(reader, 2);
  final int _month;
  _month = IsarCore.readLong(reader, 3);
  final double _targetAmount;
  _targetAmount = IsarCore.readDouble(reader, 4);
  final DateTime _createdAt;
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _createdAt =
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _createdAt =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final object = SavingsGoal(
    id: _id,
    year: _year,
    month: _month,
    targetAmount: _targetAmount,
    createdAt: _createdAt,
  );
  return object;
}

@isarProtected
dynamic deserializeSavingsGoalProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readLong(reader, 2);
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      return IsarCore.readDouble(reader, 4);
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
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

sealed class _SavingsGoalUpdate {
  bool call({
    required String id,
    int? year,
    int? month,
    double? targetAmount,
    DateTime? createdAt,
  });
}

class _SavingsGoalUpdateImpl implements _SavingsGoalUpdate {
  const _SavingsGoalUpdateImpl(this.collection);

  final IsarCollection<String, SavingsGoal> collection;

  @override
  bool call({
    required String id,
    Object? year = ignore,
    Object? month = ignore,
    Object? targetAmount = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (year != ignore) 2: year as int?,
          if (month != ignore) 3: month as int?,
          if (targetAmount != ignore) 4: targetAmount as double?,
          if (createdAt != ignore) 5: createdAt as DateTime?,
        }) >
        0;
  }
}

sealed class _SavingsGoalUpdateAll {
  int call({
    required List<String> id,
    int? year,
    int? month,
    double? targetAmount,
    DateTime? createdAt,
  });
}

class _SavingsGoalUpdateAllImpl implements _SavingsGoalUpdateAll {
  const _SavingsGoalUpdateAllImpl(this.collection);

  final IsarCollection<String, SavingsGoal> collection;

  @override
  int call({
    required List<String> id,
    Object? year = ignore,
    Object? month = ignore,
    Object? targetAmount = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (year != ignore) 2: year as int?,
      if (month != ignore) 3: month as int?,
      if (targetAmount != ignore) 4: targetAmount as double?,
      if (createdAt != ignore) 5: createdAt as DateTime?,
    });
  }
}

extension SavingsGoalUpdate on IsarCollection<String, SavingsGoal> {
  _SavingsGoalUpdate get update => _SavingsGoalUpdateImpl(this);

  _SavingsGoalUpdateAll get updateAll => _SavingsGoalUpdateAllImpl(this);
}

sealed class _SavingsGoalQueryUpdate {
  int call({
    int? year,
    int? month,
    double? targetAmount,
    DateTime? createdAt,
  });
}

class _SavingsGoalQueryUpdateImpl implements _SavingsGoalQueryUpdate {
  const _SavingsGoalQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<SavingsGoal> query;
  final int? limit;

  @override
  int call({
    Object? year = ignore,
    Object? month = ignore,
    Object? targetAmount = ignore,
    Object? createdAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (year != ignore) 2: year as int?,
      if (month != ignore) 3: month as int?,
      if (targetAmount != ignore) 4: targetAmount as double?,
      if (createdAt != ignore) 5: createdAt as DateTime?,
    });
  }
}

extension SavingsGoalQueryUpdate on IsarQuery<SavingsGoal> {
  _SavingsGoalQueryUpdate get updateFirst =>
      _SavingsGoalQueryUpdateImpl(this, limit: 1);

  _SavingsGoalQueryUpdate get updateAll => _SavingsGoalQueryUpdateImpl(this);
}

class _SavingsGoalQueryBuilderUpdateImpl implements _SavingsGoalQueryUpdate {
  const _SavingsGoalQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<SavingsGoal, SavingsGoal, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? year = ignore,
    Object? month = ignore,
    Object? targetAmount = ignore,
    Object? createdAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (year != ignore) 2: year as int?,
        if (month != ignore) 3: month as int?,
        if (targetAmount != ignore) 4: targetAmount as double?,
        if (createdAt != ignore) 5: createdAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension SavingsGoalQueryBuilderUpdate
    on QueryBuilder<SavingsGoal, SavingsGoal, QOperations> {
  _SavingsGoalQueryUpdate get updateFirst =>
      _SavingsGoalQueryBuilderUpdateImpl(this, limit: 1);

  _SavingsGoalQueryUpdate get updateAll =>
      _SavingsGoalQueryBuilderUpdateImpl(this);
}

extension SavingsGoalQueryFilter
    on QueryBuilder<SavingsGoal, SavingsGoal, QFilterCondition> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idContains(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idMatches(
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> yearEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> yearGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      yearGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> yearLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      yearLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> yearBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> monthEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      monthGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      monthGreaterThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> monthLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      monthLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition> monthBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
        ),
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtEqualTo(
    DateTime value,
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value,
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtGreaterThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value,
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtLessThanOrEqualTo(
    DateTime value,
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

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper,
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
}

extension SavingsGoalQueryObject
    on QueryBuilder<SavingsGoal, SavingsGoal, QFilterCondition> {}

extension SavingsGoalQuerySortBy
    on QueryBuilder<SavingsGoal, SavingsGoal, QSortBy> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy>
      sortByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension SavingsGoalQuerySortThenBy
    on QueryBuilder<SavingsGoal, SavingsGoal, QSortThenBy> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy>
      thenByTargetAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }
}

extension SavingsGoalQueryWhereDistinct
    on QueryBuilder<SavingsGoal, SavingsGoal, QDistinct> {
  QueryBuilder<SavingsGoal, SavingsGoal, QAfterDistinct> distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterDistinct> distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterDistinct>
      distinctByTargetAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<SavingsGoal, SavingsGoal, QAfterDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }
}

extension SavingsGoalQueryProperty1
    on QueryBuilder<SavingsGoal, SavingsGoal, QProperty> {
  QueryBuilder<SavingsGoal, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SavingsGoal, int, QAfterProperty> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SavingsGoal, int, QAfterProperty> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SavingsGoal, double, QAfterProperty> targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SavingsGoal, DateTime, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension SavingsGoalQueryProperty2<R>
    on QueryBuilder<SavingsGoal, R, QAfterProperty> {
  QueryBuilder<SavingsGoal, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SavingsGoal, (R, int), QAfterProperty> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SavingsGoal, (R, int), QAfterProperty> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SavingsGoal, (R, double), QAfterProperty>
      targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SavingsGoal, (R, DateTime), QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}

extension SavingsGoalQueryProperty3<R1, R2>
    on QueryBuilder<SavingsGoal, (R1, R2), QAfterProperty> {
  QueryBuilder<SavingsGoal, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SavingsGoal, (R1, R2, int), QOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SavingsGoal, (R1, R2, int), QOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SavingsGoal, (R1, R2, double), QOperations>
      targetAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SavingsGoal, (R1, R2, DateTime), QOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }
}
