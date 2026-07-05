import 'byte_reader.dart';
import 'sfnt_reader.dart';

const _platformWindows = 3;
const _encodingWindowsUnicodeBmp = 1;
const _platformMac = 1;

const _nameIdFullName = 4;
const _nameIdFamily = 1;

abstract final class _NameHeader {
  static const count = 2;
  static const stringOffset = 4;
  static const recordsStart = 6;
}

abstract final class _NameRecordLayout {
  static const size = 12;
  static const platformId = 0;
  static const encodingId = 2;
  static const nameId = 6;
  static const length = 8;
  static const stringOffset = 10;
}

class _NameRecord {
  const _NameRecord({
    required this.platformId,
    required this.encodingId,
    required this.nameId,
    required this.length,
    required this.stringOffset,
  });

  final int platformId;
  final int encodingId;
  final int nameId;
  final int length;
  final int stringOffset;
}

String? readFamilyName(ByteReader reader, TableRecord table) {
  final base = table.offset;
  final count = reader.u16(base + _NameHeader.count);
  final stringAreaOffset = base + reader.u16(base + _NameHeader.stringOffset);

  final records = <_NameRecord>[];
  for (var i = 0; i < count; i++) {
    final recordOffset =
        base + _NameHeader.recordsStart + i * _NameRecordLayout.size;
    records.add(
      _NameRecord(
        platformId: reader.u16(recordOffset + _NameRecordLayout.platformId),
        encodingId: reader.u16(recordOffset + _NameRecordLayout.encodingId),
        nameId: reader.u16(recordOffset + _NameRecordLayout.nameId),
        length: reader.u16(recordOffset + _NameRecordLayout.length),
        stringOffset: reader.u16(recordOffset + _NameRecordLayout.stringOffset),
      ),
    );
  }

  for (final nameId in [_nameIdFullName, _nameIdFamily]) {
    final candidates = records.where((r) => r.nameId == nameId);

    final windows = candidates.where(
      (r) =>
          r.platformId == _platformWindows &&
          r.encodingId == _encodingWindowsUnicodeBmp,
    );
    if (windows.isNotEmpty) {
      return _decodeUtf16Be(reader, stringAreaOffset, windows.first);
    }

    final mac = candidates.where((r) => r.platformId == _platformMac);
    if (mac.isNotEmpty) {
      return _decodeLatin1(reader, stringAreaOffset, mac.first);
    }
  }
  return null;
}

String _decodeUtf16Be(
  ByteReader reader,
  int stringAreaOffset,
  _NameRecord record,
) {
  final start = stringAreaOffset + record.stringOffset;
  final pairCount = record.length ~/ 2;
  final codeUnits = List<int>.generate(
    pairCount,
    (i) => reader.u16(start + i * 2),
  );
  return String.fromCharCodes(codeUnits);
}

String _decodeLatin1(
  ByteReader reader,
  int stringAreaOffset,
  _NameRecord record,
) {
  final start = stringAreaOffset + record.stringOffset;
  final codeUnits = List<int>.generate(
    record.length,
    (i) => reader.u8(start + i),
  );
  return String.fromCharCodes(codeUnits);
}
