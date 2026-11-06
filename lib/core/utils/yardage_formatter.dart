class YardageFormatter {
  static const double yardsToMetersFactor = 0.9144;

  static String formatDistance(int yards, String unitSystem) {
    if (unitSystem == 'meters') {
      final meters = (yards * yardsToMetersFactor).round();
      return '$meters m';
    }
    return '$yards yds';
  }

  static String formatNumber(int yards, String unitSystem) {
    if (unitSystem == 'meters') {
      return (yards * yardsToMetersFactor).round().toString();
    }
    return yards.toString();
  }

  static String unitLabel(String unitSystem) {
    return unitSystem == 'meters' ? 'M' : 'YDS';
  }
}
