import 'dart:typed_data';

class ByteReader {
  ByteReader(Uint8List bytes)
    : _data = ByteData.sublistView(bytes),
      length = bytes.length;

  final ByteData _data;
  final int length;

  int u8(int offset) => _data.getUint8(offset);
  int u16(int offset) => _data.getUint16(offset, Endian.big);
  int u32(int offset) => _data.getUint32(offset, Endian.big);
  int i32(int offset) => _data.getInt32(offset, Endian.big);

  double fixed(int offset) => i32(offset) / 65536.0;

  String tag(int offset) => String.fromCharCodes([
    u8(offset),
    u8(offset + 1),
    u8(offset + 2),
    u8(offset + 3),
  ]);
}
