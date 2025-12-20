// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final typeId = 5;

  @override
  Category read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Category(
      id: fields[0] as String,
      name: fields[1] as String,
      icon: fields[2] as String,
      colorValue: (fields[3] as num).toInt(),
      type: fields[4] as TransactionType,
      isDefault: fields[5] == null ? false : fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.icon)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetCategoryCollection on Isar {
  IsarCollection<String, Category> get categorys => this.collection();
}

final CategorySchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'Category',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(
        name: 'id',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'name',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'icon',
        type: IsarType.string,
      ),
      IsarPropertySchema(
        name: 'colorValue',
        type: IsarType.long,
      ),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.byte,
        enumMap: {"income": 0, "expense": 1},
      ),
      IsarPropertySchema(
        name: 'isDefault',
        type: IsarType.bool,
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, Category>(
    serialize: serializeCategory,
    deserialize: deserializeCategory,
    deserializeProperty: deserializeCategoryProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeCategory(IsarWriter writer, Category object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeString(writer, 3, object.icon);
  IsarCore.writeLong(writer, 4, object.colorValue);
  IsarCore.writeByte(writer, 5, object.type.index);
  IsarCore.writeBool(writer, 6, value: object.isDefault);
  return Isar.fastHash(object.id);
}

@isarProtected
Category deserializeCategory(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _name;
  _name = IsarCore.readString(reader, 2) ?? '';
  final String _icon;
  _icon = IsarCore.readString(reader, 3) ?? '';
  final int _colorValue;
  _colorValue = IsarCore.readLong(reader, 4);
  final TransactionType _type;
  {
    if (IsarCore.readNull(reader, 5)) {
      _type = TransactionType.income;
    } else {
      _type =
          _categoryType[IsarCore.readByte(reader, 5)] ?? TransactionType.income;
    }
  }
  final bool _isDefault;
  _isDefault = IsarCore.readBool(reader, 6);
  final object = Category(
    id: _id,
    name: _name,
    icon: _icon,
    colorValue: _colorValue,
    type: _type,
    isDefault: _isDefault,
  );
  return object;
}

@isarProtected
dynamic deserializeCategoryProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      {
        if (IsarCore.readNull(reader, 5)) {
          return TransactionType.income;
        } else {
          return _categoryType[IsarCore.readByte(reader, 5)] ??
              TransactionType.income;
        }
      }
    case 6:
      return IsarCore.readBool(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _CategoryUpdate {
  bool call({
    required String id,
    String? name,
    String? icon,
    int? colorValue,
    TransactionType? type,
    bool? isDefault,
  });
}

class _CategoryUpdateImpl implements _CategoryUpdate {
  const _CategoryUpdateImpl(this.collection);

  final IsarCollection<String, Category> collection;

  @override
  bool call({
    required String id,
    Object? name = ignore,
    Object? icon = ignore,
    Object? colorValue = ignore,
    Object? type = ignore,
    Object? isDefault = ignore,
  }) {
    return collection.updateProperties([
          id
        ], {
          if (name != ignore) 2: name as String?,
          if (icon != ignore) 3: icon as String?,
          if (colorValue != ignore) 4: colorValue as int?,
          if (type != ignore) 5: type as TransactionType?,
          if (isDefault != ignore) 6: isDefault as bool?,
        }) >
        0;
  }
}

sealed class _CategoryUpdateAll {
  int call({
    required List<String> id,
    String? name,
    String? icon,
    int? colorValue,
    TransactionType? type,
    bool? isDefault,
  });
}

class _CategoryUpdateAllImpl implements _CategoryUpdateAll {
  const _CategoryUpdateAllImpl(this.collection);

  final IsarCollection<String, Category> collection;

  @override
  int call({
    required List<String> id,
    Object? name = ignore,
    Object? icon = ignore,
    Object? colorValue = ignore,
    Object? type = ignore,
    Object? isDefault = ignore,
  }) {
    return collection.updateProperties(id, {
      if (name != ignore) 2: name as String?,
      if (icon != ignore) 3: icon as String?,
      if (colorValue != ignore) 4: colorValue as int?,
      if (type != ignore) 5: type as TransactionType?,
      if (isDefault != ignore) 6: isDefault as bool?,
    });
  }
}

extension CategoryUpdate on IsarCollection<String, Category> {
  _CategoryUpdate get update => _CategoryUpdateImpl(this);

  _CategoryUpdateAll get updateAll => _CategoryUpdateAllImpl(this);
}

sealed class _CategoryQueryUpdate {
  int call({
    String? name,
    String? icon,
    int? colorValue,
    TransactionType? type,
    bool? isDefault,
  });
}

class _CategoryQueryUpdateImpl implements _CategoryQueryUpdate {
  const _CategoryQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<Category> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? icon = ignore,
    Object? colorValue = ignore,
    Object? type = ignore,
    Object? isDefault = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 2: name as String?,
      if (icon != ignore) 3: icon as String?,
      if (colorValue != ignore) 4: colorValue as int?,
      if (type != ignore) 5: type as TransactionType?,
      if (isDefault != ignore) 6: isDefault as bool?,
    });
  }
}

extension CategoryQueryUpdate on IsarQuery<Category> {
  _CategoryQueryUpdate get updateFirst =>
      _CategoryQueryUpdateImpl(this, limit: 1);

  _CategoryQueryUpdate get updateAll => _CategoryQueryUpdateImpl(this);
}

class _CategoryQueryBuilderUpdateImpl implements _CategoryQueryUpdate {
  const _CategoryQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<Category, Category, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? icon = ignore,
    Object? colorValue = ignore,
    Object? type = ignore,
    Object? isDefault = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 2: name as String?,
        if (icon != ignore) 3: icon as String?,
        if (colorValue != ignore) 4: colorValue as int?,
        if (type != ignore) 5: type as TransactionType?,
        if (isDefault != ignore) 6: isDefault as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension CategoryQueryBuilderUpdate
    on QueryBuilder<Category, Category, QOperations> {
  _CategoryQueryUpdate get updateFirst =>
      _CategoryQueryBuilderUpdateImpl(this, limit: 1);

  _CategoryQueryUpdate get updateAll => _CategoryQueryBuilderUpdateImpl(this);
}

const _categoryType = {
  0: TransactionType.income,
  1: TransactionType.expense,
};

extension CategoryQueryFilter
    on QueryBuilder<Category, Category, QFilterCondition> {
  QueryBuilder<Category, Category, QAfterFilterCondition> idEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition>
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idLessThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idStartsWith(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idEndsWith(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idContains(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idMatches(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 1,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameGreaterThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition>
      nameGreaterThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameLessThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameLessThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameStartsWith(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameContains(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 2,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> iconEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconGreaterThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition>
      iconGreaterThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconLessThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconLessThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconBetween(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconStartsWith(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconEndsWith(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconContains(
      String value,
      {bool caseSensitive = true}) {
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconMatches(
      String pattern,
      {bool caseSensitive = true}) {
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

  QueryBuilder<Category, Category, QAfterFilterCondition> iconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> iconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(
          property: 3,
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Category, Category, QAfterFilterCondition> colorValueEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> colorValueGreaterThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition>
      colorValueGreaterThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> colorValueLessThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition>
      colorValueLessThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> colorValueBetween(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> typeEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> typeGreaterThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition>
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

  QueryBuilder<Category, Category, QAfterFilterCondition> typeLessThan(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> typeLessThanOrEqualTo(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> typeBetween(
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

  QueryBuilder<Category, Category, QAfterFilterCondition> isDefaultEqualTo(
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
}

extension CategoryQueryObject
    on QueryBuilder<Category, Category, QFilterCondition> {}

extension CategoryQuerySortBy on QueryBuilder<Category, Category, QSortBy> {
  QueryBuilder<Category, Category, QAfterSortBy> sortById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        1,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        2,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByIcon(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByIconDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(
        3,
        sort: Sort.desc,
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> sortByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension CategoryQuerySortThenBy
    on QueryBuilder<Category, Category, QSortThenBy> {
  QueryBuilder<Category, Category, QAfterSortBy> thenById(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByIdDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByNameDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByIcon(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByIconDesc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<Category, Category, QAfterSortBy> thenByIsDefaultDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension CategoryQueryWhereDistinct
    on QueryBuilder<Category, Category, QDistinct> {
  QueryBuilder<Category, Category, QAfterDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterDistinct> distinctByIcon(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Category, Category, QAfterDistinct> distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<Category, Category, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<Category, Category, QAfterDistinct> distinctByIsDefault() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }
}

extension CategoryQueryProperty1
    on QueryBuilder<Category, Category, QProperty> {
  QueryBuilder<Category, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Category, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Category, String, QAfterProperty> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Category, int, QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Category, TransactionType, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Category, bool, QAfterProperty> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension CategoryQueryProperty2<R>
    on QueryBuilder<Category, R, QAfterProperty> {
  QueryBuilder<Category, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Category, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Category, (R, String), QAfterProperty> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Category, (R, int), QAfterProperty> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Category, (R, TransactionType), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Category, (R, bool), QAfterProperty> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension CategoryQueryProperty3<R1, R2>
    on QueryBuilder<Category, (R1, R2), QAfterProperty> {
  QueryBuilder<Category, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Category, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Category, (R1, R2, String), QOperations> iconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Category, (R1, R2, int), QOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Category, (R1, R2, TransactionType), QOperations>
      typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Category, (R1, R2, bool), QOperations> isDefaultProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}
