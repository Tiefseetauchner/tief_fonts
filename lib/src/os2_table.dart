import 'byte_reader.dart';
import 'sfnt_reader.dart';

abstract final class _Os2Table {
  static const usWeightClass = 4;
  static const fsSelection = 62;
  static const minLength = 64;
}

const _fsSelectionItalicBit = 0x0001;

class Os2Info {
  const Os2Info({required this.weightClass, required this.isItalic});

  final int weightClass;
  final bool isItalic;
}

Os2Info readOs2Table(ByteReader reader, TableRecord table) {
  if (table.length < _Os2Table.minLength) {
    throw FormatException('OS/2 table too short: ${table.length} bytes');
  }
  final weightClass = reader.u16(table.offset + _Os2Table.usWeightClass);
  final fsSelection = reader.u16(table.offset + _Os2Table.fsSelection);
  final isItalic = (fsSelection & _fsSelectionItalicBit) != 0;
  return Os2Info(weightClass: weightClass, isItalic: isItalic);
}
