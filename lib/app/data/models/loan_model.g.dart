// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoanModelAdapter extends TypeAdapter<LoanModel> {
  @override
  final typeId = 4;

  @override
  LoanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoanModel(
      id: fields[0] as String?,
      userId: fields[1] as String,
      title: fields[2] as String?,
      principalAmount: (fields[3] as num).toDouble(),
      remainingAmount: (fields[4] as num).toDouble(),
      interestRate: fields[5] == null ? 0.0 : (fields[5] as num).toDouble(),
      monthlyPayment: (fields[6] as num).toDouble(),
      startDate: fields[7] as DateTime,
      endDate: fields[8] as DateTime,
      nextPaymentDate: fields[9] as DateTime,
      status: fields[10] == null ? LoanStatus.active : fields[10] as LoanStatus,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LoanModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.principalAmount)
      ..writeByte(4)
      ..write(obj.remainingAmount)
      ..writeByte(5)
      ..write(obj.interestRate)
      ..writeByte(6)
      ..write(obj.monthlyPayment)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.nextPaymentDate)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LoanStatusAdapter extends TypeAdapter<LoanStatus> {
  @override
  final typeId = 5;

  @override
  LoanStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LoanStatus.active;
      case 1:
        return LoanStatus.completed;
      case 2:
        return LoanStatus.defaulted;
      case 3:
        return LoanStatus.pending;
      default:
        return LoanStatus.active;
    }
  }

  @override
  void write(BinaryWriter writer, LoanStatus obj) {
    switch (obj) {
      case LoanStatus.active:
        writer.writeByte(0);
      case LoanStatus.completed:
        writer.writeByte(1);
      case LoanStatus.defaulted:
        writer.writeByte(2);
      case LoanStatus.pending:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoanModel _$LoanModelFromJson(Map<String, dynamic> json) => LoanModel(
  id: json['id'] as String?,
  userId: json['user_id'] as String,
  title: json['title'] as String?,
  principalAmount: (json['principal_amount'] as num).toDouble(),
  remainingAmount: (json['remaining_amount'] as num).toDouble(),
  interestRate: (json['interest_rate'] as num?)?.toDouble() ?? 0.0,
  monthlyPayment: (json['monthly_payment'] as num).toDouble(),
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  nextPaymentDate: DateTime.parse(json['next_payment_date'] as String),
  status:
      $enumDecodeNullable(_$LoanStatusEnumMap, json['status']) ??
      LoanStatus.active,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$LoanModelToJson(LoanModel instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'principal_amount': instance.principalAmount,
  'remaining_amount': instance.remainingAmount,
  'interest_rate': instance.interestRate,
  'monthly_payment': instance.monthlyPayment,
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
  'next_payment_date': instance.nextPaymentDate.toIso8601String(),
  'status': _$LoanStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$LoanStatusEnumMap = {
  LoanStatus.active: 'active',
  LoanStatus.completed: 'completed',
  LoanStatus.defaulted: 'defaulted',
  LoanStatus.pending: 'pending',
};
