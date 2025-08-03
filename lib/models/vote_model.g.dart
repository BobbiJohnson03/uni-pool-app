// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VoteModelAdapter extends TypeAdapter<VoteModel> {
  @override
  final int typeId = 2;

  @override
  VoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VoteModel.raw(
      sessionId: fields[0] as String,
      userId: fields[1] as String?,
      encryptedAnswers: fields[2] as String,
      timestamp: fields[3] as DateTime,
      deviceId: fields[4] as String,
      voteSignature: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VoteModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sessionId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.encryptedAnswers)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.deviceId)
      ..writeByte(5)
      ..write(obj.voteSignature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
