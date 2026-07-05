import 'byte_reader.dart';
import 'sfnt_reader.dart';

abstract final class _FvarHeader {
  static const axesArrayOffset = 4;
  static const axisCount = 8;
  static const axisSize = 10;
}

abstract final class _VariationAxisRecord {
  static const axisTag = 0;
  static const minValue = 4;
  static const defaultValue = 8;
  static const maxValue = 12;
}

class VariationAxis {
  const VariationAxis({
    required this.tag,
    required this.min,
    required this.defaultValue,
    required this.max,
  });

  final String tag;
  final int min;
  final int defaultValue;
  final int max;
}

List<VariationAxis> readFvarAxes(ByteReader reader, TableRecord table) {
  final base = table.offset;
  final axesArrayOffset = base + reader.u16(base + _FvarHeader.axesArrayOffset);
  final axisCount = reader.u16(base + _FvarHeader.axisCount);
  final axisSize = reader.u16(base + _FvarHeader.axisSize);

  return List.generate(axisCount, (i) {
    final axisOffset = axesArrayOffset + i * axisSize;
    return VariationAxis(
      tag: reader.tag(axisOffset + _VariationAxisRecord.axisTag),
      min: reader.fixed(axisOffset + _VariationAxisRecord.minValue).round(),
      defaultValue: reader
          .fixed(axisOffset + _VariationAxisRecord.defaultValue)
          .round(),
      max: reader.fixed(axisOffset + _VariationAxisRecord.maxValue).round(),
    );
  });
}
