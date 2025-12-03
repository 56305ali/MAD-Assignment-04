import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // Access global cameras list
import '../models/activity.dart';
import '../providers/activity_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _loading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _loading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _loading = false);
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
      _loading = false;
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
  }

  Future<void> _captureImage() async {
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera found')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(camera: cameras.first),
      ),
    );

    if (result != null && result is String && _currentPosition != null) {
      final activity = Activity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        imagePath: result,
      );

      if (!mounted) return;
      await Provider.of<ActivityProvider>(context, listen: false).addActivity(activity);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity logged successfully!')),
      );
    } else if (_currentPosition == null) {
       if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartTracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Capture Activity',
            onPressed: _captureImage,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _currentPosition == null
                    ? const Center(child: Text('Location not available'))
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _currentPosition!,
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => _mapController = controller,
                        markers: _markers,
                        myLocationEnabled: true,
                      ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _captureImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Activity'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a Picture')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            if (!mounted) return;
            Navigator.pop(context, image.path);
          } catch (e) {
            debugPrint(e.toString());
          }
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
