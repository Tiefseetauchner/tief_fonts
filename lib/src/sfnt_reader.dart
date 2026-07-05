import 'dart:typed_data';

import 'byte_reader.dart';

const _validSfntVersions = [0x00010000, 0x4F54544F]; // 0x00010000, 'OTTO'

abstract final class _SfntHeader {
  static const version = 0;
  static const numTables = 4;
  static const tableDirectoryStart = 12;
}

abstract final class _TableDirectoryRecord {
  static const size = 16;
  static const tag = 0;
  static const offset = 8;
  static const length = 12;
}

class TableRecord {
  const TableRecord({required this.offset, required this.length});

  final int offset;
  final int length;
}

class SfntReader {
  factory SfntReader(Uint8List bytes) {
    final reader = ByteReader(bytes);
    final version = reader.u32(_SfntHeader.version);
    if (!_validSfntVersions.contains(version)) {
      throw FormatException(
        'Unsupported sfnt version: 0x${version.toRadixString(16)}',
      );
    }

    final numTables = reader.u16(_SfntHeader.numTables);
    final tables = <String, TableRecord>{};
    for (var i = 0; i < numTables; i++) {
      final recordOffset =
          _SfntHeader.tableDirectoryStart + i * _TableDirectoryRecord.size;
      final tag = reader.tag(recordOffset + _TableDirectoryRecord.tag);
      final offset = reader.u32(recordOffset + _TableDirectoryRecord.offset);
      final length = reader.u32(recordOffset + _TableDirectoryRecord.length);
      tables[tag] = TableRecord(offset: offset, length: length);
    }

    return SfntReader._(reader, tables);
  }

  SfntReader._(this.reader, this._tables);

  final ByteReader reader;
  final Map<String, TableRecord> _tables;

  TableRecord? lookup(String tag) => _tables[tag];
}
