class SensorData {
  final String crop;
  final String location;
  final double soilMoisture; // percent
  final double temperature; // degrees Celsius
  final double humidity; // percent
  final double rainProbability; // percent

  const SensorData({
    required this.crop,
    required this.location,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.rainProbability,
  });
}