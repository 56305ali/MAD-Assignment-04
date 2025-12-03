class Activity {
  final String id;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? imagePath;

  Activity({
    required this.id,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.imagePath,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'imagePath': imagePath,
    };
  }
}
