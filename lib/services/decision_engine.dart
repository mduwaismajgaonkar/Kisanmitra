enum Recommendation { irrigate, delay, notNeeded }

// Moisture (%) below which the soil counts as dry, per crop.
// These are PROTOTYPE values, not agronomic advice.
const Map<String, double> lowMoistureByCrop = {
  'Wheat': 25,
  'Rice': 40,
  'Maize': 30,
  'Jowar': 20,
  'Sugarcane': 35,
  'Cotton': 25,
  'Groundnut': 25,
  'Tomato': 35,
};

const double defaultLowMoistureLimit = 25;
const double highRainLimit = 70;

double moistureLimitFor(String crop) =>
    lowMoistureByCrop[crop] ?? defaultLowMoistureLimit;

Recommendation decide(
  double soilMoisture,
  double rainProbability,
  String crop,
) {
  final limit = moistureLimitFor(crop);

  if (soilMoisture > limit) {
    return Recommendation.notNeeded;
  }
  if (rainProbability > highRainLimit) {
    return Recommendation.delay;
  }
  return Recommendation.irrigate;
}