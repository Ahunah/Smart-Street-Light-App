import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (Make sure to replace with your actual Anon Key)
  await Supabase.initialize(
    url: 'https://ixemmcjfzgydfrjieoii.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4ZW1tY2pmemd5ZGZyamllb2lpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIwOTU0MDcsImV4cCI6MjA5NzY3MTQwN30.HlVWnt66J18RCdqCu0w4tYHiTcpPNS3em50KJPSQiOg',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        // Uses the system default clean sans-serif font
        fontFamily: 'sans-serif',
      ),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final supabase = Supabase.instance.client;

  int intensity = 0;
  String status = "Loading";
  String led = "UNKNOWN";
  String update = "Loading";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final data = await supabase
          .from('esp_data')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      setState(() {
        intensity = data['light_intency'] ?? 0;
        status = data['status'] ?? "OFF";
        led = data['led_state'] ?? "UNKNOWN";

        if (data['created_at'] != null) {
          update = DateFormat(
            "yyyy-MM-dd hh:mm:ss a",
          ).format(DateTime.parse(data['created_at']).toLocal());
        }
      });
    } catch (e) {
      setState(() {
        status = "ERROR";
      });
    }
  }

  Color getLedColor() {
    switch (led.toUpperCase()) {
      case "GREEN":
        return Colors.green;
      case "BLUE":
        return Colors.blue;
      case "RED":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getCondition() {
    if (led == "GREEN") return "Bright / Day Time";
    if (led == "BLUE") return "Twilight";
    if (led == "RED") return "Dark Night";
    return "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff071426),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Smart Street Light",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "Real Time IoT Monitoring",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),

                // Intensity Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xff20295c), Color(0xff111827)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            "LIGHT INTENSITY",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.wb_sunny, color: Colors.yellow),
                        ],
                      ),
                      Text(
                        "$intensity%",
                        style: const TextStyle(
                          fontSize: 55,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Slider(
                        value: intensity.clamp(0, 100).toDouble(),
                        max: 100,
                        onChanged: null,
                        activeColor: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Grid Info Cards
                Row(
                  children: [
                    Expanded(
                      child: InfoCard(
                        title: "STATUS",
                        value: status,
                        icon: Icons.lightbulb,
                        color: status == "ON" ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: InfoCard(
                        title: "RGB",
                        value: led,
                        icon: Icons.circle,
                        color: getLedColor(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Condition Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff202b75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.nightlight_round,
                        color: Colors.yellow,
                        size: 30,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CONDITION",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            getCondition(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // Time Card
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blueAccent),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Last Update",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            update,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Refresh Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: loadData,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      "REFRESH DATA",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
