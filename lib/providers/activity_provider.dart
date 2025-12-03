import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../repositories/activity_repository.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityRepository _repository = ActivityRepository();
  List<Activity> _activities = [];
  bool _isLoading = false;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  Future<void> fetchActivities() async {
    _isLoading = true;
    notifyListeners();
    try {
      _activities = await _repository.getActivities();
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      // On error, try to load local activities
      _activities = await _repository.getLocalActivities();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addActivity(Activity activity) async {
    try {
      await _repository.addActivity(activity);
      _activities.add(activity);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding activity: $e');
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _repository.deleteActivity(id);
      _activities.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting activity: $e');
    }
  }

  Future<void> searchActivities(String query) async {
    if (query.isEmpty) {
      await fetchActivities();
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    try {
      // Search in local activities by timestamp or coordinates
      _activities = _activities.where((activity) {
        final latStr = activity.latitude.toString();
        final lngStr = activity.longitude.toString();
        final timeStr = activity.timestamp.toString();
        return latStr.contains(query) || 
               lngStr.contains(query) || 
               timeStr.contains(query);
      }).toList();
    } catch (e) {
      debugPrint('Error searching activities: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
