import 'dart:typed_data';

import 'fvar_table.dart';
import 'feature_list_table.dart';
import 'name_table.dart';
import 'os2_table.dart';
import 'sfnt_reader.dart';

const _fallback = FontInfo(
  familyName: null,
  weight: 400,
  isItalic: false,
  variationAxes: null,
  features: [],
);

/// The result of [extractFontInfo], containing family name, weight, italic and variable-axis metadata.
class FontInfo {
  const FontInfo({
    required this.familyName,
    required this.weight,
    required this.isItalic,
    required this.variationAxes,
    required this.features,
  });

  /// The font's family name, or null if it couldn't be read.
  final String? familyName;

  /// The font's weight, or 400 if it couldn't be read.
  final int weight;

  /// Whether the font is italic, or false if it couldn't be read.
  final bool isItalic;

  /// The variable axis metadata, or null if the font is not a variable font or the metadata couldn't be read.
  final List<VariationAxis>? variationAxes;

  /// OpenType feature tags (e.g. 'liga', 'smcp', 'onum') advertised by the font's GSUB/GPOS tables. Empty if none were found or readable.
  final List<String> features;
}

/// Extracts family name, weight, italic and variable-axis metadata from an sfnt (TTF/OTF) font file's raw bytes.
FontInfo extractFontInfo(Uint8List bytes) {
  try {
    final sfnt = SfntReader(bytes);

    int weight = 400;
    bool isItalic = false;
    final os2Table = sfnt.lookup('OS/2');
    if (os2Table != null) {
      final os2 = readOs2Table(sfnt.reader, os2Table);
      weight = os2.weightClass;
      isItalic = os2.isItalic;
    }

    List<VariationAxis>? axes;
    final fvarTable = sfnt.lookup('fvar');
    if (fvarTable != null) {
      axes = readFvarAxes(sfnt.reader, fvarTable);
    }

    String? familyName;
    final nameTable = sfnt.lookup('name');
    if (nameTable != null) {
      familyName = readFamilyName(sfnt.reader, nameTable);
    }

    final features = <String>{};
    for (final tag in ['GSUB', 'GPOS']) {
      final table = sfnt.lookup(tag);
      if (table != null) {
        features.addAll(readFeatureTags(sfnt.reader, table));
      }
    }

    return FontInfo(
      familyName: familyName,
      weight: weight,
      isItalic: isItalic,
      variationAxes: axes,
      features: features.toList()..sort(),
    );
  } catch (_) {
    return _fallback;
  }
}
