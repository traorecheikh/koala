// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalUserAdapter extends TypeAdapter<LocalUser> {
  @override
  final typeId = 0;

  @override
  LocalUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalUser(
      id: fields[7] == null ? '' : fields[7] as String,
      fullName: fields[0] as String,
      salary: (fields[1] as num).toDouble(),
      payday: (fields[2] as num).toInt(),
      age: (fields[3] as num).toInt(),
      budgetingType: fields[4] as String,
      firstLaunchDate: fields[5] as DateTime?,
      hasCompletedCatchUp: fields[6] == null ? false : fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LocalUser obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.fullName)
      ..writeByte(1)
      ..write(obj.salary)
      ..writeByte(2)
      ..write(obj.payday)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.budgetingType)
      ..writeByte(5)
      ..write(obj.firstLaunchDate)
      ..writeByte(6)
      ..write(obj.hasCompletedCatchUp)
      ..writeByte(7)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetLocalUserCollection on Isar {
  IsarCollection<String, LocalUser> get localUsers => this.collection();
}

final LocalUserSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'LocalUser',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'fullName',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'salary',
        type: IsarType.double,
      ),
      IsarPropertySchema(
        name: 'payday',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'age',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'budgetingType',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'firstLaunchDate',
        type: IsarType.dateTime,
      ),
      IsarPropertySchema(
        name: 'hasCompletedCatchUp',
        type: IsarType.bool,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, LocalUser>(
    serialize: serializeLocalUser,
    deserialize: deserializeLocalUser,
    deserializeProperty: deserializeLocalUserProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeLocalUser(IsarWriter writer, LocalUser object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.fullName);
  IsarCore.writeDouble(writer, 3, object.salary);
  IsarCore.writeLong(writer, 4, object.payday);
  IsarCore.writeLong(writer, 5, object.age);
  IsarCore.writeString(writer, 6, object.budgetingType);
  IsarCore.writeLong(
      writer,
      7,
      object.firstLaunchDate?.toUtc().microsecondsSinceEpoch ??
          -9223372036854775808);
  IsarCore.writeBool(writer, 8, value: object.hasCompletedCatchUp);
  return Isar.fastHash(object.id);
}

@isarProtected
LocalUser deserializeLocalUser(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _fullName;
  _fullName = IsarCore.readString(reader, 2) ?? '';
  final double _salary;
  _salary = IsarCore.readDouble(reader, 3);
  final int _payday;
  _payday = IsarCore.readLong(reader, 4);
  final int _age;
  _age = IsarCore.readLong(reader, 5);
  final String _budgetingType;
  _budgetingType = IsarCore.readString(reader, 6) ?? '';
  final DateTime? _firstLaunchDate;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _firstLaunchDate = null;
    } else {
      _firstLaunchDate =
          DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final bool _hasCompletedCatchUp;
  _hasCompletedCatchUp = IsarCore.readBool(reader, 8);
  final object = LocalUser(
    id: _id,
    fullName: _fullName,
    salary: _salary,
    payday: _payday,
    age: _age,
    budgetingType: _budgetingType,
    firstLaunchDate: _firstLaunchDate,
    hasCompletedCatchUp: _hasCompletedCatchUp,
  );
  return object;
}

@isarProtected
dynamic deserializeLocalUserProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readDouble(reader, 3);
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      return IsarCore.readLong(reader, 5);
    case 6:
      return IsarCore.readString(reader, 6) ?? '';
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)
              .toLocal();
        }
      }
    case 8:
      return IsarCore.readBool(reader, 8);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _LocalUserUpdate {
  bool call({
    required String id,
    String? fullName,
    double? salary,
    int? payday,
    int? age,
    String? budgetingType,
    DateTime? firstLaunchDate,
    bool? hasCompletedCatchUp,
  });
}

class _LocalUserUpdateImpl implements _LocalUserUpdate {
  const _LocalUserUpdateImpl(this.collection);

  final IsarCollection<String, LocalUser> collection;

  @override
  bool call({
    required String id,
    Object? fullName = ignore,
    Object? salary = ignore,
    Object? payday = ignore,
    Object? age = ignore,
    Object? budgetingType = ignore,
    Object? firstLaunchDate = ignore,
    Object? hasCompletedCatchUp = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (fullName != ignore) 2: fullName as String?,
          if (salary != ignore) 3: salary as double?,
          if (payday != ignore) 4: payday as int?,
          if (age != ignore) 5: age as int?,
          if (budgetingType != ignore) 6: budgetingType as String?,
          if (firstLaunchDate != ignore) 7: firstLaunchDate as DateTime?,
          if (hasCompletedCatchUp != ignore) 8: hasCompletedCatchUp as bool?,
        }) >
        0;
  }
}

sealed class _LocalUserUpdateAll {
  int call({
    required List<String> id,
    String? fullName,
    double? salary,
    int? payday,
    int? age,
    String? budgetingType,
    DateTime? firstLaunchDate,
    bool? hasCompletedCatchUp,
  });
}

class _LocalUserUpdateAllImpl implements _LocalUserUpdateAll {
  const _LocalUserUpdateAllImpl(this.collection);

  final IsarCollection<String, LocalUser> collection;

  @override
  int call({
    required List<String> id,
    Object? fullName = ignore,
    Object? salary = ignore,
    Object? payday = ignore,
    Object? age = ignore,
    Object? budgetingType = ignore,
    Object? firstLaunchDate = ignore,
    Object? hasCompletedCatchUp = ignore,
  }) {
    return collection.updateProperties(id, {
      if (fullName != ignore) 2: fullName as String?,
      if (salary != ignore) 3: salary as double?,
      if (payday != ignore) 4: payday as int?,
      if (age != ignore) 5: age as int?,
      if (budgetingType != ignore) 6: budgetingType as String?,
      if (firstLaunchDate != ignore) 7: firstLaunchDate as DateTime?,
      if (hasCompletedCatchUp != ignore) 8: hasCompletedCatchUp as bool?,
    });
  }
}

extension LocalUserUpdate on IsarCollection<String, LocalUser> {
  _LocalUserUpdate get update => _LocalUserUpdateImpl(this);

  _LocalUserUpdateAll get updateAll => _LocalUserUpdateAllImpl(this);
}

sealed class _LocalUserQueryUpdate {
  int call({
    String? fullName,
    double? salary,
    int? payday,
    int? age,
    String? budgetingType,
    DateTime? firstLaunchDate,
    bool? hasCompletedCatchUp,
  });
}

class _LocalUserQueryUpdateImpl implements _LocalUserQueryUpdate {
  const _LocalUserQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<LocalUser> query;
  final int? limit;

  @override
  int call({
    Object? fullName = ignore,
    Object? salary = ignore,
    Object? payday = ignore,
    Object? age = ignore,
    Object? budgetingType = ignore,
    Object? firstLaunchDate = ignore,
    Object? hasCompletedCatchUp = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (fullName != ignore) 2: fullName as String?,
      if (salary != ignore) 3: salary as double?,
      if (payday != ignore) 4: payday as int?,
      if (age != ignore) 5: age as int?,
      if (budgetingType != ignore) 6: budgetingType as String?,
      if (firstLaunchDate != ignore) 7: firstLaunchDate as DateTime?,
      if (hasCompletedCatchUp != ignore) 8: hasCompletedCatchUp as bool?,
    });
  }
}

extension LocalUserQueryUpdate on IsarQuery<LocalUser> {
  _LocalUserQueryUpdate get updateFirst =>
      _LocalUserQueryUpdateImpl(this, limit: 1);

  _LocalUserQueryUpdate get updateAll => _LocalUserQueryUpdateImpl(this);
}

class _LocalUserQueryBuilderUpdateImpl implements _LocalUserQueryUpdate {
  const _LocalUserQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<LocalUser, LocalUser, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? fullName = ignore,
    Object? salary = ignore,
    Object? payday = ignore,
    Object? age = ignore,
    Object? budgetingType = ignore,
    Object? firstLaunchDate = ignore,
    Object? hasCompletedCatchUp = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (fullName != ignore) 2: fullName as String?,
        if (salary != ignore) 3: salary as double?,
        if (payday != ignore) 4: payday as int?,
        if (age != ignore) 5: age as int?,
        if (budgetingType != ignore) 6: budgetingType as String?,
        if (firstLaunchDate != ignore) 7: firstLaunchDate as DateTime?,
        if (hasCompletedCatchUp != ignore) 8: hasCompletedCatchUp as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension LocalUserQueryBuilderUpdate
    on QueryBuilder<LocalUser, LocalUser, QOperations> {
  _LocalUserQueryUpdate get updateFirst =>
      _LocalUserQueryBuilderUpdateImpl(this, limit: 1);

  _LocalUserQueryUpdate get updateAll => _LocalUserQueryBuilderUpdateImpl(this);
}

extension LocalUserQueryFilter
    on QueryBuilder<LocalUser, LocalUser, QFilterCondition> {
  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idLessThanOrEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idContains(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idMatches(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameGreaterThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      fullNameGreaterThanOrEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameLessThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      fullNameLessThanOrEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameBetween(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameStartsWith(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameEndsWith(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameContains(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameMatches(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> salaryEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> salaryGreaterThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      salaryGreaterThanOrEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> salaryLessThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      salaryLessThanOrEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> salaryBetween(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> paydayEqualTo(
    int value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> paydayGreaterThan(
    int value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      paydayGreaterThanOrEqualTo(
    int value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> paydayLessThan(
    int value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      paydayLessThanOrEqualTo(
    int value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> paydayBetween(
    int lower,
    int upper,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> ageEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> ageGreaterThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      ageGreaterThanOrEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> ageLessThan(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      ageLessThanOrEqualTo(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition> ageBetween(
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      budgetingTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 6,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateEqualTo(
    DateTime? value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateGreaterThan(
    DateTime? value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateGreaterThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateLessThan(
    DateTime? value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateLessThanOrEqualTo(
    DateTime? value,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      firstLaunchDateBetween(
    DateTime? lower,
    DateTime? upper,
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

  QueryBuilder<LocalUser, LocalUser, QAfterFilterCondition>
      hasCompletedCatchUpEqualTo(
    bool value,
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
}

extension LocalUserQueryObject
    on QueryBuilder<LocalUser, LocalUser, QFilterCondition> {}

extension LocalUserQuerySortBy on QueryBuilder<LocalUser, LocalUser, QSortBy> {
  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByFullNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortBySalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortBySalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByPaydayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByBudgetingType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByBudgetingTypeDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        6,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByFirstLaunchDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByFirstLaunchDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> sortByHasCompletedCatchUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy>
      sortByHasCompletedCatchUpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension LocalUserQuerySortThenBy
    on QueryBuilder<LocalUser, LocalUser, QSortThenBy> {
  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByFullNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenBySalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenBySalaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByPaydayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByBudgetingType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByBudgetingTypeDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByFirstLaunchDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByFirstLaunchDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy> thenByHasCompletedCatchUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterSortBy>
      thenByHasCompletedCatchUpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension LocalUserQueryWhereDistinct
    on QueryBuilder<LocalUser, LocalUser, QDistinct> {
  QueryBuilder<LocalUser, LocalUser, QAfterDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterDistinct> distinctBySalary() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterDistinct> distinctByPayday() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterDistinct> distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterDistinct> distinctByBudgetingType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterDistinct>
      distinctByFirstLaunchDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<LocalUser, LocalUser, QAfterDistinct>
      distinctByHasCompletedCatchUp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension LocalUserQueryProperty1
    on QueryBuilder<LocalUser, LocalUser, QProperty> {
  QueryBuilder<LocalUser, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalUser, String, QAfterProperty> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalUser, double, QAfterProperty> salaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalUser, int, QAfterProperty> paydayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalUser, int, QAfterProperty> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalUser, String, QAfterProperty> budgetingTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalUser, DateTime?, QAfterProperty> firstLaunchDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalUser, bool, QAfterProperty> hasCompletedCatchUpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension LocalUserQueryProperty2<R>
    on QueryBuilder<LocalUser, R, QAfterProperty> {
  QueryBuilder<LocalUser, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalUser, (R, String), QAfterProperty> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalUser, (R, double), QAfterProperty> salaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalUser, (R, int), QAfterProperty> paydayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalUser, (R, int), QAfterProperty> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalUser, (R, String), QAfterProperty> budgetingTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalUser, (R, DateTime?), QAfterProperty>
      firstLaunchDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalUser, (R, bool), QAfterProperty>
      hasCompletedCatchUpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension LocalUserQueryProperty3<R1, R2>
    on QueryBuilder<LocalUser, (R1, R2), QAfterProperty> {
  QueryBuilder<LocalUser, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<LocalUser, (R1, R2, String), QOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<LocalUser, (R1, R2, double), QOperations> salaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<LocalUser, (R1, R2, int), QOperations> paydayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<LocalUser, (R1, R2, int), QOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<LocalUser, (R1, R2, String), QOperations>
      budgetingTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<LocalUser, (R1, R2, DateTime?), QOperations>
      firstLaunchDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<LocalUser, (R1, R2, bool), QOperations>
      hasCompletedCatchUpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}
