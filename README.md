# tief_fonts

A tiny, pure-Dart package that pokes around inside `.ttf`/`.otf` files and
tells you what it finds: family name, weight, italic, variable-font axes,
and OpenType feature tags. Just some patience with the 
[OpenType spec](https://learn.microsoft.com/en-us/typography/opentype/spec/).

This exists because [tiefprompt](https://github.com/Tiefseetauchner/tiefprompt) lets people import their own
fonts, and asking a user "what's the weight and style of this file you just
picked?" is a bad time for everyone. So instead we read the sfnt tables
ourselves and figure it out.

## Usage

```dart
import 'dart:io';
import 'package:tief_fonts/tief_fonts.dart';

final bytes = File('SomeFont.ttf').readAsBytesSync();
final info = extractFontInfo(bytes);

print(info.familyName);    // 'Roboto', or null if we couldn't find one
print(info.weight);        // 400, straight off usWeightClass
print(info.isItalic);      // fsSelection bit 0
print(info.variationAxes); // null for static fonts, a List<VariationAxis> for variable ones
print(info.features);      // ['kern', 'liga', 'smcp', ...] from GSUB/GPOS
```

That's the whole public surface: one function, one result type.


On purpose --- if you need lower-level table access, the individual table 
readers live in `lib/src/` and are not exported. They work, but they're not 
a supported API, so don't get attached.

## What this is not

- Not a font renderer, not a shaper, not a subsetter. It reads metadata,
  full stop.
- Not a `.ttc` (font collection) parser. If you hand it one, you get the
  fallback, not a crash — but you won't get real data either.
- Not going to guess at MacRoman codepages properly. The Mac-platform name
  fallback treats bytes as Latin-1-ish. It's rare enough in the wild that
  doing it "correctly" wasn't worth the code.
