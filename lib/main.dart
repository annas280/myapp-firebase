import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/monitoring',
        builder: (context, state) => const MonitoringPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    initialLocation: '/login',
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SensorDataProvider()),
      ],
      child: MaterialApp.router(
        title: 'Monitoring Kesegaran Daging Sapi',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.oswaldTextTheme(),
        ),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// ===========================================
//  LOGIN PAGE
// ===========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await Future.delayed(const Duration(seconds: 2));

      if (_usernameController.text == "admin" &&
          _passwordController.text == "1234") {
        context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username atau password salah!")),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thermostat_auto,
                        size: 80, color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    Text(
                      "MONITORING KESEGARAN\nDAGING SAPI",
                      style: GoogleFonts.oswald(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Dengan Sensor DHT22 & AI",
                      style: GoogleFonts.oswald(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: "Username",
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Username wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Password wajib diisi" : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Login",
                                  style: TextStyle(fontSize: 16)),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================
//  HOMEPAGE / DASHBOARD
// ===========================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Monitoring',
            style: GoogleFonts.oswald(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Suhu: ${sensorProvider.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(fontSize: 18)),
            Text('Kelembapan: ${sensorProvider.humidity.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Tingkat Risiko: ${sensorProvider.riskLevel}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: sensorProvider.riskLevel == "TINGGI"
                      ? Colors.red
                      : sensorProvider.riskLevel == "SEDANG"
                          ? Colors.orange
                          : Colors.green,
                )),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 0),
    );
  }
}

// ===========================================
//  MONITORING PAGE
// ===========================================
class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorDataProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring Real-time',
            style: GoogleFonts.oswald(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.thermostat, size: 80, color: Colors.blue),
            Text('Suhu: ${sensorProvider.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(fontSize: 20)),
            Text('Kelembapan: ${sensorProvider.humidity.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Status: ${sensorProvider.riskLevel}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: sensorProvider.riskLevel == "TINGGI"
                      ? Colors.red
                      : sensorProvider.riskLevel == "SEDANG"
                          ? Colors.orange
                          : Colors.green,
                )),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 1),
    );
  }
}

// ===========================================
//  HISTORY PAGE
// ===========================================
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Data',
            style: GoogleFonts.oswald(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman History - Data sensor historis akan ditampilkan di sini'),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 2),
    );
  }
}

// ===========================================
//  SETTINGS PAGE
// ===========================================
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan',
            style: GoogleFonts.oswald(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Halaman Settings - Pengaturan aplikasi di sini'),
      ),
      bottomNavigationBar: _buildBottomNavBar(context, 3),
    );
  }
}

// ===========================================
//  BOTTOM NAVIGATION BAR
// ===========================================
BottomNavigationBar _buildBottomNavBar(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.blue[700],
    unselectedItemColor: Colors.grey[600],
    onTap: (index) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/monitoring');
          break;
        case 2:
          context.go('/history');
          break;
        case 3:
          context.go('/settings');
          break;
      }
    },
    items: const [
      BottomNavigationBarItem(
          icon: Icon(Icons.dashboard), label: 'Dashboard'),
      BottomNavigationBarItem(
          icon: Icon(Icons.monitor_heart), label: 'Monitoring'),
      BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
    ],
  );
}

// ===========================================
//  PROVIDER UNTUK DATA SENSOR
// ===========================================
class SensorDataProvider with ChangeNotifier {
  double _temperature = 27.5;
  double _humidity = 72.0;
  String _riskLevel = "SEDANG";

  double get temperature => _temperature;
  double get humidity => _humidity;
  String get riskLevel => _riskLevel;

  void updateSensorData(double temp, double hum) {
    _temperature = temp;
    _humidity = hum;

    if (temp > 30.0 || hum > 80.0) {
      _riskLevel = "TINGGI";
    } else if (temp > 25.0 || hum > 70.0) {
      _riskLevel = "SEDANG";
    } else {
      _riskLevel = "RENDAH";
    }

    notifyListeners();
  }
}
