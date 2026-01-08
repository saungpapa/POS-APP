import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/report_service.dart';

void main() {
  group('ReportService Tests', () {
    late ReportService reportService;

    setUp(() {
      reportService = ReportService.instance;
    });

    test('getDateRange should return correct range for today', () {
      final range = reportService.getDateRange(ReportPeriod.today);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      expect(range.start.year, today.year);
      expect(range.start.month, today.month);
      expect(range.start.day, today.day);
      expect(range.start.hour, 0);
      expect(range.start.minute, 0);
    });

    test('getDateRange should return correct range for this week', () {
      final range = reportService.getDateRange(ReportPeriod.thisWeek);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: now.weekday - 1));

      expect(range.start.year, weekStart.year);
      expect(range.start.month, weekStart.month);
      expect(range.start.day, weekStart.day);
    });

    test('getDateRange should return correct range for this month', () {
      final range = reportService.getDateRange(ReportPeriod.thisMonth);
      final now = DateTime.now();

      expect(range.start.year, now.year);
      expect(range.start.month, now.month);
      expect(range.start.day, 1);
    });

    test('getDateRange should return custom range when provided', () {
      final customStart = DateTime(2024, 1, 1);
      final customEnd = DateTime(2024, 1, 31);

      final range = reportService.getDateRange(
        ReportPeriod.custom,
        customStart: customStart,
        customEnd: customEnd,
      );

      expect(range.start, customStart);
      expect(range.end, customEnd);
    });

    test('getDateRange should throw error for custom period without dates', () {
      expect(
        () => reportService.getDateRange(ReportPeriod.custom),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DateRange Tests', () {
    test('DateRange should store start and end dates', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final range = DateRange(start: start, end: end);

      expect(range.start, start);
      expect(range.end, end);
    });
  });
}
