import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tief_fonts/tief_fonts.dart';

Uint8List _fixture(String name) =>
    File('test/fixtures/$name').readAsBytesSync();

void _verifyVariationAxis(
  VariationAxis axis,
  String tag,
  double min,
  double max,
  double defaultValue,
) {
  expect(axis.tag, tag);
  expect(axis.min, min);
  expect(axis.max, max);
  expect(axis.defaultValue, defaultValue);
}

void main() {
  group('extractFontInfo', () {
    test('reads a static font (Roboto Regular)', () {
      final info = extractFontInfo(_fixture('Roboto-Regular.ttf'));

      expect(info.familyName, contains('Roboto'));
      expect(info.weight, 400);
      expect(info.isItalic, isFalse);
      expect(info.variationAxes, isNull);
      expect(info.features, containsAll(['liga', 'kern', 'smcp']));
    });

    test('reads a variable font (Exo)', () {
      final info = extractFontInfo(_fixture('Exo-VariableFont_wght.ttf'));

      expect(info.familyName, contains('Exo'));
      expect(info.weight, 100);
      expect(info.isItalic, isFalse);
      expect(info.variationAxes, isNotNull);
      expect(info.variationAxes, isNotEmpty);
      _verifyVariationAxis(info.variationAxes![0], 'wght', 100, 900, 100);
      expect(info.features, containsAll(['liga', 'kern', 'smcp']));
    });

    test('reads a static otf font (OpenDyslexic)', () {
      final info = extractFontInfo(_fixture('OpenDyslexic-Regular.otf'));

      expect(info.familyName, contains('OpenDyslexic'));
      expect(info.weight, 400);
      expect(info.isItalic, isFalse);
      expect(info.variationAxes, isNull);
      expect(info.features, containsAll(['liga', 'kern']));
    });

    test('falls back to defaults for an empty buffer', () {
      final info = extractFontInfo(Uint8List(0));

      expect(info.familyName, isNull);
      expect(info.weight, 400);
      expect(info.isItalic, isFalse);
      expect(info.variationAxes, isNull);
      expect(info.features, isEmpty);
    });

    test('falls back to defaults for a truncated header', () {
      final truncated = _fixture('Roboto-Regular.ttf').sublist(0, 10);
      final info = extractFontInfo(truncated);

      expect(info.familyName, isNull);
      expect(info.weight, 400);
      expect(info.isItalic, isFalse);
      expect(info.variationAxes, isNull);
      expect(info.features, isEmpty);
    });

    test(
      'falls back to defaults when the table directory overruns the buffer',
      () {
        final bytes = Uint8List.fromList(_fixture('Roboto-Regular.ttf'));
        final data = ByteData.sublistView(bytes);
        data.setUint16(4, 0xFFFF);

        final info = extractFontInfo(bytes);

        expect(info.familyName, isNull);
        expect(info.weight, 400);
        expect(info.isItalic, isFalse);
        expect(info.variationAxes, isNull);
        expect(info.features, isEmpty);
      },
    );
  });
}
