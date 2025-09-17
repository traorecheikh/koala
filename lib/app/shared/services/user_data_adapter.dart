import 'package:hive_ce/hive.dart';

class UserDataAdapter extends TypeAdapter<Map<String, dynamic>> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  Map<String, dynamic> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final Map<String, dynamic> fields = <String, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldKey = reader.readString();
      final fieldValue = reader.read();
      fields[fieldKey] = fieldValue;
    }
    return fields;
  }

  @override
  void write(BinaryWriter writer, Map<String, dynamic> obj) {
    writer.writeByte(obj.length);
    obj.forEach((key, value) {
      writer.writeString(key);
      writer.write(value);
    });
  }
}
