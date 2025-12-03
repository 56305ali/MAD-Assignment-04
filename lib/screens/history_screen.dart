import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/activity_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch activities when screen loads
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<ActivityProvider>(context, listen: false).fetchActivities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ActivityProvider>(context, listen: false)
                  .fetchActivities();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by coordinates or time',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<ActivityProvider>(context, listen: false)
                        .fetchActivities();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                Provider.of<ActivityProvider>(context, listen: false)
                    .searchActivities(value);
              },
            ),
          ),
          Expanded(
            child: Consumer<ActivityProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.activities.isEmpty) {
                  return const Center(child: Text('No activities found.'));
                }

                return ListView.builder(
                  itemCount: provider.activities.length,
                  itemBuilder: (context, index) {
                    final activity = provider.activities[index];
                    return Dismissible(
                      key: Key(activity.id),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        provider.deleteActivity(activity.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Activity deleted')),
                        );
                      },
                      child: ListTile(
                        leading: activity.imagePath != null
                            ? SizedBox(
                                width: 50,
                                height: 50,
                                child: Image.file(
                                  File(activity.imagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text('Activity at ${activity.timestamp.toString()}'),
                        subtitle: Text(
                            'Lat: ${activity.latitude.toStringAsFixed(4)}, Lng: ${activity.longitude.toStringAsFixed(4)}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
