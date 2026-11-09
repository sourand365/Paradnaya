import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

void main() {
  runApp(const ParadnayaApp());
}

class ParadnayaApp extends StatelessWidget {
  const ParadnayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF172333);
    return MaterialApp(
      title: 'Парадная',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF176CDB)),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),
      ),
      home: const MapHomePage(),
    );
  }
}

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {
  // Odesa city centre. The map starts here; GPS permission is not required.
  static const LatLng _odesa = LatLng(46.4825, 30.7233);
  static const String _styleUrl = 'https://tiles.openfreemap.org/styles/liberty';

  MapLibreMapController? _mapController;
  bool _mapReady = false;
  String? _mapError;

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  void _onStyleLoaded() {
    if (!mounted) return;
    setState(() {
      _mapReady = true;
      _mapError = null;
    });
  }

  void _onMapError(Object error) {
    if (!mounted) return;
    setState(() => _mapError = error.toString());
  }

  Future<void> _goToOdesa() async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _odesa, zoom: 15.5, tilt: 55, bearing: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Парадная', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: 'Одесса',
            onPressed: _goToOdesa,
            icon: const Icon(Icons.location_city),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _styleUrl,
            initialCameraPosition: const CameraPosition(
              target: _odesa,
              zoom: 14.2,
              tilt: 55,
              bearing: -12,
            ),
            minMaxZoomPreference: const MinMaxZoomPreference(3, 19),
            compassEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            myLocationEnabled: false,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoaded,
            onMapError: _onMapError,
          ),
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(14),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Поиск адреса или квартиры',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Поиск адресов добавим на следующем этапе.')),
                  );
                },
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'city',
              onPressed: _goToOdesa,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF172333),
              child: const Icon(Icons.location_city),
            ),
          ),
          if (!_mapReady && _mapError == null)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Загружаем 3D-карту…'),
                    ],
                  ),
                ),
              ),
            ),
          if (_mapError != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Не удалось загрузить карту. Проверьте интернет и попробуйте снова.\n$_mapError',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
          if (_mapReady)
            Positioned(
              left: 14,
              bottom: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Text('Одесса · 3D-карта', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
