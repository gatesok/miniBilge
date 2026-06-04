import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renders a string that may contain inline LaTeX expressions ($...$).
///
/// When [hasLatex] is false, falls back to a plain [Text] widget.
/// When [hasLatex] is true, splits the string on $...$ delimiters and
/// renders math segments with [Math.tex] and plain text with [Text].
/// Unsupported LaTeX commands are caught and displayed as raw text.
class MathText extends StatelessWidget {
  final String text;
  final bool hasLatex;
  final TextStyle? style;
  final TextAlign textAlign;

  const MathText({
    super.key,
    required this.text,
    this.hasLatex = false,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasLatex) {
      return Text(text, style: style, textAlign: textAlign);
    }

    final segments = _parseSegments(text);

    if (segments.length == 1 && segments.first.isLatex) {
      return Math.tex(
        segments.first.content,
        textStyle: style,
        onErrorFallback: (_) => Text(segments.first.content, style: style),
      );
    }

    return Wrap(
      alignment: textAlign == TextAlign.center
          ? WrapAlignment.center
          : WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: segments.map((seg) {
        if (seg.isLatex) {
          return Math.tex(
            seg.content,
            textStyle: style,
            onErrorFallback: (_) => Text(seg.content, style: style),
          );
        }
        if (seg.content.isEmpty) return const SizedBox.shrink();
        return Text(seg.content, style: style);
      }).toList(),
    );
  }

  List<_Segment> _parseSegments(String input) {
    final segments = <_Segment>[];
    final pattern = RegExp(r'\$([^$]+)\$');
    int lastEnd = 0;

    for (final match in pattern.allMatches(input)) {
      if (match.start > lastEnd) {
        segments.add(_Segment(input.substring(lastEnd, match.start), false));
      }
      segments.add(_Segment(match.group(1)!, true));
      lastEnd = match.end;
    }

    if (lastEnd < input.length) {
      segments.add(_Segment(input.substring(lastEnd), false));
    }

    if (segments.isEmpty) {
      segments.add(_Segment(input, false));
    }

    return segments;
  }
}

class _Segment {
  final String content;
  final bool isLatex;
  const _Segment(this.content, this.isLatex);
}
