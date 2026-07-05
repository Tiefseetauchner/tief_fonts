import 'byte_reader.dart';
import 'sfnt_reader.dart';

abstract final class _FeatureListHeader {
  static const featureListOffset = 6;
}

abstract final class _FeatureList {
  static const featureCount = 0;
  static const recordsStart = 2;
}

abstract final class _FeatureRecord {
  static const size = 6;
  static const featureTag = 0;
}

List<String> readFeatureTags(ByteReader reader, TableRecord table) {
  final base = table.offset;
  final featureListBase =
      base + reader.u16(base + _FeatureListHeader.featureListOffset);

  final featureCount = reader.u16(featureListBase + _FeatureList.featureCount);
  return List.generate(featureCount, (i) {
    final recordOffset =
        featureListBase + _FeatureList.recordsStart + i * _FeatureRecord.size;
    return reader.tag(recordOffset + _FeatureRecord.featureTag);
  });
}
