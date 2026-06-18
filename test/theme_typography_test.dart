import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mind_gym/utils/theme.dart';

void main() {
  test('theme exposes deliberate UI and reading typography roles', () {
    final uiStyle = AppTheme.sectionLabelStyle;
    final readingStyle = AppTheme.challengePromptTextStyle;
    final messageStyle = AppTheme.messageTextStyle;

    expect(uiStyle.fontFamily, contains('Inter'));
    expect(uiStyle.letterSpacing, 1.1);
    expect(uiStyle.fontWeight, FontWeight.w800);

    expect(readingStyle.fontFamily, contains('Lora'));
    expect(readingStyle.fontSize, 16);
    expect(readingStyle.height, greaterThanOrEqualTo(1.65));
    expect(readingStyle.color, AppTheme.textPrimary);

    expect(messageStyle.fontFamily, contains('Lora'));
    expect(messageStyle.height, greaterThanOrEqualTo(1.55));
  });
}
