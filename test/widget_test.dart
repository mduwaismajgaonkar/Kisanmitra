import 'package:flutter_test/flutter_test.dart';
import 'package:helloworld/services/decision_engine.dart';

void main() {
  test('dry soil and low rain chance -> irrigate', () {
    expect(decide(20, 30, 'Wheat'), Recommendation.irrigate);
  });

  test('dry soil and high rain chance -> delay', () {
    expect(decide(20, 85, 'Wheat'), Recommendation.delay);
  });

  test('wet soil -> not needed', () {
    expect(decide(60, 10, 'Wheat'), Recommendation.notNeeded);
  });

  test('exactly at the limit counts as dry', () {
    expect(decide(25, 20, 'Wheat'), Recommendation.irrigate);
  });

  test('rice needs more moisture than wheat', () {
    expect(decide(30, 20, 'Wheat'), Recommendation.notNeeded);
    expect(decide(30, 20, 'Rice'), Recommendation.irrigate);
  });

  test('unknown crop uses the default limit', () {
    expect(decide(25, 20, 'Banana'), Recommendation.irrigate);
    expect(decide(26, 20, 'Banana'), Recommendation.notNeeded);
  });
}