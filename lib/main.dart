import 'package:flutter/material.dart';
import 'services/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allo Ramia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A74DA),
          primary: const Color(0xFF0A74DA),
          secondary: const Color(0xFF10B981),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0A74DA),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const MyHomePage(title: 'Allo Ramia - Pharmacies de Garde'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _locationMessage = "Cliquez sur le bouton pour activer la géolocalisation";
  bool _isLoading = false;

  Future<void> _handleGeoSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await LocationService.fetchNearbyPharmaciesOnDuty();

      setState(() {
        _isLoading = false;
        _locationMessage = "Position GPS trouvée !\nLat: ${position.latitude.toStringAsFixed(4)}\nLon: ${position.longitude.toStringAsFixed(4)}";
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _locationMessage = "Erreur : $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0A74DA))
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Trouvez les pharmacies de garde ouvertes à proximité',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(10, 116, 218, 0.08),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                _locationMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isLoading ? null : _handleGeoSearch,
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.my_location),
              label: Text(
                _isLoading ? 'Recherche GPS...' : 'Activer la Géolocalisation (GPS)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
