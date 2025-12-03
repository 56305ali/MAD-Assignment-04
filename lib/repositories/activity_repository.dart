import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';

class ActivityRepository {
  // Updated for physical device - use computer's IP address
  // For emulator, use: 'http://10.0.2.2:3000/activities'
  // For physical device on same WiFi: use computer's local IP
  final String apiUrl = 'http://192.168.100.30:3000/activities';
  
  Future<List<Activity>> getActivities() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Activity.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      // Fallback to local storage if API fails
      return await getLocalActivities();
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(activity.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add activity');
      }
      // Also save locally
      await saveActivityLocally(activity);
    } catch (e) {
      // If API fails, just save locally (offline mode)
      await saveActivityLocally(activity);
    }
  }

  Future<void> deleteActivity(String id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete activity');
    }
    // Remove from local storage as well
    // Note: This implementation assumes we want to sync deletion.
    // For simplicity, we might not fully sync deletion offline in this basic version.
  }

  Future<void> saveActivityLocally(Activity activity) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activities = prefs.getStringList('activities') ?? [];
    activities.add(json.encode(activity.toJson()));
    
    // Keep only last 5
    if (activities.length > 5) {
      activities = activities.sublist(activities.length - 5);
    }
    
    await prefs.setStringList('activities', activities);
  }

  Future<List<Activity>> getLocalActivities() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activities = prefs.getStringList('activities') ?? [];
    return activities.map((str) => Activity.fromJson(json.decode(str))).toList();
  }
}
