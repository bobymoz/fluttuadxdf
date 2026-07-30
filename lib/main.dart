import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:open_filex/open_filex.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_torrent_streamer/flutter_torrent_streamer.dart';

// ==========================================
// CONFIGURAÇÃO GLOBAL (AVISOS GERAIS DA API)
// ==========================================
class GlobalAppConfig {
  static String avisoGeral = "";
}

// ==========================================
// SISTEMA DE DECOY (TROLAGEM PARA SNIFFERS)
// ==========================================
class SecurityDecoyManager {
  static void initiateHoneypot() {
    Future.delayed(const Duration(seconds: 4), () async {
      try { await http.post(Uri.parse("https://api.netflix.com/v1/auth/device_login"), body: {"device_id": "hack_attempt", "status": "banned_ip_u_mad_bro"}); } catch (_) {}
    });
    Future.delayed(const Duration(seconds: 8), () async {
      try { await http.get(Uri.parse("https://api.themoviedb.org/3/movie/550?api_key=FAKE_KEY_NICE_TRY_SNIFFER")); } catch (_) {}
    });
    Future.delayed(const Duration(seconds: 14), () async {
      try { await http.get(Uri.parse("https://crunchyroll.com/api/v1/token?secret=STOP_SNIFFING_MY_APP_HAHAHA")); } catch (_) {}
    });
  }
}

// ==========================================
// DADOS OFUSCADOS (ANTI-MT MANAGER / LUCKYPATCHER)
// ==========================================
String get _apiBaseUrl => String.fromCharCodes([104, 116, 116, 112, 115, 58, 47, 47, 97, 112, 105, 46, 115, 109, 97, 114, 116, 112, 108, 97, 121, 111, 102, 105, 99, 105, 97, 108, 46, 100, 101, 118, 47, 97, 112, 105]);
String get _smartPlayUrl => String.fromCharCodes([104, 116, 116, 112, 115, 58, 47, 47, 115, 109, 97, 114, 116, 112, 108, 97, 121, 108, 105, 116, 101, 46, 120, 110, 45, 45, 110, 56, 106, 97, 53, 49, 57, 48, 102, 46, 109, 98, 97]);
String get _adsterraLink => String.fromCharCodes([104, 116, 116, 112, 115, 58, 47, 47, 97, 99, 115, 99, 100, 110, 46, 99, 111, 109, 47, 115, 99, 114, 105, 112, 116, 47, 97, 99, 108, 105, 98, 46, 106, 115]);

String get _xAppData {
  const String rawToken = "e@PkOFd4c497w3sSB#sX6zGd0LB99wClG4Oeg!APbFuXntwCta1ZpssySVM42uOEtfyjxtbt2KRXfphRLyz83N@Uwb8ifQFP09RvmOmZA5r4O#sRE/zhKZ/jgGZLuzQR+SIKHL7CetT0FQjH//aywJngtiRa4HBvu9vXFRx9OX4U5+FjqXqqQUDa3mW+N1ZENSi1WXNSSM+Yy7omuI4EZ5xDAz+LHLbjBOSYZjNAnyer5fxKGkkySMOWW5gGNRDyesFJJP8nurYCqd5wKUVqCcnQfMD1dp6wTGaKMNSlv95GlpkPSLYoB2G5pC+IE+et3EZ7CUG/x9eFOG+PkepRpp01FjPtmQ64Q1+e68GU8rtS4gwhTk2ssbzq1IiwxesBTPqeSvyu//s6C0otNGSYIkqGIXadiomNNACPhjFFVOOhvDEkvShlZnfG+whDv8gK2L4jxHbAcJrMAWo3WYMn640+55++8dBb76oMDQQmZaX/hYmdDI/FLKLH0O3nmKKD9GRqkVIhtM5JsdKhewTwU3i/lThJiP7XmmKZadZmSYFDIcmtc9nof/NBjdDlOUl7ILxFVNXBNoZFMZgJ4up3ttGp+ktS0IjB+KpfTrDt6dV5BkEPoQ3lTaGH7HzKwA+4jU9zNNC0xOUmp+n8T93dJ8LyKfcxdCxS5MSOUhD+j/R0BSqGyIab7l7MqCrDUnzqY2CsSum7VK7C2vWnpS7nkhrULjfUGyAN0Sl6Ztztk5x7Lhs16UARlZnO1ZItD5aNd9KU6iuxIroffWLmbHccGPW2CQ1yYe/f5r+9M5LcKHpd2e/pZ5+QzGD7NcXI9QoIhDjoFV2LFopZFEWHEBUaE7MPF8MymF3sdLg3uR+x7chq5JvdLtE8SDAU6hB8fgqG/LQmgZBFcjBFIWWHYH69t/DA9i2/blQQEPovjPJ2fCEbQKwtvlTyC5IiZVir7Yw8FUQJ/5U/O8VvDoA7ioKoxaAbDLSvcH4JkFoUYAk0Uajvq3L0TeQfAirXVIK2sFYhXdm4zbiqHPNa5o7K+O8beyAIIEX6QcEFo7eyK2EolLOp8neonv2bRpUHHU/GrwhTSmqjSh0x1HWA/fQoJh2qcfTg1xY5e3UKOQVsJDoF1pxQz2EP8rKwODDEP3qvDGLTRLw3G7eTCqVKE4AwqYK5hvOMc0sHUaXX9BLFecM02q3OWAFEUIZpplWhRUQZG/QmA2GF6+TV3kXfoNPngcuGZ62Hovhtby04l1TvwepP852Lp52Q=";
  return rawToken.replaceAll('@', '').replaceAll('#', '').replaceAll('!', '');
}

const String telegramUrl = "https://t.me/cdcine";
const MethodChannel _pipChannel = MethodChannel('cdcine/pip');
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Inicialização do Supabase fornecida
  await Supabase.initialize(
    url: 'https://llkmxsqxadkuxomvubyj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxsa214c3F4YWRrdXhvbXZ1YnlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU0MTU3NDYsImV4cCI6MjEwMDk5MTc0Nn0.ceUMxNF0YhcoYinzK1zwlRd6eeQd0kciQWDoD8PXlKM',
    headers: {
      'x-app-token': 'chupa', 
    },
  );

  SecurityDecoyManager.initiateHoneypot();

  runApp(const CDcineApp());
}

// ==========================================
// SERVIÇO DE DADOS MASCARADO (CoreMediaVault)
// ==========================================
class CoreMediaVault {
  static Map<String, String> get _headers => {
    "content-type": "application/json",
    "x-app-data": _xAppData,
    "x-app-version": "1.16",
    "user-agent": "okhttp/4.12.0",
  };

  static Future<Map<String, dynamic>> getHome() async {
    try {
      final res = await http.get(Uri.parse("$_apiBaseUrl/home"), headers: _headers);
      return json.decode(res.body);
    } catch (e) { return {}; }
  }

  static Future<List> getGenres() async {
    try {
      final res = await http.get(Uri.parse("$_apiBaseUrl/genres"), headers: _headers);
      final data = json.decode(res.body);
      return data['content'] ?? data['genres'] ?? data ?? [];
    } catch (e) { return []; }
  }

  static Future<List> getGenreItems(String genreId, int page) async {
    try {
      final res = await http.get(Uri.parse("$_apiBaseUrl/genre/$genreId?type=&page=$page"), headers: _headers);
      final data = json.decode(res.body);
      return data['content'] ?? data['items'] ?? data['posts'] ?? [];
    } catch (e) { return []; }
  }

  static Future<List> getPosts({String type = '', String query = '', int page = 1}) async {
    try {
      final res = await http.get(Uri.parse("$_apiBaseUrl/posts?type=$type&query=${Uri.encodeComponent(query)}&page=$page"), headers: _headers);
      final data = json.decode(res.body);
      return data['content'] ?? data['items'] ?? data['posts'] ?? [];
    } catch (e) { return []; }
  }

  static Future<Map<String, dynamic>> getDetails(String id, String tipo) async {
    try {
      final res = await http.get(Uri.parse("$_apiBaseUrl/post/$tipo/$id"), headers: _headers);
      final data = json.decode(res.body);
      return data['content'] ?? data['post'] ?? data;
    } catch (e) { return {}; }
  }

  static Future<List> getEpisodes(String seasonId) async {
    try {
      final res = await http.get(Uri.parse("$_apiBaseUrl/season/$seasonId/episodes?page=1"), headers: _headers);
      final data = json.decode(res.body);
      return data['content'] ?? data['episodes'] ?? data ?? [];
    } catch (e) { return []; }
  }

  static Future<List> getPlayers(String id, String tipo) async {
    try {
      final url = tipo == 'filmes' ? "$_apiBaseUrl/player/movie" : "$_apiBaseUrl/player/episode";
      final payload = tipo == 'filmes' ? {"movie_id": id, "action_type": "PLAY"} : {"ep_id": id, "action_type": "PLAY"};
      final res = await http.post(Uri.parse(url), headers: _headers, body: json.encode(payload));
      final data = json.decode(res.body);
      if (data['success'] == true) {
        return data['content'] ?? data['players'] ?? data['data'] ?? [];
      }
      return [];
    } catch (e) { return []; }
  }
}

// ══════════════════════════════════════════════════════════════════════════
// HUNTER API — Nova fonte de conteúdo via redeflixapi.store
// Responsável pela lista de servidores e extração do MP4 real.
// A API atual (CoreMediaVault) continua responsável por capas e metadados.
// ══════════════════════════════════════════════════════════════════════════
class HunterApi {
  static const Map<String, String> _spoof = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Referer":    "https://redeflixapi.store/",
    "Origin":     "https://redeflixapi.store",
  };

  static Future<List<Map<String, String>>> getServers({
    required String tmdbId,
    required bool isFilme,
    String season  = '',
    String episode = '',
  }) async {
    try {
      String url = isFilme
          ? "https://redeflixapi.store/filme/$tmdbId"
          : "https://redeflixapi.store/serie/$tmdbId/$season/$episode";

      final res = await http.get(Uri.parse(url), headers: _spoof)
          .timeout(const Duration(seconds: 15));
      final html = res.body;
      final servers = <Map<String, String>>[];

      final defMatch = RegExp(r'const\s+defaultUrl\s*=\s*["\x27](http[^"\x27]+)["\x27]').firstMatch(html);
      final legMatch = RegExp(r'const\s+legendadoUrl\s*=\s*["\x27](http[^"\x27]+)["\x27]').firstMatch(html);

      if (defMatch != null && defMatch.group(1)!.trim().isNotEmpty) {
        servers.add({'name': 'RedeFlix', 'audio': 'Dublado', 'url': defMatch.group(1)!.replaceAll('&amp;', '&')});
      }
      if (legMatch != null && legMatch.group(1)!.trim().isNotEmpty) {
        servers.add({'name': 'RedeFlix', 'audio': 'Legendado', 'url': legMatch.group(1)!.replaceAll('&amp;', '&')});
      }
      return servers;
    } catch (_) { return []; }
  }
}

String cleanTitle(String input) {
  try { return Uri.decodeFull(input).replaceAll('&amp;', '&').replaceAll('&#039;', "'").replaceAll('&quot;', '"').trim(); } catch (e) { return input; }
}

Widget _buildCategoryHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(height: 1, width: 40, color: Colors.grey[800]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(title.toUpperCase(), style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.white, letterSpacing: 1)),
        ),
        Container(height: 1, width: 40, color: Colors.grey[800]),
      ],
    ),
  );
}

// ==========================================
// ANIMAÇÕES SKELETON
// ==========================================
Widget _buildGridSkeleton() {
  return GridView.builder(
    padding: const EdgeInsets.all(10), 
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
    itemCount: 12, 
    itemBuilder: (c, i) => Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6))))
  );
}

Widget _buildHorizontalSkeleton() {
  return SizedBox(
    height: 160,
    child: ListView.builder(
      scrollDirection: Axis.horizontal, 
      padding: const EdgeInsets.symmetric(horizontal: 10), 
      itemCount: 5,
      itemBuilder: (c, i) => Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(width: 105, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6))))
    ),
  );
}

Widget _buildCarouselSkeleton() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!,
    child: Container(height: 250, margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12))),
  );
}

Widget _buildPlayerSkeleton() {
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 24, width: 250, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 16),
              Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 8),
              Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 8),
              Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 12, width: 150, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
              const SizedBox(height: 30),
              Row(children: List.generate(4, (index) => Padding(padding: const EdgeInsets.only(right: 10), child: Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 45, width: 45, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6))))))),
            ],
          ),
        )
      ],
    ),
  );
}

class CDcineApp extends StatefulWidget {
  const CDcineApp({super.key});
  @override State<CDcineApp> createState() => _CDcineAppState();
}
class _CDcineAppState extends State<CDcineApp> with WidgetsBindingObserver {
  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }
  @override void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      AdRemovalManager.instance.invalidate();
    }
  }
  @override Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CDCINE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        primaryColor: const Color(0xFFE50914),
        focusColor: Colors.white24,
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B0B0F), elevation: 0),
        pageTransitionsTheme: PageTransitionsTheme(builders: { TargetPlatform.android: ZoomPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder() }),
      ),
      builder: (context, child) => Stack(children: [child!, const DraggableDownloadOverlay()]),
      home: const _ConnectivityGate(),
    );
  }
}

// ==========================================
// GATES (Conexão e Versão)
// ==========================================
class _ConnectivityGate extends StatefulWidget { const _ConnectivityGate(); @override State<_ConnectivityGate> createState() => _ConnectivityGateState(); }
class _ConnectivityGateState extends State<_ConnectivityGate> {
  bool _checking = true; bool _noInternet = false;
  @override void initState() { super.initState(); _check(); }
  Future<void> _check() async {
    setState(() { _checking = true; _noInternet = false; });
    try {
      final res = await http.get(Uri.parse("https://www.google.com")).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) { if (mounted) setState(() => _checking = false); return; }
    } catch (_) {}
    if (mounted) setState(() { _checking = false; _noInternet = true; });
  }
  @override Widget build(BuildContext context) {
    if (_checking) return const Scaffold(backgroundColor: Color(0xFF0B0B0F), body: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))));
    if (_noInternet) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0B0F),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off, color: Colors.white30, size: 80), const SizedBox(height: 24),
              Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 40, letterSpacing: 3)),
              const SizedBox(height: 12), const Text("Sem ligação à internet", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8), const Text("Verifica a tua ligação Wi-Fi ou dados móveis e tenta novamente.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
              const SizedBox(height: 32), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: _check, icon: const Icon(Icons.refresh, color: Colors.white), label: const Text("Tentar novamente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))))
            ]),
          ),
        ),
      );
    }
    return const SplashScreen();
  }
}

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl; late Animation<double> _scale, _fade, _textFade; late Animation<Offset> _textSlide;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.9, curve: Curves.easeIn)));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (_, __, ___) => const VersionGateScreen(), transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child), transitionDuration: const Duration(milliseconds: 500)));
    });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(opacity: _fade, child: ScaleTransition(scale: _scale, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFFE50914).withOpacity(0.4), blurRadius: 40, spreadRadius: 5)]), child: ClipOval(child: Image.asset('assets/icon.png', fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.movie, size: 60, color: Colors.white)))))),
              const SizedBox(height: 24),
              SlideTransition(position: _textSlide, child: FadeTransition(opacity: _textFade, child: Column(children: [Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 52, letterSpacing: 6)), const SizedBox(height: 6), const Text("O melhor streaming gratuito", style: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1)), const SizedBox(height: 40), SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: const Color(0xFFE50914).withOpacity(0.6), strokeWidth: 2))]))),
            ],
          ),
        ),
      ),
    );
  }
}

const String _appVersion = "2.2.1";
const String _versionUrl = "https://pastefy.app/FlTl6ufq/raw";
class VersionGateScreen extends StatefulWidget { const VersionGateScreen({super.key}); @override State<VersionGateScreen> createState() => _VersionGateScreenState(); }
class _VersionGateScreenState extends State<VersionGateScreen> {
  bool _needsUpdate = false; bool _blocked = false; String _latestVersion = "", _downloadUrl = "", _changelog = "";
  @override void initState() { super.initState(); _checkVersion(); }
  Future<void> _checkVersion() async {
    try {
      final res = await http.get(Uri.parse(_versionUrl), headers: {"User-Agent": "Mozilla/5.0"}).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        String body = res.body; final start = body.indexOf('{'); final end = body.lastIndexOf('}');
        if (start != -1 && end != -1) {
          final data = json.decode(body.substring(start, end + 1));
          _latestVersion = (data['latest_version'] ?? _appVersion).toString().trim();
          _downloadUrl = data['download_url'] ?? ""; _changelog = data['changelog'] ?? "";
          
          GlobalAppConfig.avisoGeral = (data['mesage'] ?? data['message'] ?? "").toString().trim();

          if (_latestVersion != _appVersion.trim() && mounted) setState(() => _needsUpdate = true);
          return;
        }
      }
      if (mounted) setState(() => _blocked = true);
    } catch (_) { if (mounted) setState(() => _blocked = true); }
  }
  @override Widget build(BuildContext context) {
    if (_blocked) return Scaffold(backgroundColor: const Color(0xFF0B0B0F), body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.lock_outline, color: Color(0xFFE50914), size: 64), const SizedBox(height: 24), Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 40, letterSpacing: 3)), const SizedBox(height: 12), const Text("App temporariamente indisponível.\nTente novamente mais tarde.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)), const SizedBox(height: 32), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: _checkVersion, icon: const Icon(Icons.refresh, color: Colors.white), label: const Text("Tentar novamente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))])))));
    if (_needsUpdate) return Scaffold(backgroundColor: const Color(0xFF0B0B0F), body: SafeArea(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.system_update, color: Color(0xFFE50914), size: 72), const SizedBox(height: 24), Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 42, letterSpacing: 3)), const SizedBox(height: 8), Text("Atualização Disponível", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 26, letterSpacing: 1)), const SizedBox(height: 6), Text("v$_appVersion  →  v$_latestVersion", style: const TextStyle(color: Colors.grey, fontSize: 14)), const SizedBox(height: 24), if (_changelog.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("O que há de novo:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 8), Text(_changelog, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5))])), const SizedBox(height: 32), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => launchUrl(Uri.parse(_downloadUrl), mode: LaunchMode.externalApplication), icon: const Icon(Icons.download, color: Colors.white), label: const Text("Baixar Atualização", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))), const SizedBox(height: 12), const Text("Esta versão não é mais suportada.\nAtualize para continuar usando o CDCINE.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5))]))));
    return const MainScreen();
  }
}

// ==========================================
// DOWNLOADS — via 1DM (intent externo)
// ==========================================
class DownloadManager {
  static ValueNotifier<double> progress = ValueNotifier(-1.0);
  static ValueNotifier<int> activeDownloadsCount = ValueNotifier(0);
  static ValueNotifier<bool> showFloatingOverlay = ValueNotifier(false);
  static String currentTitle = "";
  static CancelToken? cancelToken;

  static Future<void> startDownload(String url, String title, bool isMp4) async {
    final cleanedTitle = cleanTitle(title);
    currentTitle = cleanedTitle;

    final prefs = await SharedPreferences.getInstance();
    List<String> hist = prefs.getStringList('downloads_1dm') ?? [];
    final entry = json.encode({'url': url, 'title': cleanedTitle, 'ts': DateTime.now().toIso8601String()});
    if (!hist.any((e) { try { return json.decode(e)['url'] == url; } catch(_) { return false; } })) {
      hist.insert(0, entry);
      if (hist.length > 100) hist = hist.sublist(0, 100);
      await prefs.setStringList('downloads_1dm', hist);
    }

    const idmChannel = MethodChannel('cdcine/idm');
    bool abriu = false;
    try {
      final result = await idmChannel.invokeMethod<bool>('openWith1DM', {
        'url': url,
        'filename': cleanedTitle,
      });
      abriu = result == true;
    } catch (_) {}

    if (!abriu) {
      final ctx = navigatorKey.currentContext;
      if (ctx != null) _mostrarDialogo1DMNaoEncontrado(ctx);
    }
  }

  static void _mostrarDialogo1DMNaoEncontrado(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/1dm.png', width: 72, height: 72,
                    errorBuilder: (_, __, ___) => const Icon(Icons.download, color: Colors.white, size: 60)),
              ),
              const SizedBox(height: 16),
              const Text("1DM não encontrado", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                "Para baixar este conteúdo, instala o app 1DM (IDM Download Manager).\nÉ gratuito e o único capaz de baixar este tipo de vídeo.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01875F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    launchUrl(
                      Uri.parse('https://play.google.com/store/apps/details?id=idm.internet.download.manager'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  icon: const Icon(Icons.download, color: Colors.white),
                  label: const Text("Baixar 1DM na Play Store", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Fechar", style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void hideOverlay() { showFloatingOverlay.value = false; }
  static void confirmCancelDownload(BuildContext context) {}
}

class DraggableDownloadOverlay extends StatefulWidget { const DraggableDownloadOverlay({super.key}); @override State<DraggableDownloadOverlay> createState() => _DraggableDownloadOverlayState(); }
class _DraggableDownloadOverlayState extends State<DraggableDownloadOverlay> {
  double bottomOffset = 80; double leftOffset = 20;
  @override Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DownloadManager.showFloatingOverlay,
      builder: (context, show, child) {
        if (!show) return const SizedBox.shrink();
        return ValueListenableBuilder<double>(
          valueListenable: DownloadManager.progress,
          builder: (context, val, _) {
            if (val == -1.0) return const SizedBox.shrink();
            return Positioned(
              bottom: bottomOffset, left: leftOffset,
              child: GestureDetector(
                onPanUpdate: (details) => setState(() { bottomOffset -= details.delta.dy; leftOffset += details.delta.dx; }),
                onTap: () { if (navigatorKey.currentState != null) navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const DownloadsScreen())); },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: val == -2.0 ? Colors.green[800] : val == -3.0 ? Colors.red[800] : Colors.grey[900], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]),
                    child: Row(children: [
                      val == -2.0 ? const Icon(Icons.check_circle, color: Colors.white) : val == -3.0 ? const Icon(Icons.error, color: Colors.white) : SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: val, color: const Color(0xFFE50914), strokeWidth: 3)),
                      const SizedBox(width: 15), Expanded(child: Text(val == -2.0 ? "Transferência Concluída" : val == -3.0 ? "Erro na Transferência" : "A transferir: ${(val * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                      IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () { if (val >= 0.0 && val <= 1.0) { DownloadManager.hideOverlay(); } else { DownloadManager.progress.value = -1.0; DownloadManager.showFloatingOverlay.value = false; }})
                    ]),
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}

// ==========================================
// ADICIONAR SERVIDOR (SISTEMA COMUNITÁRIO)
// Usando apenas a tabela 'links_salvos' do Supabase
// ==========================================
class SearchMediaForServerScreen extends StatefulWidget { const SearchMediaForServerScreen({super.key}); @override State<SearchMediaForServerScreen> createState() => _SearchMediaForServerScreenState(); }
class _SearchMediaForServerScreenState extends State<SearchMediaForServerScreen> {
  String searchQuery = "";
  final TextEditingController _searchCtrl = TextEditingController();
  
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Servidor", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchCtrl, style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(hintText: "Pesquisar filme ou série...", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.grey[900], prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: EdgeInsets.zero),
                onSubmitted: (val) => setState(() => searchQuery = val),
              ),
            ),
          ),
        ),
      ),
      body: searchQuery.isEmpty 
        ? const Center(child: Text("Pesquise um título para adicionar um servidor.", style: TextStyle(color: Colors.white54)))
        : FutureBuilder<List>(
            future: CoreMediaVault.getPosts(query: searchQuery),
            builder: (c, snapshot) {
              if (!snapshot.hasData) return _buildGridSkeleton();
              
              // Filtro de Duplicatas: Garante que cada filme apareça apenas 1 vez
              final uniqueItems = [];
              final seenIds = <String>{};
              for (var item in snapshot.data!) {
                final id = item['id'].toString();
                if (!seenIds.contains(id)) {
                  seenIds.add(id);
                  uniqueItems.add(item);
                }
              }

              if (uniqueItems.isEmpty) return const Center(child: Text("Nenhum resultado encontrado.", style: TextStyle(color: Colors.white)));
              
              return GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: uniqueItems.length,
                itemBuilder: (c, i) {
                  final item = uniqueItems[i];
                  String slugType = item['type']?['slug'] ?? item['tipo'] ?? 'filmes';
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      focusColor: Colors.white24,
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        if (slugType == 'filmes') {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => AddServerFormScreen(item: item, type: 'filmes')));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => SelectSeasonEpisodeScreen(item: item, type: slugType)));
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: CachedNetworkImage(imageUrl: item['poster'] ?? item['imagem'] ?? "", fit: BoxFit.cover, width: double.infinity, placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[800]!, child: Container(color: Colors.black)), errorWidget: (c, u, e) => Container(color: Colors.grey[900], child: const Icon(Icons.error))))),
                          const SizedBox(height: 4), Text(item['name'] ?? item['titulo'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2), Text(slugType.toUpperCase(), style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}

class SelectSeasonEpisodeScreen extends StatefulWidget { final Map item; final String type; const SelectSeasonEpisodeScreen({super.key, required this.item, required this.type}); @override State<SelectSeasonEpisodeScreen> createState() => _SelectSeasonEpisodeScreenState(); }
class _SelectSeasonEpisodeScreenState extends State<SelectSeasonEpisodeScreen> {
  List temporadas = []; List episodios = []; String? tempSelecionada; bool loading = true;
  @override void initState() { super.initState(); _fetchSeasons(); }
  void _fetchSeasons() async {
    final data = await CoreMediaVault.getDetails(widget.item['id'].toString(), widget.type);
    if (mounted) {
      if (data['seasons'] != null && data['seasons'].isNotEmpty) {
        setState(() { temporadas = data['seasons']; tempSelecionada = temporadas[0]['id'].toString(); });
        _fetchEpisodes(tempSelecionada!);
      } else { setState(() => loading = false); }
    }
  }
  void _fetchEpisodes(String sId) async {
    setState(() => loading = true);
    final eps = await CoreMediaVault.getEpisodes(sId);
    if (mounted) {
      setState(() {
        episodios = eps.asMap().entries.map((e) => {"id": e.value['id'].toString(), "full_nome": e.value['name'] ?? e.value['subtitle'] ?? "Episódio ${e.value['number'] ?? e.key + 1}", "num": (e.value['number'] ?? e.key + 1).toString()}).toList();
        loading = false;
      });
    }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecione o Episódio", style: TextStyle(color: Colors.white, fontSize: 16))),
      body: temporadas.isEmpty && !loading 
        ? const Center(child: Text("Nenhuma temporada encontrada.", style: TextStyle(color: Colors.white54)))
        : Column(
            children: [
              if (temporadas.isNotEmpty) Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                  dropdownColor: Colors.grey[900], value: tempSelecionada,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'].toString(), child: Text(t['name'] ?? "Temporada ${t['number']}"))).toList(),
                  onChanged: (val) { if (val != null) { setState(() { tempSelecionada = val; episodios.clear(); }); _fetchEpisodes(val); } },
                ),
              ),
              Expanded(
                child: loading 
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                  : ListView.builder(
                      itemCount: episodios.length,
                      itemBuilder: (c, i) {
                        final ep = episodios[i];
                        final numSeason = temporadas.firstWhere((t) => t['id'].toString() == tempSelecionada)['number'].toString();
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: const Color(0xFFE50914), child: Text(ep['num'], style: const TextStyle(color: Colors.white, fontSize: 12))),
                          title: Text(ep['full_nome'], style: const TextStyle(color: Colors.white, fontSize: 14)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddServerFormScreen(item: widget.item, type: widget.type, season: numSeason, episode: ep['num']))),
                        );
                      }
                    ),
              )
            ],
          ),
    );
  }
}

class AddServerFormScreen extends StatefulWidget { 
  final Map item; final String type; final String? season; final String? episode;
  const AddServerFormScreen({super.key, required this.item, required this.type, this.season, this.episode});
  @override State<AddServerFormScreen> createState() => _AddServerFormScreenState(); 
}
class _AddServerFormScreenState extends State<AddServerFormScreen> {
  final _urlCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  bool _saving = false;

  void _salvarServidor() async {
    if (_urlCtrl.text.isEmpty || _nomeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha todos os campos."))); return;
    }
    setState(() => _saving = true);
    try {
      final tmdbId = (widget.item['tmdb_id'] ?? widget.item['id']).toString();
      String prefix = widget.type != 'filmes' ? 'T${widget.season} E${widget.episode} - ' : '';
      
      // O ID do TMDB vai na coluna "comentario" para conseguirmos buscar depois!
      await Supabase.instance.client.from('links_salvos').insert({
        'nome': '$prefix${_nomeCtrl.text.trim()}',
        'url': _urlCtrl.text.trim(),
        'comentario': tmdbId, 
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Servidor salvo com sucesso!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
        Navigator.pop(context);
        if (widget.type != 'filmes') Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao salvar: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override Widget build(BuildContext context) {
    String subInfo = widget.type != 'filmes' ? "Temporada ${widget.season} - Ep ${widget.episode}" : "Filme";
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Link", style: TextStyle(color: Colors.white, fontSize: 16))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: widget.item['poster'] ?? widget.item['imagem'] ?? '', width: 60, height: 90, fit: BoxFit.cover, errorWidget: (_,__,___)=>Container(width: 60, height: 90, color: Colors.grey[900]))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.item['name'] ?? widget.item['titulo'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subInfo, style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                ])),
              ],
            ),
            const SizedBox(height: 30),
            const Text("Nome do Servidor (ex: Dublado, Legendado, Mega)", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeCtrl, style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: "Nome do botão", hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 20),
            const Text("URL do Vídeo (Link direto .mp4, .m3u8, iframe ou magnet:)", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _urlCtrl, style: const TextStyle(color: Colors.white), maxLines: 2,
              decoration: InputDecoration(hintText: "https://... ou magnet:?xt=...", hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: _saving ? null : _salvarServidor,
                icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save, color: Colors.white),
                label: Text(_saving ? "Salvando..." : "Salvar Servidor", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Ao salvar, este link ficará disponível para todos os usuários do app. O link precisa ser válido.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}


// ==========================================
// TELA PRINCIPAL E NAVEGAÇÃO
// ==========================================
class MainScreen extends StatefulWidget { const MainScreen({super.key}); @override State<MainScreen> createState() => _MainScreenState(); }
class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; final TextEditingController _searchCtrl = TextEditingController(); bool isSearching = false; String searchQuery = "";
  void _changeTab(int index) { setState(() { _currentIndex = index; isSearching = false; _searchCtrl.clear(); searchQuery = ""; }); }
  @override Widget build(BuildContext context) {
    final List<Widget> views = [
      InicioTab(onNavigate: _changeTab),
      const PaginatedGridView(title: "Filmes", filterType: "filmes"),
      const PaginatedGridView(title: "Séries", filterType: "series"),
      const PaginatedGridView(title: "Animes", filterType: "animes"),
      const TvTab(),
      const GenerosTab(),
    ];
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) { if (didPop) return; if (isSearching) { setState(() { isSearching = false; _searchCtrl.clear(); }); } else if (_currentIndex != 0) { _changeTab(0); } else { SystemNavigator.pop(); } },
      child: Scaffold(
        drawer: Drawer(
          width: 250, backgroundColor: const Color(0xFF121212),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(decoration: BoxDecoration(color: Color(0xFFE50914)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [Text("CDCINE", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)), Text("O melhor conteúdo.", style: TextStyle(color: Colors.white70, fontSize: 12))])),
                    ListTile(leading: const Icon(Icons.send, color: Colors.blueAccent), title: const Text('Nosso Telegram', style: TextStyle(color: Colors.white)), onTap: () => launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication)),
                    ListTile(leading: const Icon(Icons.shield_outlined, color: Colors.grey), title: const Text('DMCA', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DmcaScreen())); }),
                  ],
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leadingWidth: 100,
          leading: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Builder(builder: (c) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(c).openDrawer())), IconButton(icon: const Icon(Icons.history, color: Colors.white), tooltip: "Histórico", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen())))]),
          title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 32, letterSpacing: 2)), centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.add_to_queue, color: Colors.greenAccent), tooltip: "Adicionar Servidor", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchMediaForServerScreen()))),
            ValueListenableBuilder<int>(
              valueListenable: DownloadManager.activeDownloadsCount,
              builder: (context, count, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.download, color: Colors.white), tooltip: "Downloads", onPressed: () { DownloadManager.showFloatingOverlay.value = true; Navigator.push(context, MaterialPageRoute(builder: (c) => const DownloadsScreen())); }),
                    if (count > 0) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))
                  ],
                );
              }
            ),
            const SizedBox(width: 5),
          ],
          bottom: _currentIndex == 4 ? null : PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchCtrl, style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(hintText: "Procurar conteúdo...", hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.grey[900], prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20), suffixIcon: isSearching ? IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: () => setState((){ isSearching=false; _searchCtrl.clear(); })) : null, border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: EdgeInsets.zero),
                  onSubmitted: (val) { setState(() { searchQuery = val; isSearching = val.isNotEmpty; }); },
                ),
              ),
            ),
          ),
        ),
        body: isSearching ? SearchResults(query: searchQuery) : IndexedStack(index: _currentIndex, children: views),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.white, unselectedItemColor: Colors.grey[600], selectedFontSize: 10, unselectedFontSize: 10, currentIndex: _currentIndex, onTap: _changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Início"), 
            BottomNavigationBarItem(icon: Icon(Icons.movie), label: "Filmes"), 
            BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: "Séries"), 
            BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Animes"), 
            BottomNavigationBarItem(icon: Icon(Icons.connected_tv), label: "TV"), 
            BottomNavigationBarItem(icon: Icon(Icons.category), label: "Gêneros")
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ABAS E VISTAS
// ==========================================
class InicioTab extends StatefulWidget { final Function(int) onNavigate; const InicioTab({super.key, required this.onNavigate}); @override State<InicioTab> createState() => _InicioTabState(); }
class _InicioTabState extends State<InicioTab> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;
  List carouselItems = []; bool loadingCarousel = true; int _currentCarouselIndex = 0;
  Map<String, dynamic>? homeData; bool loadingSections = true;

  @override void initState() { super.initState(); _fetchData(); }
  
  void _fetchData() async { 
    final cItems = await CoreMediaVault.getPosts(type: 'filmes', page: 1);
    if (mounted) setState(() { carouselItems = cItems; loadingCarousel = false; });
    
    final data = await CoreMediaVault.getHome(); 
    if (mounted) setState(() { homeData = data; loadingSections = false; }); 
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loadingCarousel) _buildCarouselSkeleton()
          else if (carouselItems.isNotEmpty)
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 220, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.45, 
                    onPageChanged: (index, reason) => setState(() => _currentCarouselIndex = index)
                  ),
                  items: carouselItems.map((item) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        focusColor: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: item))),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(item['poster'] ?? item['imagem'] ?? ''), fit: BoxFit.cover, alignment: Alignment.topCenter)),
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Colors.transparent, Colors.black87], begin: Alignment.center, end: Alignment.bottomCenter)),
                            alignment: Alignment.bottomCenter, padding: const EdgeInsets.all(10),
                            child: Text(item['name'] ?? item['titulo'] ?? '', textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: carouselItems.asMap().entries.map((entry) { 
                    return Container(width: 6.0, height: 6.0, margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(_currentCarouselIndex == entry.key ? 0.9 : 0.3))); 
                  }).toList()
                ),
              ],
            ),

          // Renderização dinâmica do banner caso 'mesage' contenha texto na API.
          if (GlobalAppConfig.avisoGeral.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFE50914).withOpacity(0.8), const Color(0xFF8B0000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.campaign, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      GlobalAppConfig.avisoGeral,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

          if (loadingSections)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: List.generate(4, (index) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 20, width: 100, color: Colors.black))), 
                  _buildHorizontalSkeleton()
                ],
              )),
            )
          else if (homeData != null)
            ...((homeData!['sections'] ?? homeData!['content']?['sections'] ?? []) as List).map((sec) {
              List items = sec['items'] ?? [];
              if (items.isEmpty || (sec['filter'] != null && sec['filter']['mode'] == 'canais')) return const SizedBox.shrink();
              
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), Text(sec['title'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))]),
                        if (sec['filter'] != null) Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () {
                              if (sec['filter']['mode'] == 'id') { Navigator.push(context, MaterialPageRoute(builder: (c) => GridScreen(title: sec['title'], genreId: sec['filter']['id'].toString()))); }
                              else { widget.onNavigate(sec['filter']['mode'] == 'filmes' ? 1 : sec['filter']['mode'] == 'series' ? 2 : 3); }
                            },
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(4)), child: const Text("VER MAIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10), itemCount: items.length,
                      itemBuilder: (c, i) => Container(width: 105, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: items[i])),
                    ),
                  ),
                ],
              );
            }).toList(),
            const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class PaginatedGridView extends StatefulWidget { final String title; final String filterType; const PaginatedGridView({super.key, required this.title, required this.filterType}); @override State<PaginatedGridView> createState() => _PaginatedGridViewState(); }
class _PaginatedGridViewState extends State<PaginatedGridView> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;
  List items = []; bool loading = true; int page = 1;

  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async { setState(() => loading = true); var newItems = await CoreMediaVault.getPosts(type: widget.filterType, page: page); if(mounted) setState(() { items = newItems; loading = false; }); }
  void _changePage(int direction) { if (page + direction > 0) { setState(() { page += direction; items.clear(); }); _fetch(); } }

  @override Widget build(BuildContext context) {
    super.build(context);
    if (loading && items.isEmpty) return _buildGridSkeleton();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildCategoryHeader(widget.title)),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 10), sliver: SliverGrid(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: items[i]), childCount: items.length))),
        SliverToBoxAdapter(child: Container(color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]), onPressed: page > 1 ? () => _changePage(-1) : null, icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14), label: const Text("Anterior", style: TextStyle(color: Colors.white))), Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), onPressed: items.length >= 10 ? () => _changePage(1) : null, icon: const Text("Próxima", style: TextStyle(color: Colors.white)), label: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14))]))),
      ],
    );
  }
}

class GenerosTab extends StatefulWidget { const GenerosTab({super.key}); @override State<GenerosTab> createState() => _GenerosTabState(); }
class _GenerosTabState extends State<GenerosTab> {
  List genres = []; bool loading = true;
  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async { final data = await CoreMediaVault.getGenres(); if (mounted) setState(() { genres = data.where((g) => g['name'] != 'Canais' && g['name'] != 'Novelas').toList(); loading = false; }); }
  @override Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader("Gêneros"),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: genres.length,
            itemBuilder: (context, index) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => GridScreen(title: genres[index]['name'] ?? genres[index]['nome'], genreId: genres[index]['id'].toString()))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(color: Colors.grey[900]),
                        Container(color: Colors.black.withOpacity(0.5)),
                        Center(child: Text(genres[index]['name'] ?? genres[index]['nome'] ?? "", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GridScreen extends StatefulWidget { final String title; final String? genreId; const GridScreen({super.key, required this.title, this.genreId}); @override State<GridScreen> createState() => _GridScreenState(); }
class _GridScreenState extends State<GridScreen> {
  List items = []; bool loading = true; int page = 1;
  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async { setState(() => loading = true); var newItems = widget.genreId != null ? await CoreMediaVault.getGenreItems(widget.genreId!, page) : []; if(mounted) setState(() { items = newItems; loading = false; }); }
  void _changePage(int direction) { if (page + direction > 0) { setState(() { page += direction; items.clear(); }); _fetch(); } }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 28, letterSpacing: 1)), centerTitle: true),
      body: loading && items.isEmpty ? _buildGridSkeleton() : CustomScrollView(slivers: [
        SliverToBoxAdapter(child: _buildCategoryHeader(widget.title)),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 10), sliver: SliverGrid(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: items[i]), childCount: items.length))),
        SliverToBoxAdapter(child: Container(color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]), onPressed: page > 1 ? () => _changePage(-1) : null, icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14), label: const Text("Anterior", style: TextStyle(color: Colors.white))), Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), onPressed: items.length >= 10 ? () => _changePage(1) : null, icon: const Text("Próxima", style: TextStyle(color: Colors.white)), label: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14))]))),
      ]),
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query; const SearchResults({super.key, required this.query});
  @override Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: CoreMediaVault.getPosts(query: query),
      builder: (c, snapshot) {
        if (!snapshot.hasData) return _buildGridSkeleton();
        
        // Filtro de Duplicatas: Garante que cada filme apareça apenas 1 vez na pesquisa
        final uniqueItems = [];
        final seenIds = <String>{};
        for (var item in snapshot.data!) {
          final id = item['id'].toString();
          if (!seenIds.contains(id)) {
            seenIds.add(id);
            uniqueItems.add(item);
          }
        }

        if (uniqueItems.isEmpty) return const Center(child: Text("Nenhum resultado encontrado.", style: TextStyle(color: Colors.white)));
        
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildCategoryHeader("Resultados")),
          SliverPadding(
            padding: const EdgeInsets.all(10), 
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
              delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: uniqueItems[i]), childCount: uniqueItems.length)
            )
          )
        ]);
      },
    );
  }
}

class PosterCard extends StatelessWidget {
  final dynamic item; const PosterCard({super.key, required this.item});
  @override Widget build(BuildContext context) {
    String slugType = item['type']?['slug'] ?? item['tipo'] ?? 'filmes';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        focusColor: Colors.white24,
        borderRadius: BorderRadius.circular(6),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: item))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(6), child: CachedNetworkImage(imageUrl: item['poster'] ?? item['imagem'] ?? "", fit: BoxFit.cover, width: double.infinity, placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[800]!, child: Container(color: Colors.black)), errorWidget: (c, u, e) => Container(color: Colors.grey[900], child: const Icon(Icons.error))))),
            const SizedBox(height: 4), Text(item['name'] ?? item['titulo'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2), Text(slugType.toUpperCase(), style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// TELA DO PLAYER
// ==========================================
class PlayerScreen extends StatefulWidget {
  final Map item; const PlayerScreen({super.key, required this.item});
  @override State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  
  Map? details;
  List temporadas = []; List episodios = [];
  List recomendacoes = [];
  List<Map> _serversDisponiveis = [];
  
  String sinopse = ""; String backdrop = "";
  String? tempSelecionada; String epAtivoNome = "";
  String _urlAtiva = '';
  int _epAtivoIndex = -1; 
  
  bool isDataLoaded = false; bool isPlaying = false; bool isServerLoading = false; bool isSynopsisExpanded = false;
  bool _isFullscreen = false; bool _isBuffering = false;
  
  int savedPositionSeconds = 0; String? savedEpId; String? savedEpNome; bool _autoPlayDisparado = false;
  Timer? _saveTimer; Timer? _adTimer; bool _playerInitializing = false;
  
  // Torrent Streamer Subs
  StreamSubscription? _torrentSub;

  // HunterApi — servidores e URL real 
  List<Map<String, dynamic>> _servidoresNovos = [];
  int    _servidorAtivoIdx  = -1;
  bool   _extracandoHls     = false;
  String _hlsUrlAtiva       = '';   
  
  // WebView Player: fallback
  bool _webViewPlayerShowing = false;
  WebViewController? _webViewPlayerCtrl;

  // Comentários da Tabela 'links_salvos'
  List<dynamic> _comentariosList = [];
  bool _carregandoComentarios = true;
  final TextEditingController _comentarioCtrl = TextEditingController();

  @override void initState() { 
    super.initState(); 
    _salvarHistoricoGeral(); 
    _checkResumeData(); 
    _loadDetails(); 
    _carregarComentarios();
  }
  
  @override void dispose() { 
    _saveTimer?.cancel(); 
    _adTimer?.cancel(); 
    _torrentSub?.cancel();
    try { TorrentStreamer.stop(); } catch(_) {}
    _chewieController?.dispose(); 
    _videoPlayerController?.dispose(); 
    _webViewPlayerCtrl = null; 
    _comentarioCtrl.dispose(); 
    _exitFullscreen(); 
    super.dispose(); 
  }

  void _enterFullscreen() { SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]); SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); setState(() => _isFullscreen = true); }
  void _exitFullscreen() { SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); if (mounted) setState(() => _isFullscreen = false); }

  void _checkResumeData() async {
    final prefs = await SharedPreferences.getInstance(); String? data = prefs.getString("resume_${widget.item['id']}");
    if (data != null) { var map = json.decode(data); savedPositionSeconds = map['position'] ?? 0; savedEpId = map['ep_id']; savedEpNome = map['ep_nome']; }
  }

  void _iniciarSalvamentoContinuo() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
        final pos = _videoPlayerController!.value.position;
        if (pos.inSeconds > 0) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString("resume_${widget.item['id']}", json.encode({"position": pos.inSeconds, "ep_id": savedEpId, "ep_nome": epAtivoNome}));
        }
      }
    });
  }

  void _salvarHistoricoGeral() async {
    final prefs = await SharedPreferences.getInstance(); List<String> hist = prefs.getStringList('history') ?? [];
    Map<String, dynamic> it = {'id': widget.item['id'], 'title': widget.item['name'] ?? widget.item['titulo'], 'type': widget.item['type']?['slug'] ?? widget.item['tipo'] ?? 'filmes', 'poster_path': widget.item['poster'] ?? widget.item['imagem']};
    hist.removeWhere((e) => json.decode(e)['id'] == widget.item['id']); hist.insert(0, json.encode(it)); await prefs.setStringList('history', hist);
  }

  // ── COMUNIDADE: CARREGAR E ENVIAR COMENTÁRIOS USANDO 'links_salvos' ──
  Future<void> _carregarComentarios() async {
    setState(() => _carregandoComentarios = true);
    try {
      final tmdbId = (details?['tmdb_id'] ?? widget.item['tmdb_id'] ?? widget.item['id']).toString();
      final res = await Supabase.instance.client
          .from('links_salvos')
          .select()
          .eq('url', tmdbId) 
          .eq('nome', 'COMENTARIO')
          .order('created_at', ascending: false);
      if (mounted) setState(() { _comentariosList = res; _carregandoComentarios = false; });
    } catch (e) {
      if (mounted) setState(() => _carregandoComentarios = false);
    }
  }

  Future<void> _enviarComentario() async {
    if (_comentarioCtrl.text.trim().isEmpty) return;
    try {
      final tmdbId = (details?['tmdb_id'] ?? widget.item['tmdb_id'] ?? widget.item['id']).toString();
      await Supabase.instance.client.from('links_salvos').insert({
        'nome': 'COMENTARIO',
        'url': tmdbId, 
        'comentario': _comentarioCtrl.text.trim(),
      });
      _comentarioCtrl.clear();
      FocusScope.of(context).unfocus();
      _carregarComentarios();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao enviar: $e"), backgroundColor: Colors.red));
    }
  }

  void _loadDetails() async {
    final id = widget.item['id'].toString();
    final tipo = widget.item['type']?['slug'] ?? widget.item['tipo'] ?? 'filmes';
    
    final data = await CoreMediaVault.getDetails(id, tipo);
    if (mounted) {
      setState(() {
        details = data;
        sinopse = cleanTitle(details?['description'] ?? details?['sinopse'] ?? "Sinopse não disponível");
        backdrop = details?['backdrop'] ?? widget.item['poster'] ?? widget.item['imagem'] ?? "";
        if (details?['recommendations']?['items'] != null) recomendacoes = details!['recommendations']['items'];
        isDataLoaded = true;
      });

      if (tipo != 'filmes' && details?['seasons'] != null && details!['seasons'].isNotEmpty) {
        setState(() { temporadas = details!['seasons']; tempSelecionada = temporadas[0]['id'].toString(); });
        _carregarEpisodios(tempSelecionada!);
      } else if (tipo == 'filmes' && savedPositionSeconds > 0) {
        _abrirServidores(id, details?['name'] ?? widget.item['titulo'], false);
      }
      _carregarComentarios(); 
    }
  }

  void _carregarEpisodios(String seasonId) async {
    final eps = await CoreMediaVault.getEpisodes(seasonId);
    if (mounted) {
      setState(() {
        episodios = eps.asMap().entries.map((entry) {
          int i = entry.key; var e = entry.value;
          String numFormatado = e['number'] != null ? e['number'].toString() : (i + 1).toString();
          return {"id": e['id'].toString(), "full_nome": e['name'] ?? e['subtitle'] ?? "Episódio $numFormatado", "num": numFormatado};
        }).toList();
      });
      if (!_autoPlayDisparado && savedEpId != null) {
        _autoPlayDisparado = true;
        final idx = episodios.indexWhere((e) => e['id'] == savedEpId);
        if (idx != -1) setState(() => _epAtivoIndex = idx);
        _abrirServidores(savedEpId!, savedEpNome ?? "Episódio", false);
      }
    }
  }

  Future<void> _cleanPlayer() async {
    _torrentSub?.cancel();
    try { await TorrentStreamer.stop(); } catch(_) {}
    
    final oldChewie = _chewieController;
    final oldVideo = _videoPlayerController;
    _chewieController = null;
    _videoPlayerController = null;
    if (mounted) setState(() {});
    oldChewie?.dispose();
    if (oldVideo != null) await oldVideo.dispose();
  }

  void _proximoEpisodio() {
    if (episodios.isEmpty) return;
    final nextIdx = _epAtivoIndex + 1;
    if (nextIdx >= episodios.length) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Já é o último episódio.")));
      return;
    }
    final ep = episodios[nextIdx];
    final nomeTitulo = widget.item['name'] ?? widget.item['titulo'] ?? "";
    setState(() => _epAtivoIndex = nextIdx);
    _abrirServidores(ep['id'], "$nomeTitulo - ${ep['full_nome']}", false);
  }

  Future<void> _abrirServidores(String idVideo, String nomeVideo, bool isParaDownload) async {
    if (savedEpId != null && savedEpId != idVideo) {
      savedPositionSeconds = 0;
      setState(() { _hlsUrlAtiva = ''; _servidoresNovos = []; _servidorAtivoIdx = -1; });
    }

    if (isParaDownload) {
      if (_hlsUrlAtiva.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Inicia o vídeo primeiro para poder fazer o download."),
            backgroundColor: Color(0xFF880000),
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }
      _mostrarRewardedPopup(
        mensagemDownload: "Para iniciar a transferência,",
        onSuccess: () => DownloadManager.startDownload(_hlsUrlAtiva, nomeVideo, true),
      );
      return;
    }

    await _cleanPlayer();
    setState(() {
      isPlaying = true; isServerLoading = true;
      epAtivoNome = nomeVideo; savedEpId = idVideo;
      _serversDisponiveis = []; _urlAtiva = '';
      _servidoresNovos = []; _servidorAtivoIdx = -1; _hlsUrlAtiva = '';
    });

    final tipo    = widget.item['type']?['slug'] ?? widget.item['tipo'] ?? 'filmes';
    final isFilme = tipo == 'filmes';
    final tmdbId  = (details?['tmdb_id'] ?? widget.item['tmdb_id'] ?? widget.item['id']).toString();

    String season  = '';
    String episode = '';
    if (!isFilme) {
      final tempNum = temporadas.cast<Map?>()
          .firstWhere((t) => t!['id'].toString() == tempSelecionada, orElse: () => null)?['number'];
      season  = (tempNum ?? '1').toString();
      if (_epAtivoIndex >= 0 && _epAtivoIndex < episodios.length) {
        episode = episodios[_epAtivoIndex]['num'] ?? '1';
      }
    }

    final novosServers = await HunterApi.getServers(
      tmdbId: tmdbId, isFilme: isFilme, season: season, episode: episode,
    );

    // ── Buscar Servidores Comunitários da tabela 'links_salvos' ──
    List<Map<String, dynamic>> communityServers = [];
    try {
      final resComunidade = await Supabase.instance.client
          .from('links_salvos')
          .select()
          .eq('comentario', tmdbId); 
      
      for (var row in resComunidade) {
        if (row['nome'] == 'COMENTARIO') continue; 
        
        String dbNome = row['nome'].toString();
        
        if (isFilme) {
          if (!dbNome.startsWith('T') && !dbNome.contains(' - ')) {
            communityServers.add({
              'name': '[COMUNIDADE]',
              'audio': dbNome,
              'url': row['url'],
              'id_banco': row['id'].toString(),
            });
          }
        } else {
          String prefix = 'T$season E$episode - ';
          if (dbNome.startsWith(prefix)) {
            communityServers.add({
              'name': '[COMUNIDADE]',
              'audio': dbNome.replaceAll(prefix, ''),
              'url': row['url'],
              'id_banco': row['id'].toString(),
            });
          }
        }
      }
    } catch (_) {}

    if (!mounted) return;

    final combinedServers = [...novosServers, ...communityServers];

    if (combinedServers.isEmpty) {
      setState(() { isServerLoading = false; isPlaying = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nenhum servidor disponível para este conteúdo.")),
      );
      return;
    }

    setState(() { _servidoresNovos = combinedServers; isServerLoading = false; });

    final autoIdx = combinedServers.indexWhere((s) => s['audio'].toString().toLowerCase().contains('dublado'));
    _selecionarServidor(combinedServers[autoIdx != -1 ? autoIdx : 0], autoIdx != -1 ? autoIdx : 0, tipo);
  }

  void _selecionarServidor(Map<String, dynamic> servidor, int idx, String tipo) {
    setState(() { 
      _servidorAtivoIdx = idx; 
      _hlsUrlAtiva = servidor['url']!; 
    });
    
    _iniciarExoPlayer(servidor['url']!, epAtivoNome ?? '');
  }

  static bool _isSignedCdnUrl(String url) {
    final q = url.toLowerCase();
    return q.contains('x-amz-signature') ||
           q.contains('x-amz-credential') ||
           q.contains('awsaccesskeyid') ||
           q.contains('x-goog-signature') ||
           (q.contains('.wasabisys.com') && q.contains('?')) ||
           (q.contains('.amazonaws.com') && q.contains('?')) ||
           (q.contains('.r2.dev') && q.contains('?')) ||
           (q.contains('.backblazeb2.com') && q.contains('?'));
  }

  Future<_ProbeResult> _resolveEnvelopeUrl(String envelopeUrl) async {
    final hdrs = {
      "User-Agent": "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/112.0 Mobile Safari/537.36",
      "Referer": _smartPlayUrl,
      "Accept": "*/*",
    };
    try {
      final res = await http.get(Uri.parse(envelopeUrl), headers: hdrs)
          .timeout(const Duration(seconds: 15));
      final body = res.body.trim();

      if (body.startsWith('#EXTM3U')) {
        try {
          final dir = Directory.systemTemp;
          final fname = 'cdcine_' + DateTime.now().millisecondsSinceEpoch.toString() + '.m3u8';
          final f = File(dir.path + '/' + fname);
          await f.writeAsString(body);
          return _ProbeResult(url: f.uri.toString(), isHls: true, isLocalFile: true);
        } catch (_) {
          return _ProbeResult(url: envelopeUrl, isHls: true);
        }
      }

      if (body.startsWith('{') || body.startsWith('[')) {
        try {
          final decoded = json.decode(body);
          final map = decoded is List ? decoded.first as Map : decoded as Map;

          final inner = (map['url'] ?? map['link'] ?? map['file'] ??
                         map['src'] ?? map['stream'] ?? '').toString().trim();
          if (inner.isNotEmpty && inner.startsWith('http')) {
            return _probeUrl(inner);
          }

          final rawList = map['results'] ?? map['resultados'] ??
                          map['items']   ?? map['data'];
          if (rawList is List && rawList.isNotEmpty) {
            final entries = rawList.whereType<Map>().toList();
            final firstHref = entries.first['href']?.toString() ?? '';

            final fragRx = RegExp(r'(\d+)\.html');
            if (fragRx.hasMatch(firstHref)) {
              final Map<int, Map> best = {};
              for (final e in entries) {
                final href = e['href']?.toString() ?? '';
                final m = fragRx.firstMatch(href);
                if (m == null) continue;
                final idx = int.tryParse(m.group(1)!) ?? -1;
                if (idx < 0) continue;
                final score = ((e['score'] ?? e['pontuação'] ?? e['score'] ?? 0) as num).toDouble();
                if (!best.containsKey(idx) || score > (best[idx]!['_s'] as double)) {
                  best[idx] = Map.from(e)..['_s'] = score;
                }
              }

              if (best.isNotEmpty) {
                final sorted = best.keys.toList()..sort();
                final buf = StringBuffer()
                  ..writeln('#EXTM3U')
                  ..writeln('#EXT-X-VERSION:3')
                  ..writeln('#EXT-X-TARGETDURATION:10')
                  ..writeln('#EXT-X-ALLOW-CACHE:YES');
                for (final i in sorted) {
                  buf.writeln('#EXTINF:10.0,');
                  buf.writeln(best[i]!['href']);
                }
                buf.writeln('#EXT-X-ENDLIST');

                try {
                  final dir = Directory.systemTemp;
                  final fname = 'cdcine_' + DateTime.now().millisecondsSinceEpoch.toString() + '.m3u8';
                  final f = File(dir.path + '/' + fname);
                  await f.writeAsString(buf.toString());
                  return _ProbeResult(url: f.uri.toString(), isHls: true, isLocalFile: true);
                } catch (_) {}
              }
            }

            for (final e in entries) {
              final u = (e['url'] ?? e['link'] ?? e['file'] ?? e['src'] ?? '').toString().trim();
              if (u.isNotEmpty && u.startsWith('http')) return _probeUrl(u);
            }
          }
        } catch (_) {}
      }

      final lines = body.split('\n').expand((l) => l.split('\r')).map((l) => l.trim()).where((l) => l.isNotEmpty);
      for (final line in lines) {
        if (line.startsWith('http')) return _probeUrl(line);
      }

      final ct = (res.headers['content-type'] ?? '').toLowerCase();
      if (ct.contains('mpegurl') || ct.contains('x-mpegurl')) {
        return _ProbeResult(url: envelopeUrl, isHls: true);
      }
      return _ProbeResult(url: envelopeUrl, isHls: false);
    } catch (_) {
      return _ProbeResult(url: envelopeUrl, isHls: false);
    }
  }

  Future<_ProbeResult> _probeUrl(String url) async {
    final String pathOnly;
    try { pathOnly = Uri.parse(url).path.toLowerCase(); }
    catch (_) { return _ProbeResult(url: url, isHls: false); }

    if (pathOnly.endsWith('.m3u8') || pathOnly.endsWith('.m3u')) {
      return _ProbeResult(url: url, isHls: true);
    }
    if (pathOnly.endsWith('.ts')) return _ProbeResult(url: url, isHls: true);
    if (pathOnly.endsWith('.mpd'))  return _ProbeResult(url: url, isHls: false);
    if (pathOnly.endsWith('.mp4')  || pathOnly.endsWith('.mkv') ||
        pathOnly.endsWith('.avi')  || pathOnly.endsWith('.webm') ||
        pathOnly.endsWith('.mov')  || pathOnly.endsWith('.wmv') ||
        pathOnly.endsWith('.flv')  || pathOnly.endsWith('.m4v') ||
        pathOnly.endsWith('.mp4v') || pathOnly.endsWith('.3gp') ||
        pathOnly.endsWith('.ogv')) {
      return _ProbeResult(url: url, isHls: false);
    }
    
    if (pathOnly.endsWith('.txt') || pathOnly.endsWith('.json')) {
      return _resolveEnvelopeUrl(url);
    }
    if (_isSignedCdnUrl(url)) return _ProbeResult(url: url, isHls: false);

    final hdrs = {
      "User-Agent": "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/112.0 Mobile Safari/537.36",
      "Referer": _smartPlayUrl,
      "Accept": "*/*",
    };
    try {
      http.Response? head;
      try {
        head = await http.head(Uri.parse(url), headers: hdrs).timeout(const Duration(seconds: 8));
      } catch (_) {}
      final ct = (head?.headers['content-type'] ?? '').toLowerCase();
      if (ct.contains('mpegurl') || ct.contains('x-mpegurl')) return _ProbeResult(url: url, isHls: true);
      if (ct.contains('dash+xml')) return _ProbeResult(url: url, isHls: false);
      if (ct.startsWith('video/') || ct.contains('octet-stream')) return _ProbeResult(url: url, isHls: false);
      
      final get = await http.get(Uri.parse(url), headers: hdrs).timeout(const Duration(seconds: 12));
      final body = get.body.trimLeft();
      if (body.startsWith('#EXTM3U')) {
        try {
          final dir = Directory.systemTemp;
          final fname = 'cdcine_' + DateTime.now().millisecondsSinceEpoch.toString() + '.m3u8';
          final f = File(dir.path + '/' + fname);
          await f.writeAsString(body);
          return _ProbeResult(url: f.uri.toString(), isHls: true, isLocalFile: true);
        } catch (_) { return _ProbeResult(url: url, isHls: true); }
      }
      final ctGet = (get.headers['content-type'] ?? '').toLowerCase();
      if (ctGet.contains('mpegurl')) return _ProbeResult(url: url, isHls: true);
      return _ProbeResult(url: url, isHls: false);
    } catch (_) {
      return _ProbeResult(url: url, isHls: false);
    }
  }

  void _iniciarExoPlayer(String url, String tituloEpisodio, {String embedUrl = ''}) async {
    if (_playerInitializing) return;
    _playerInitializing = true;

    await _cleanPlayer();
    setState(() { _urlAtiva = url; isPlaying = true; isServerLoading = true; _isBuffering = false; });

    // ── Suporte direto a Magnet Links com motor nativo ──
    if (url.toLowerCase().startsWith('magnet:')) {
      _playerInitializing = false;
      setState(() { isPlaying = true; isServerLoading = true; _isBuffering = true; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A estabelecer conexão com o Torrent (Buscando pares...)")));

      try {
        await TorrentStreamer.stop(); 
        await TorrentStreamer.start(url);
        
        _torrentSub?.cancel();
        _torrentSub = TorrentStreamer.updates.listen((status) {
          if (!mounted) return;
          
          if (status.hasVideo && status.videoUrl != null && status.videoUrl!.isNotEmpty) {
            _torrentSub?.cancel();
            // Motor torrent retornou a stream local, joga pro ExoPlayer normalmente
            _iniciarExoPlayer(status.videoUrl!, tituloEpisodio, embedUrl: embedUrl);
          }
        }, onError: (e) {
          _tentarProximoServidor();
        });
      } catch (e) {
        _tentarProximoServidor();
      }
      return;
    }

    final posParaSeek = savedPositionSeconds;
    final pathLower = ((){try{return Uri.parse(url).path.toLowerCase();}catch(_){return url.toLowerCase();}})();

    if ((pathLower.endsWith('.txt') || pathLower.endsWith('.json')) && embedUrl.isNotEmpty) {
      _playerInitializing = false;
      _iniciarWebViewPlayer(embedUrl, tituloEpisodio);
      return;
    }

    // Suporte a embeds web gerais da comunidade
    bool isKnownVideoExtension = pathLower.endsWith('.mp4') || pathLower.endsWith('.m3u8') || pathLower.endsWith('.mkv') || pathLower.endsWith('.webm') || pathLower.endsWith('.ts') || pathLower.endsWith('.avi') || pathLower.endsWith('.m3u');
    if (!isKnownVideoExtension && !_isSignedCdnUrl(url) && !pathLower.endsWith('.txt') && !pathLower.endsWith('.json') && url.startsWith('http') && !url.contains('127.0.0.1')) {
       _playerInitializing = false;
       _iniciarWebViewPlayer(url, tituloEpisodio);
       return;
    }

    try {
      final probe = await _probeUrl(url);

      final hdrs = (probe.isLocalFile || _isSignedCdnUrl(url))
          ? <String, String>{}
          : {
              "Origin": "https://redeflixapi.store",
              "Referer": "https://redeflixapi.store/",
              "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
              "Accept": "*/*",
            };

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(probe.url),
        httpHeaders: hdrs,
      );

      final timeout = probe.isHls ? const Duration(seconds: 90) : const Duration(seconds: 120);
      await _videoPlayerController!.initialize().timeout(timeout);

      if (posParaSeek > 0 &&
          _videoPlayerController!.value.duration.inSeconds > 0 &&
          posParaSeek < _videoPlayerController!.value.duration.inSeconds) {
        await _videoPlayerController!.seekTo(Duration(seconds: posParaSeek));
      }

      final bool isLive = probe.isHls && _videoPlayerController!.value.duration == Duration.zero;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        startAt: posParaSeek > 0 ? Duration(seconds: posParaSeek) : null,
        allowFullScreen: true,
        allowMuting: true,
        showControlsOnInitialize: false,
        isLive: isLive,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFE50914),
          handleColor: const Color(0xFFE50914),
          bufferedColor: Colors.white38,
          backgroundColor: Colors.white24,
        ),
        errorBuilder: (context, errorMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(seconds: 6), () {
              if (mounted && isPlaying) _tentarProximoServidor();
            });
          });
          final erro = errorMessage.isNotEmpty ? errorMessage : 'Erro desconhecido';
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, color: Color(0xFFE50914), size: 36),
              const SizedBox(height: 10),
              const Text("Erro no servidor — a tentar outro...",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SelectableText(
                  erro,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          );
        },
      );

      Timer? bufferDebounce;
      _videoPlayerController!.addListener(() {
        if (!mounted) return;

        final buf = _videoPlayerController!.value.isBuffering;
        if (buf != _isBuffering) {
          if (buf) {
            bufferDebounce?.cancel();
            bufferDebounce = Timer(const Duration(seconds: 4), () {
              if (mounted && _videoPlayerController != null && _videoPlayerController!.value.isBuffering) {
                setState(() => _isBuffering = true);
              }
            });
          } else {
            bufferDebounce?.cancel();
            if (mounted) setState(() => _isBuffering = false);
          }
        }
      });

      if (mounted) setState(() { isServerLoading = false; });
      _iniciarSalvamentoContinuo();

      _adTimer?.cancel();
      _adTimer = Timer(const Duration(seconds: 30), () {
        if (mounted && isPlaying) {
          _videoPlayerController?.pause();
          _mostrarRewardedPopup(onSuccess: () { 
            if (mounted) {
              _videoPlayerController?.play();
              setState(() {});
            } 
          });
        }
      });

    } catch (e) {
      debugPrint('[CDCINE PLAYER ERROR] $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: SelectableText(
              'Erro: ' + (e.toString().length > 120 ? e.toString().substring(0, 120) : e.toString()),
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            backgroundColor: const Color(0xFF880000),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) _tentarProximoServidor();
    } finally {
      _playerInitializing = false;
    }
  }

  void _tentarProximoServidor() {
    if (mounted) {
      final tipo = widget.item['type']?['slug'] ?? widget.item['tipo'] ?? 'filmes';
      setState(() { isServerLoading = false; _extracandoHls = false; });
      if (_servidoresNovos.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Erro neste servidor. Por favor troque de servidor abaixo."),
          backgroundColor: Color(0xFF880000),
          duration: Duration(seconds: 5),
        ));
      } else {
        setState(() { isPlaying = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao reproduzir. Tenta novamente."), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _iniciarWebViewPlayer(String embedUrl, String titulo) {
    if (!mounted) return;
    const String adBlockJs = '''
(function() {
  window.open = function() { return null; };
  document.addEventListener('click', function(e) {
    var a = e.target.closest('a');
    if (a && a.target === '_blank') { a.removeAttribute('target'); }
  }, true);
  var s=document.createElement('style');
  s.textContent='[id*=ad],[class*=ads-],[class*=-ads],[class*=advert],[class*=popup],'
    +'[id*=popup],[class*=overlay-ad],[class*=vast-],[id*=vast],'
    +'iframe[src*=doubleclick],iframe[src*=googlesyndication],iframe[src*=adnxs]'
    +'{display:none!important;visibility:hidden!important;pointer-events:none!important}';
  (document.head||document.documentElement).appendChild(s);
})();
''';
    const List<String> adDomains = [
      'doubleclick.net', 'googlesyndication.com', 'adnxs.com', 'pubmatic.com',
      'rubiconproject.com', 'openx.net', 'adsafeprotected.com', 'moatads.com',
      'casalemedia.com', 'smartadserver.com', 'outbrain.com', 'taboola.com',
      'criteo.com', 'adsrvr.org', 'advertising.com', 'adform.net',
      'aniview.com', 'vidazoo.com', 'spotxchange.com', 'springserve.com',
    ];
    
    late final WebViewController ctrl;
    ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..addJavaScriptChannel('CDCineLog', onMessageReceived: (_) {})
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) async {
          try { await ctrl.runJavaScript(adBlockJs); } catch (_) {}
        },
        onNavigationRequest: (req) {
          final u = req.url.toLowerCase();
          for (final d in adDomains) {
            if (u.contains(d)) return NavigationDecision.prevent;
          }
          final p = (){try{return Uri.parse(req.url).path.toLowerCase();}catch(_){return u;};}();
          if ((p.endsWith('.mp4') || p.endsWith('.m3u8') || p.endsWith('.mkv') ||
               p.endsWith('.webm') || p.endsWith('.m3u') || _isSignedCdnUrl(req.url)) &&
              !req.url.contains('redeflix') && !req.url.contains('embedplayer')) {
            if (mounted) setState(() { _hlsUrlAtiva = req.url; });
            setState(() { _webViewPlayerShowing = false; _webViewPlayerCtrl = null; });
            _playerInitializing = false;
            _iniciarExoPlayer(req.url, titulo);
            return NavigationDecision.prevent;
          }
          
          final uri = Uri.parse(embedUrl);
          final embedHost = uri.host;
          
          if (u.startsWith('http') && !u.contains('redeflix') && !u.contains('embedplayer') && !u.contains(embedHost)) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(embedUrl), headers: {
        "Referer":    "https://redeflixapi.store/",
        "Origin":     "https://redeflixapi.store",
        "User-Agent": "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/112.0 Mobile Safari/537.36",
      });

    setState(() {
      _webViewPlayerShowing = true;
      _webViewPlayerCtrl    = ctrl;
      isPlaying             = true;
      isServerLoading       = false;
    });
  }

  void _mostrarRewardedPopup({required VoidCallback onSuccess, String mensagemDownload = "Para continuar a assistir"}) async {
    final adFree = await AdRemovalManager.instance.isAdFree();
    if (adFree) { onSuccess(); return; }

    if (_isFullscreen) _exitFullscreen(); 
    _videoPlayerController?.pause();
    
    if (!mounted) return;
    showDialog(
      context: context, barrierDismissible: false, useRootNavigator: true,
      builder: (ctxPopup) => PopScope(
        canPop: false, 
        child: _RewardedPopup(
          tituloAdicional: mensagemDownload,
          onSuccess: () { 
            Navigator.of(ctxPopup, rootNavigator: true).pop();
            Future.delayed(const Duration(milliseconds: 300), () {
              onSuccess();
            }); 
          }
        )
      ),
    );
  }

  void _entrarPiP() async {
    try {
      await _pipChannel.invokeMethod('enterPiP');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("O modo Janela Flutuante (PiP) não é suportado pelo teu telemóvel ou falta código nativo.", style: TextStyle(fontSize: 12))));
    }
  }

  void _mostrarDialogoEdicao(Map<String, dynamic> s, String tipo) {
    final _editNomeCtrl = TextEditingController(text: s['audio']);
    final _editUrlCtrl = TextEditingController(text: s['url']);
    bool _atualizando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Editar Servidor Comunitário", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: _editNomeCtrl, style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(hintText: "Nome", filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _editUrlCtrl, style: const TextStyle(color: Colors.white), maxLines: 2,
                  decoration: InputDecoration(hintText: "URL do Vídeo", filled: true, fillColor: Colors.grey[900], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar", style: TextStyle(color: Colors.white54))),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)),
                      onPressed: _atualizando ? null : () async {
                        if (_editNomeCtrl.text.isEmpty || _editUrlCtrl.text.isEmpty) return;
                        setDialogState(() => _atualizando = true);
                        try {
                          String curSeason = '';
                          String curEpisode = '';
                          if (tipo != 'filmes') {
                             final tempNum = temporadas.cast<Map?>().firstWhere((t) => t!['id'].toString() == tempSelecionada, orElse: () => null)?['number'];
                             curSeason = (tempNum ?? '1').toString();
                             if (_epAtivoIndex >= 0 && _epAtivoIndex < episodios.length) {
                               curEpisode = episodios[_epAtivoIndex]['num'] ?? '1';
                             }
                          }
                          String prefix = tipo != 'filmes' ? 'T$curSeason E$curEpisode - ' : '';

                          await Supabase.instance.client.from('links_salvos').update({
                            'nome': prefix + _editNomeCtrl.text.trim(),
                            'url': _editUrlCtrl.text.trim(),
                          }).eq('id', int.parse(s['id_banco']));

                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Atualizado com sucesso!"), backgroundColor: Colors.green));
                            _abrirServidores(savedEpId ?? widget.item['id'].toString(), epAtivoNome, false);
                          }
                        } catch (e) {
                          setDialogState(() => _atualizando = false);
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
                        }
                      },
                      child: _atualizando ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Salvar", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServerSelector(String tipo) {
    if (_servidoresNovos.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SERVIDORES", style: TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5,
          )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_servidoresNovos.length, (i) {
              final s       = _servidoresNovos[i];
              final isAtivo = i == _servidorAtivoIdx;
              final isDub   = s['audio'].toString().toLowerCase().contains('dublado');
              final isComunidade = s['name'] == '[COMUNIDADE]';

              return GestureDetector(
                onTap: () => _selecionarServidor(s, i, tipo),
                onLongPress: () {
                  if (isComunidade && s.containsKey('id_banco')) {
                    _mostrarDialogoEdicao(s, tipo);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAtivo ? const Color(0xFFE50914) : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAtivo ? const Color(0xFFE50914) : Colors.white12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_circle_fill, color: isAtivo ? Colors.white : (isDub ? Colors.greenAccent : Colors.lightBlueAccent), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        s['audio'],
                        style: TextStyle(
                          color: isAtivo ? Colors.white : Colors.white70,
                          fontWeight: FontWeight.bold, 
                          fontSize: 14,
                        ),
                      ),
                      if (isComunidade && isAtivo) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.edit, color: Colors.white54, size: 12),
                      ]
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),
          const Text(
            "Se tiver problemas de reproducao, por favor troque de servidor. Pressione e segure servidores da comunidade para editar.",
            style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerArea() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        if (!isPlaying || isServerLoading) ...[
          CachedNetworkImage(imageUrl: backdrop, fit: BoxFit.cover, alignment: Alignment.topCenter, errorWidget: (_, __, ___) => Container(color: Colors.black)),
          Container(color: Colors.black.withOpacity(0.6)),
        ],
        if (isPlaying && !isServerLoading && _chewieController != null) Chewie(controller: _chewieController!),
        
        if (isPlaying && isServerLoading) const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
        if (isPlaying && !isServerLoading && _isBuffering) const Center(child: SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 3))),
        if (!isPlaying && (widget.item['type']?['slug'] ?? widget.item['tipo']) == 'filmes') Center(child: IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 70), onPressed: () => _abrirServidores(widget.item['id'].toString(), widget.item['name'] ?? widget.item['titulo'], false))),
        if (!isPlaying && (widget.item['type']?['slug'] ?? widget.item['tipo']) != 'filmes') const Center(child: Text("Seleciona um episódio abaixo", style: TextStyle(color: Colors.white, fontSize: 16))),
        
        if (_webViewPlayerShowing && _webViewPlayerCtrl != null)
          WebViewWidget(controller: _webViewPlayerCtrl!),
        Positioned(top: 8, left: 4, child: SafeArea(child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20, shadows: [Shadow(color: Colors.black, blurRadius: 8)]), onPressed: () { setState(() { _webViewPlayerShowing = false; _webViewPlayerCtrl = null; }); Navigator.pop(context); }))),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), const Text("Comentários", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _comentarioCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Adicionar comentário público...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: const Color(0xFF1C1C1C),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _enviarComentario(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle),
              child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: _enviarComentario),
            )
          ],
        ),
        const SizedBox(height: 16),
        _carregandoComentarios
            ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 2)))
            : _comentariosList.isEmpty
                ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: Text("Nenhum comentário ainda. Seja o primeiro!", style: TextStyle(color: Colors.white38, fontSize: 12))))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comentariosList.length,
                    itemBuilder: (c, i) {
                      final com = _comentariosList[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(radius: 16, backgroundColor: Colors.grey[800], child: const Icon(Icons.person, color: Colors.white54, size: 18)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                                child: Text(com['comentario'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  @override Widget build(BuildContext context) {
    String nomeTitulo = widget.item['name'] ?? widget.item['titulo'] ?? "";
    String tipo = widget.item['type']?['slug'] ?? widget.item['tipo'] ?? "filmes";
    final bool isTV = MediaQuery.of(context).size.width > 900; 

    if (_isFullscreen) {
      return WillPopScope(
        onWillPop: () async { _exitFullscreen(); return false; },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildPlayerArea(),
              if (tipo != 'filmes' && isPlaying && !isServerLoading && episodios.isNotEmpty && _epAtivoIndex < episodios.length - 1)
                Positioned(
                  bottom: 80,
                  right: 20,
                  child: Material(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _proximoEpisodio,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(mainAxisSize: MainAxisSize.min, children: const [
                          Text("Próximo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 6),
                          Icon(Icons.skip_next, color: Colors.white, size: 22),
                        ]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (isTV && tipo != 'filmes') {
      return WillPopScope(
        onWillPop: () async { return true; },
        child: Scaffold(
          backgroundColor: const Color(0xFF0F0F13),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(aspectRatio: 16 / 9, child: _buildPlayerArea()),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Text(cleanTitle(nomeTitulo), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
                            InkWell(borderRadius: BorderRadius.circular(6), onTap: _entrarPiP, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)), child: const Row(children: [Icon(Icons.picture_in_picture_alt, color: Colors.white, size: 16), SizedBox(width: 5), Text("PiP", style: TextStyle(color: Colors.white, fontSize: 12))]))),
                            const SizedBox(width: 8),
                            InkWell(borderRadius: BorderRadius.circular(6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransmitirTvScreen())), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)), child: const Row(children: [Icon(Icons.cast, color: Colors.white, size: 16), SizedBox(width: 5), Text("TV", style: TextStyle(color: Colors.white, fontSize: 12))]))),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                          child: Row(children: [
                            Text(tipo.toUpperCase(), style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                            if (details?['year'] != null) ...[const SizedBox(width: 10), Text("•  ${details!['year']}", style: const TextStyle(color: Colors.white54, fontSize: 11))],
                          ]),
                        ),
                        if (isDataLoaded) Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                          child: GestureDetector(
                            onTap: () => setState(() => isSynopsisExpanded = !isSynopsisExpanded),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(sinopse, maxLines: isSynopsisExpanded ? null : 3, overflow: isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                              if (sinopse.length > 100) Padding(padding: const EdgeInsets.only(top: 4), child: Text(isSynopsisExpanded ? "Mostrar menos" : "Ver mais...", style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12))),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _buildCommentsSection()),
                        const SizedBox(height: 20),
                        const _BannerAdWidget(),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  color: const Color(0xFF0B0B0B),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (temporadas.isNotEmpty) Padding(
                        padding: const EdgeInsets.all(10),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(filled: true, fillColor: Colors.grey[900], contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE50914), width: 2))),
                          dropdownColor: Colors.grey[900],
                          value: tempSelecionada,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'].toString(), child: Text(t['name'] ?? "Temporada ${t['number']}"),)).toList(),
                          onChanged: (val) { if (val != null) { setState(() { tempSelecionada = val; episodios.clear(); _epAtivoIndex = -1; }); _carregarEpisodios(val); } },
                        ),
                      ),
                      if (episodios.isNotEmpty && _epAtivoIndex < episodios.length - 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)),
                              onPressed: _proximoEpisodio,
                              icon: const Icon(Icons.skip_next, color: Colors.white, size: 18),
                              label: const Text("Próximo episódio", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      const Divider(color: Colors.white10, height: 1),
                      Expanded(
                        child: episodios.isEmpty
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                          : ListView.builder(
                              itemCount: episodios.length,
                              itemBuilder: (ctx, i) {
                                final ep = episodios[i];
                                final bool isAtivo = i == _epAtivoIndex;
                                return Material(
                                  color: isAtivo ? const Color(0xFFE50914).withOpacity(0.15) : Colors.transparent,
                                  child: InkWell(
                                    focusColor: Colors.white24,
                                    onTap: () { setState(() => _epAtivoIndex = i); _abrirServidores(ep['id'], "$nomeTitulo - ${ep['full_nome']}", false); },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(color: isAtivo ? const Color(0xFFE50914) : Colors.transparent, width: 3),
                                          bottom: const BorderSide(color: Colors.white10, width: 0.5),
                                        ),
                                      ),
                                      child: Row(children: [
                                        Container(
                                          width: 32, height: 32,
                                          decoration: BoxDecoration(color: isAtivo ? const Color(0xFFE50914) : Colors.grey[800], borderRadius: BorderRadius.circular(6)),
                                          child: Center(child: isAtivo ? const Icon(Icons.play_arrow, color: Colors.white, size: 18) : Text(ep['num'], style: TextStyle(color: Colors.grey[300], fontSize: 12, fontWeight: FontWeight.bold))),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(child: Text(ep['full_nome'], style: TextStyle(color: isAtivo ? Colors.white : Colors.white70, fontSize: 13, fontWeight: isAtivo ? FontWeight.bold : FontWeight.normal), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                        IconButton(
                                          icon: Image.asset('assets/1dm.png', width: 18, height: 18, errorBuilder: (_,__,___) => const Icon(Icons.download, color: Colors.white54, size: 18)),
                                          onPressed: () {
                                          if (_hlsUrlAtiva.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text("Inicia o episodio primeiro para poder fazer o download."),
                                              backgroundColor: Color(0xFF880000),
                                              duration: Duration(seconds: 4),
                                            ));
                                            return;
                                          }
                                          _mostrarRewardedPopup(
                                            mensagemDownload: "Para iniciar a transferencia,",
                                            onSuccess: () => DownloadManager.startDownload(_hlsUrlAtiva, "$nomeTitulo - ${ep['full_nome']}", true),
                                          );
                                        },
                                          tooltip: "Baixar com 1DM",
                                          iconSize: 18,
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async { if (_isFullscreen) { _exitFullscreen(); return false; } return true; },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F13),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Container(color: Colors.black, child: AspectRatio(aspectRatio: 16 / 9, child: _buildPlayerArea())),
              Expanded(
                child: !isDataLoaded
                  ? _buildPlayerSkeleton()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Text(cleanTitle(nomeTitulo), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                            Padding(padding: const EdgeInsets.only(left: 8), child: Material(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), child: InkWell(borderRadius: BorderRadius.circular(6), onTap: _entrarPiP, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)), child: const Row(children: [Icon(Icons.picture_in_picture_alt, color: Colors.white, size: 16), SizedBox(width: 5), Text("PiP", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]))))),
                            Padding(padding: const EdgeInsets.only(left: 8), child: Material(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), child: InkWell(borderRadius: BorderRadius.circular(6), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransmitirTvScreen())), child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)), child: const Row(children: [Icon(Icons.cast, color: Colors.white, size: 16), SizedBox(width: 5), Text("TV", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]))))),
                            if (tipo == 'filmes' || (tipo != 'filmes' && _epAtivoIndex >= 0 && _epAtivoIndex < episodios.length)) Padding(padding: const EdgeInsets.only(left: 8), child: Material(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), child: InkWell(borderRadius: BorderRadius.circular(6), onTap: () {
                                  if (_hlsUrlAtiva.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text("Inicia o vídeo primeiro para poder fazer o download."),
                                      backgroundColor: Color(0xFF880000),
                                      duration: Duration(seconds: 4),
                                    ));
                                    return;
                                  }
                                  final titulo = tipo == 'filmes' ? nomeTitulo : (_epAtivoIndex >= 0 ? "$nomeTitulo - ${episodios[_epAtivoIndex]['full_nome']}" : nomeTitulo);
                                  _mostrarRewardedPopup(
                                    mensagemDownload: "Para iniciar a transferencia,",
                                    onSuccess: () => DownloadManager.startDownload(_hlsUrlAtiva, titulo, true),
                                  );
                                }, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)), child: Row(children: [Image.asset('assets/1dm.png', width: 18, height: 18, errorBuilder: (_,__,___) => const Icon(Icons.download, color: Colors.white, size: 16)), const SizedBox(width: 5), Text(tipo == 'filmes' ? "BAIXAR" : "BAIXAR EP.", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]))))),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Text(tipo.toUpperCase(), style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                            if (details?['year'] != null) ...[const SizedBox(width: 10), Text("•  ${details!['year']}", style: const TextStyle(color: Colors.white54, fontSize: 11))],
                            if (details?['lang'] != null) ...[const SizedBox(width: 10), Text("•  ${details!['lang']}", style: const TextStyle(color: Colors.white54, fontSize: 11))],
                          ]),
                          const SizedBox(height: 15),
                          GestureDetector(onTap: () => setState(() => isSynopsisExpanded = !isSynopsisExpanded), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sinopse, maxLines: isSynopsisExpanded ? null : 3, overflow: isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)), if (sinopse.length > 150) Padding(padding: const EdgeInsets.only(top: 5), child: Text(isSynopsisExpanded ? "Mostrar menos" : "Ver mais...", style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12)))])),
                          const SizedBox(height: 16),
                          _buildServerSelector(tipo),
                          const SizedBox(height: 8),

                          if (tipo != 'filmes' && temporadas.isNotEmpty) ...[
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey[900],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE50914), width: 2)),
                                ),
                                dropdownColor: Colors.grey[900],
                                value: tempSelecionada,
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                items: temporadas.map((t) => DropdownMenuItem<String>(
                                  value: t['id'].toString(),
                                  child: Text(t['name'] ?? "Temporada ${t['number']}"),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() { tempSelecionada = val; episodios.clear(); _epAtivoIndex = -1; });
                                    _carregarEpisodios(val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (tipo != 'filmes') ...[
                            if (episodios.isNotEmpty && _epAtivoIndex >= 0 && _epAtivoIndex < episodios.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)),
                                    onPressed: _proximoEpisodio,
                                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 18),
                                    label: const Text("Próximo episódio", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            if (episodios.isEmpty)
                              SizedBox(height: 56, child: ListView.builder(
                                itemCount: 5, scrollDirection: Axis.horizontal,
                                itemBuilder: (c, i) => Shimmer.fromColors(
                                  baseColor: Colors.grey[850]!, highlightColor: Colors.grey[700]!,
                                  child: Container(width: 56, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8))),
                                ),
                              ))
                            else
                              SizedBox(
                                height: 56,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: episodios.length,
                                  itemBuilder: (ctx, i) {
                                    final ep = episodios[i];
                                    final bool isAtivo = i == _epAtivoIndex;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: ElevatedButton(
                                          autofocus: isAtivo && i == 0,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isAtivo ? const Color(0xFFE50914) : const Color(0xFF1C1C1C),
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            side: BorderSide(color: isAtivo ? Colors.transparent : Colors.white12),
                                          ).copyWith(
                                            overlayColor: MaterialStateProperty.resolveWith((states) {
                                              if (states.contains(MaterialState.focused)) return Colors.white24;
                                              return null;
                                            }),
                                          ),
                                          onPressed: () { setState(() => _epAtivoIndex = i); _abrirServidores(ep['id'], "$nomeTitulo - ${ep['full_nome']}", false); },
                                          child: isAtivo
                                              ? const Icon(Icons.play_arrow, color: Colors.white, size: 22)
                                              : Text(ep['num'], style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/1dm.png', width: 14, height: 14, errorBuilder: (_,__,___) => const Icon(Icons.download, color: Colors.white24, size: 14)),
                                const SizedBox(width: 6),
                                const Text("Seleciona um episódio e clica em BAIXAR EP. para transferir", style: TextStyle(color: Colors.white24, fontSize: 11)),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          if (recomendacoes.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Row(children: [Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), const Text("Recomendações", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
                            const SizedBox(height: 10),
                            SizedBox(height: 160, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: recomendacoes.length, itemBuilder: (ctx, i) => GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PlayerScreen(item: recomendacoes[i]))), child: Container(width: 105, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: recomendacoes[i]))))),
                            const SizedBox(height: 12),
                          ],

                          // ── Sessão de Comentários Comunitários ──
                          const SizedBox(height: 20),
                          _buildCommentsSection(),
                          const SizedBox(height: 20),

                          // ── Banners Adsterra (Native + Display) em Combo ──
                          const _BannerAdWidget(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banners Combinados Adsterra ────────────────────────────────
class _BannerAdWidget extends StatefulWidget {
  const _BannerAdWidget();
  @override State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}
class _BannerAdWidgetState extends State<_BannerAdWidget> {
  late final WebViewController _ctrl;
  bool _loaded = false;
  double _height = 400; 

  static const String _bannerHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <style>
    * { margin:0; padding:0; box-sizing:border-box; }
    body { background:#0F0F13; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 15px; padding: 10px 0; overflow-x: hidden; }
  </style>
</head>
<body>
  <script async="async" data-cfasync="false" src="//pl29657400.effectivecpmnetwork.com/0b441d364002ce46271a097b97bf33af/invoke.js"></script>
  <div id="container-0b441d364002ce46271a097b97bf33af"></div>

  <script type="text/javascript">
    atOptions = {
      'key' : '923539f65a022c48ecd0ff98e61fe4bf',
      'format' : 'iframe',
      'height' : 250,
      'width' : 300,
      'params' : {}
    };
  </script>
  <script type="text/javascript" src="//www.highperformanceformat.com/923539f65a022c48ecd0ff98e61fe4bf/invoke.js"></script>

  <script type="text/javascript">
    atOptions = {
      'key' : '3a941b7c5cd244f3fe9ffadda07677fd',
      'format' : 'iframe',
      'height' : 50,
      'width' : 320,
      'params' : {}
    };
  </script>
  <script type="text/javascript" src="//www.highperformanceformat.com/3a941b7c5cd244f3fe9ffadda07677fd/invoke.js"></script>

  <script>
    // BLOQUEIO REFORÇADO DE POP-UPS
    window.open = function() { return null; };
    document.addEventListener('click', function(e) {
      var a = e.target.closest('a');
      if (a && a.target === '_blank') { a.removeAttribute('target'); }
    }, true);
    
    function reportHeight() {
      var h = document.body.scrollHeight;
      if (h > 50) { try { BannerHeight.postMessage(h.toString()); } catch(e){} }
    }
    setInterval(reportHeight, 2000);
  </script>
</body>
</html>
''';

  @override void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0F0F13))
      ..addJavaScriptChannel('BannerHeight', onMessageReceived: (msg) {
        final h = double.tryParse(msg.message);
        if (h != null && h > 50 && mounted) {
          setState(() => _height = h + 20);
        }
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) { if (mounted) setState(() => _loaded = true); },
        onNavigationRequest: (req) {
          final u = req.url;
          // Impede explicitamente navegações de popups não relacionados ao adsterra
          if (u.startsWith('http') && !u.contains('effectivecpmnetwork.com') && !u.contains('highperformanceformat.com') && !u.contains('about:blank')) {
            launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadHtmlString(_bannerHtml, baseUrl: 'https://effectivecpmnetwork.com/'); 
  }

  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F13),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(children: [
              Container(width: 3, height: 10, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 6)),
              const Text("PUBLICIDADE", style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.bold)),
            ]),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: _height,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10),
              ),
            ),
            child: Stack(children: [
              WebViewWidget(controller: _ctrl),
              if (!_loaded)
                const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 2))),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Resultado da sonda de URL ─────────────────────────────────────────────
class _ProbeResult {
  final String url;
  final bool isHls;
  final bool isLocalFile;
  const _ProbeResult({required this.url, required this.isHls, this.isLocalFile = false});
}

// ==========================================
// TV AO VIVO
// ==========================================
const List<Map<String, String>> _iptvSources = [
  {'name': 'M3UPT (PT/BR)', 'url': 'https://m3upt.com/iptv'},
  {'name': 'IPTV-ORG Português', 'url': 'https://iptv-org.github.io/iptv/languages/por.m3u'},
  {'name': 'IPTV-ORG Brasil', 'url': 'https://iptv-org.github.io/iptv/countries/br.m3u'},
];
class TvTab extends StatefulWidget { const TvTab({super.key}); @override State<TvTab> createState() => _TvTabState(); }
class _TvTabState extends State<TvTab> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true; List<Map<String, String>> _channels = []; List<Map<String, String>> _filtered = []; bool _loading = true; String _search = "";
  @override void initState() { super.initState(); _loadChannels(); }
  Future<void> _loadChannels() async {
    setState(() => _loading = true); final List<Map<String, String>> all = []; final Set<String> seen = {};
    for (final source in _iptvSources) {
      try {
        final res = await http.get(Uri.parse(source['url']!), headers: {"User-Agent": "Mozilla/5.0", "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.8", "Referer": "https://www.google.pt/"}).timeout(const Duration(seconds: 12));
        if (res.statusCode == 200 && res.body.contains('#EXTM3U')) {
          final lines = res.body.split('\n'); String? name, logo, group;
          for (final line in lines) {
            final l = line.trim();
            if (l.startsWith('#EXTINF')) { name = RegExp(r',(.+)$').firstMatch(l)?.group(1)?.trim() ?? 'Canal'; logo = RegExp(r'tvg-logo="([^"]*)"').firstMatch(l)?.group(1) ?? ''; group = RegExp(r'group-title="([^"]*)"').firstMatch(l)?.group(1) ?? 'Outros'; } 
            else if (l.isNotEmpty && !l.startsWith('#') && name != null) { final key = '${name}_$l'; if (!seen.contains(key)) { seen.add(key); all.add({'name': name, 'logo': logo ?? '', 'group': group ?? 'Outros', 'url': l}); } name = null; }
          }
        }
      } catch (_) {}
    }
    all.sort((a, b) { final g = a['group']!.compareTo(b['group']!); return g != 0 ? g : a['name']!.compareTo(b['name']!); });
    if (mounted) setState(() { _channels = all; _filtered = all; _loading = false; });
  }
  @override Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(padding: const EdgeInsets.all(12), child: TextField(style: const TextStyle(color: Colors.white, fontSize: 14), onChanged: (q) => setState(() { _search = q; _filtered = q.isEmpty ? _channels : _channels.where((c) => c['name']!.toLowerCase().contains(q.toLowerCase()) || c['group']!.toLowerCase().contains(q.toLowerCase())).toList(); }), decoration: InputDecoration(hintText: "Pesquisar canal ou grupo...", filled: true, fillColor: Colors.grey[900], prefixIcon: const Icon(Icons.search, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), contentPadding: EdgeInsets.zero))),
        if (_loading) Expanded(child: Center(child: CircularProgressIndicator(color: const Color(0xFFE50914))))
        else Expanded(child: ListView.builder(itemCount: _filtered.length, itemBuilder: (ctx, i) { final ch = _filtered[i]; final showGroup = i == 0 || _filtered[i - 1]['group'] != ch['group']; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (showGroup && _search.isEmpty) Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4), child: Row(children: [Container(width: 3, height: 14, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), Text(ch['group']!, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))])), Material(color: Colors.transparent, child: InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _TvPlayerScreen(name: ch['name']!, url: ch['url']!, logo: ch['logo']!))), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2), leading: ClipRRect(borderRadius: BorderRadius.circular(6), child: ch['logo']!.isNotEmpty ? CachedNetworkImage(imageUrl: ch['logo']!, width: 52, height: 34, fit: BoxFit.contain, errorWidget: (_,__,___)=>Container(width: 52, height: 34, color: Colors.grey[900], child: const Icon(Icons.tv, color: Colors.white24))) : Container(width: 52, height: 34, color: Colors.grey[900], child: const Icon(Icons.tv, color: Colors.white24))), title: Text(ch['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: _search.isNotEmpty && ch['group']!.isNotEmpty ? Text(ch['group']!, style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1) : null, trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red.withOpacity(0.35))), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: Colors.red, size: 7), SizedBox(width: 4), Text("AO VIVO", style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold))])))))]); }))
      ],
    );
  }
}
class _TvPlayerScreen extends StatefulWidget { final String name, url, logo; const _TvPlayerScreen({required this.name, required this.url, required this.logo}); @override State<_TvPlayerScreen> createState() => _TvPlayerScreenState(); }
class _TvPlayerScreenState extends State<_TvPlayerScreen> { VideoPlayerController? _ctrl; ChewieController? _chewie; bool _loading = true; bool _error = false; @override void initState() { super.initState(); _init(); } Future<void> _init() async { try { _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url), httpHeaders: {"User-Agent": "Mozilla/5.0", "Referer": "https://www.google.pt/"}); await _ctrl!.initialize(); _chewie = ChewieController(videoPlayerController: _ctrl!, autoPlay: true, isLive: true, materialProgressColors: ChewieProgressColors(playedColor: const Color(0xFFE50914), handleColor: const Color(0xFFE50914), bufferedColor: Colors.white24, backgroundColor: Colors.white12)); if (mounted) setState(() => _loading = false); } catch (_) { if (mounted) setState(() { _loading = false; _error = true; }); } } @override void dispose() { _chewie?.dispose(); _ctrl?.dispose(); super.dispose(); } @override Widget build(BuildContext context) { return Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white), title: Row(children: [if (widget.logo.isNotEmpty) ...[CachedNetworkImage(imageUrl: widget.logo, height: 28, fit: BoxFit.contain, errorWidget: (_, __, ___) => const Icon(Icons.tv, color: Colors.white, size: 22)), const SizedBox(width: 10)], Expanded(child: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: Colors.white, size: 8), SizedBox(width: 4), Text("AO VIVO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))]))])), body: _loading ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))) : _error ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.signal_wifi_off, color: Colors.white54, size: 64), const SizedBox(height: 16), const Text("Canal indisponível", style: TextStyle(color: Colors.white70, fontSize: 16)), const SizedBox(height: 8), const Text("Este canal pode não funcionar\nfora de Portugal.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 13))])) : Chewie(controller: _chewie!)); } }

// ==========================================
// TELAS EXTRAS
// ==========================================
class HistoryScreen extends StatefulWidget { const HistoryScreen({super.key}); @override State<HistoryScreen> createState() => _HistoryScreenState(); }
class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = []; @override void initState() { super.initState(); carregar(); } void carregar() async { final prefs = await SharedPreferences.getInstance(); setState(() => history = (prefs.getStringList('history') ?? []).map((e) => json.decode(e) as Map<String, dynamic>).toList()); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Histórico")), body: history.isEmpty ? const Center(child: Text("Ainda não assistiu a nada.", style: TextStyle(color: Colors.grey))) : ListView.builder(itemCount: history.length, itemBuilder: (c, i) { var item = history[i]; return ListTile(leading: CachedNetworkImage(imageUrl: item['poster_path'], width: 50, fit: BoxFit.cover), title: Text(cleanTitle(item['title']), style: const TextStyle(color: Colors.white)), subtitle: Text(item['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.grey)), trailing: const Icon(Icons.play_arrow, color: Colors.red), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: {'id': item['id'], 'titulo': item['title'], 'tipo': item['type'], 'imagem': item['poster_path']})))); })); }
}

class DownloadsScreen extends StatefulWidget { const DownloadsScreen({super.key}); @override State<DownloadsScreen> createState() => _DownloadsScreenState(); }
class _DownloadsScreenState extends State<DownloadsScreen> {
  List<Map<String, dynamic>> _entries = [];
  @override void initState() { super.initState(); _carregar(); }
  Future<void> _carregar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('downloads_1dm') ?? [];
    setState(() { _entries = raw.map((e) { try { return json.decode(e) as Map<String, dynamic>; } catch(_) { return <String,dynamic>{}; } }).where((e) => e['url'] != null).toList(); });
  }
  Future<void> _remover(int i) async {
    final prefs = await SharedPreferences.getInstance();
    _entries.removeAt(i);
    await prefs.setStringList('downloads_1dm', _entries.map((e) => json.encode(e)).toList());
    setState(() {});
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(children: [
          Image.asset('assets/1dm.png', width: 26, height: 26, errorBuilder: (_,__,___) => const Icon(Icons.download, color: Colors.white, size: 22)),
          const SizedBox(width: 10),
          const Text("Enviados ao 1DM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ]),
      ),
      body: Column(children: [
        // Banner informativo
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.withOpacity(0.25))),
          child: Row(children: [
            Image.asset('assets/1dm.png', width: 32, height: 32, errorBuilder: (_,__,___) => const Icon(Icons.info, color: Colors.blue, size: 28)),
            const SizedBox(width: 12),
            const Expanded(child: Text("O download é gerido pelo app 1DM.\nAbre o 1DM para ver o progresso e os ficheiros.", style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.5))),
            TextButton(
              onPressed: () => launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=idm.internet.download.manager'), mode: LaunchMode.externalApplication),
              child: const Text("Obter\n1DM", textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
        const Divider(color: Colors.white12),
        Expanded(
          child: _entries.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Image.asset('assets/1dm.png', width: 64, height: 64, errorBuilder: (_,__,___) => const Icon(Icons.download, color: Colors.white24, size: 64)),
                const SizedBox(height: 16),
                const Text("Nenhum download enviado ainda.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                const Text("Acessa um filme ou série e clica em BAIXAR.", style: TextStyle(color: Colors.white38, fontSize: 12)),
              ]))
            : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (c, i) {
                  final e = _entries[i];
                  final title = e['title'] ?? 'Sem título';
                  final ts = e['ts'] != null ? DateTime.tryParse(e['ts'] as String) : null;
                  final tsStr = ts != null ? "${ts.day.toString().padLeft(2,'0')}/${ts.month.toString().padLeft(2,'0')} ${ts.hour.toString().padLeft(2,'0')}:${ts.minute.toString().padLeft(2,'0')}" : '';
                  return ListTile(
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/1dm.png', width: 40, height: 40, errorBuilder: (_,__,___) => const Icon(Icons.download, color: Colors.greenAccent, size: 36))),
                    title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(tsStr.isNotEmpty ? "Enviado a $tsStr · Verifica no 1DM" : "Verifica no 1DM", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new, color: Colors.blueAccent, size: 20),
                        tooltip: "Abrir no 1DM",
                        onPressed: () => DownloadManager.startDownload(e['url'] as String, title, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        tooltip: "Remover do histórico",
                        onPressed: () => _remover(i),
                      ),
                    ]),
                  );
                },
              ),
        ),
      ]),
    );
  }
}

class TransmitirTvScreen extends StatelessWidget {
  const TransmitirTvScreen({super.key});
  static const _appUrl = 'https://play.google.com/store/apps/details?id=screen.mirroring.screenmirroring&hl=pt';
  @override Widget build(BuildContext context) { return Scaffold(backgroundColor: const Color(0xFF0B0B0F), appBar: AppBar(backgroundColor: const Color(0xFF0B0B0F), iconTheme: const IconThemeData(color: Colors.white), title: const Text("Transmitir para TV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), centerTitle: true), body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: double.infinity, padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFE50914).withOpacity(0.8), const Color(0xFF8B0000)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)), child: Column(children: [const Icon(Icons.cast_connected, color: Colors.white, size: 52), const SizedBox(height: 12), Text("Ver o CDCINE na TV", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 28, letterSpacing: 1)), const SizedBox(height: 6), const Text("Segue estes passos simples para ver o teu conteúdo favorito no ecrã grande!", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5))])), const SizedBox(height: 28), _passo(1, Icons.download_outlined, "Instala o app gratuito", "Descarrega o app \"Espelhar Celular na TV\" gratuitamente na Google Play Store. É rápido e fácil!", botao: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01875F), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => launchUrl(Uri.parse(_appUrl), mode: LaunchMode.externalApplication), icon: const Icon(Icons.download, color: Colors.white, size: 18), label: const Text("Baixar na Play Store", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), _passo(2, Icons.wifi, "Liga o Wi‑Fi", "Garante que o teu telemóvel e a tua TV estão ligados à mesma rede Wi‑Fi em casa.", dica: "Dica: Usa o Wi-Fi de casa, não os dados móveis!"), _passo(3, Icons.tv, "Abre o app e seleciona a TV", "Abre o \"Espelhar Celular na TV\", clica em Ligar e o app vai procurar automaticamente a tua TV. Clica no nome da tua TV para conectar."), _passo(4, Icons.play_circle_outline, "Volta ao CDCINE e reproduz", "Com a ligação feita, volta ao CDCINE, escolhe o teu filme ou série e carrega em play. O conteúdo aparece na TV!"), const SizedBox(height: 24), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.info_outline, color: Colors.white54, size: 16), SizedBox(width: 8), Text("Compatível com:", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13))]), const SizedBox(height: 10), _CompatItem(icon: Icons.check_circle, text: "Smart TVs (Samsung, LG, Sony, etc.)"), _CompatItem(icon: Icons.check_circle, text: "Chromecast e Google TV"), _CompatItem(icon: Icons.check_circle, text: "Fire TV Stick (Amazon)"), _CompatItem(icon: Icons.check_circle, text: "Qualquer TV com Wi-Fi ou HDMI")])), const SizedBox(height: 24), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01875F), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => launchUrl(Uri.parse(_appUrl), mode: LaunchMode.externalApplication), icon: const Icon(Icons.open_in_new, color: Colors.white), label: const Text("Baixar app gratuito", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))), const SizedBox(height: 8), const Center(child: Text("Gratuito • Sem anúncios forçados • Fácil de usar", style: TextStyle(color: Colors.white30, fontSize: 11))), const SizedBox(height: 24)]))); }
  Widget _passo(int num, IconData icon, String titulo, String descricao, {Widget? botao, String? dica}) { return Padding(padding: const EdgeInsets.only(bottom: 20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFFE50914), shape: BoxShape.circle), child: Center(child: Text('$num', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))), Container(width: 2, height: 60, color: Colors.white10, margin: const EdgeInsets.symmetric(vertical: 4))]), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 8), Row(children: [Icon(icon, color: const Color(0xFFE50914), size: 18), const SizedBox(width: 8), Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))]), const SizedBox(height: 6), Text(descricao, style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)), if (dica != null) ...[const SizedBox(height: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.amber.withOpacity(0.3))), child: Text(dica, style: const TextStyle(color: Colors.amber, fontSize: 11)))], if (botao != null) ...[const SizedBox(height: 10), botao], const SizedBox(height: 8)]))])); }
}
class _CompatItem extends StatelessWidget { final IconData icon; final String text; const _CompatItem({required this.icon, required this.text}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [Icon(icon, color: Colors.green, size: 14), const SizedBox(width: 8), Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12))])); }

class DmcaScreen extends StatelessWidget {
  const DmcaScreen({super.key});
  Widget _dmcaItem(IconData icon, String text) { return Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.only(top: 2), padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFE50914).withOpacity(0.15), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFFE50914), size: 16)), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)))])); }
  @override Widget build(BuildContext context) { return Scaffold(backgroundColor: const Color(0xFF0B0B0F), appBar: AppBar(title: const Text("DMCA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF0B0B0F), iconTheme: const IconThemeData(color: Colors.white)), body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.shield, color: Color(0xFFE50914), size: 28), const SizedBox(width: 10), Text("Notificação de violação de\ndireitos autorais", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 22, letterSpacing: 1))]), const SizedBox(height: 24), const Text("Para enviar uma notificação de violação de direitos autorais ao CDCINE, você precisará realizar os seguintes passos: (consulte seu advogado ou a Seção 512(c)(3) da Lei de Direitos Autorais para confirmar esses requisitos)", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)), const SizedBox(height: 20), _dmcaItem(Icons.person_outline, "Informações sobre a pessoa/empresa que reivindica os direitos autorais."), _dmcaItem(Icons.link, "Envio da identificação do material protegido por direitos autorais, fornecendo os URLs correspondentes."), _dmcaItem(Icons.contact_mail_outlined, "Informações que nos permitam entrar em contato com a empresa/empresa em questão, como e-mail, número de telefone ou endereço físico."), const SizedBox(height: 20), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Todas as informações acima devem ser enviadas para:", style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)), const SizedBox(height: 12), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), onPressed: () => launchUrl(Uri.parse("mailto:cdcine@horsefucker.org?subject=DMCA%20Notice"), mode: LaunchMode.externalApplication), icon: const Icon(Icons.email_outlined, color: Colors.white), label: const Text("Enviar notificação DMCA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))), const SizedBox(height: 8), const Text("Quaisquer outros meios de envio não serão aceitos e não receberão resposta.", style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5))])), const SizedBox(height: 20), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: const Text("O conteúdo protegido por direitos autorais será analisado em até 24 horas e removido em até 48 horas.", style: TextStyle(color: Colors.blue, fontSize: 13, height: 1.6))), const SizedBox(height: 20), Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.withOpacity(0.3))), child: const Text("Observe também que, de acordo com a Seção 512(f), qualquer pessoa que, conscientemente, declare falsamente que um material ou atividade infringe direitos autorais poderá ser responsabilizada.", style: TextStyle(color: Colors.orange, fontSize: 13, height: 1.6))), const SizedBox(height: 30)]))); }
}

// ==========================================
// ==========================================
// SISTEMA DE ANÚNCIOS (WEBVIEW IN-APP POPUP)
// ==========================================

// ── Lógica de Remoção de Anúncios ──────────────────────────────────────────
class _AdRemovalData {
  final String url;
  final String codeB64;
  const _AdRemovalData(this.url, this.codeB64);
  String get decoded {
    final bytes = base64Decode(codeB64);
    return utf8.decode(bytes).trim().toLowerCase();
  }
}

class AdRemovalManager {
  AdRemovalManager._();
  static final AdRemovalManager instance = AdRemovalManager._();

  static const List<_AdRemovalData> _entries = [
    _AdRemovalData('https://shrtslug.biz/cdom',  'Y2RjaW5lMjAyNQ=='),
    _AdRemovalData('https://stfly.vip/cdom2',    'Y2RjaW5lMjAyNQ=='),
  ];

  static const String _keyExpiry  = 'adrem_expiry_ms';
  static const Duration _validity = Duration(hours: 24);

  Future<bool> isAdFree() async {
    final prefs = await SharedPreferences.getInstance();
    final exp = prefs.getInt(_keyExpiry);
    if (exp == null) return false;
    return DateTime.now().millisecondsSinceEpoch < exp;
  }

  (String, int) beginSession() {
    final idx = DateTime.now().millisecond % _entries.length;
    return (_entries[idx].url, idx);
  }

  Future<_AdRemResult> validate(String input, {required int idx, required bool urlOpened, required bool isTV}) async {
    if (!isTV && !urlOpened) {
      return _AdRemResult.invalid('Tens de abrir o link primeiro para obter o código!');
    }
    final given = input.trim().toLowerCase();
    if (given.isEmpty) return _AdRemResult.invalid('Digita o código obtido no link.');

    const blackList = ['1234', '0000', '1111', '12345', '123456', '000000', 'teste', 'admin', '123123', 'qwer', 'asdf'];
    if (given.length < 4 || blackList.contains(given) || RegExp(r'^(\d)\1+$').hasMatch(given)) {
      return _AdRemResult.invalid('Código inválido. Por favor, copia o código real da página gerada.');
    }

    final exp = DateTime.now().add(_validity).millisecondsSinceEpoch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyExpiry, exp);
    return _AdRemResult.success;
  }

  Future<void> invalidate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyExpiry);
  }
}

class _AdRemResult {
  final bool isSuccess;
  final bool isError;
  final String? message;
  const _AdRemResult._({required this.isSuccess, required this.isError, this.message});
  static const _AdRemResult success = _AdRemResult._(isSuccess: true,  isError: false);
  static _AdRemResult invalid(String msg) => _AdRemResult._(isSuccess: false, isError: false, message: msg);
  static _AdRemResult error(String msg)   => _AdRemResult._(isSuccess: false, isError: true,  message: msg);
}

class _RewardedPopup extends StatefulWidget {
  final VoidCallback onSuccess;
  final String tituloAdicional;
  const _RewardedPopup({required this.onSuccess, this.tituloAdicional = "Para continuar a assistir"});
  @override State<_RewardedPopup> createState() => _RewardedPopupState();
}

class _RewardedPopupState extends State<_RewardedPopup> {
  int _countdown60 = 60;
  int _countdown15 = 15;
  bool _aguardando60  = false;
  bool _anuncioAberto = false;
  bool _podeFechar    = false;
  Timer? _timer60;
  Timer? _timer15;
  WebViewController? _webCtrl;

  _RemStep _remStep    = _RemStep.hidden;
  String   _remUrl     = '';
  int      _remIdx     = 0;       
  bool     _remLoading = false;
  bool     _remUrlOpen = false;   
  String   _remError   = '';
  int      _remCountdown = 0;
  Timer?   _remTimer;
  final    _remCodeCtrl = TextEditingController();

  bool get _isTV => navigatorKey.currentContext != null &&
      MediaQuery.of(navigatorKey.currentContext!).size.width > 900;

  @override void initState() {
    super.initState();
    if (_adsterraLink.length < 10) exit(0);
  }

  @override void dispose() {
    _timer60?.cancel();
    _timer15?.cancel();
    _remTimer?.cancel();
    _remCodeCtrl.dispose();
    super.dispose();
  }

  void _iniciarContagemLenta() {
    setState(() { _aguardando60 = true; _countdown60 = 60; });
    _timer60 = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown60--);
      if (_countdown60 <= 0) { t.cancel(); widget.onSuccess(); }
    });
  }

  void _abrirAnuncioInApp() {
    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B0B0F))
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse('https://www.effectivecpmnetwork.com/uxdnex1e3?key=1fe6aae31fc64a4f7b7eea79b9505328'));

    setState(() { _anuncioAberto = true; _podeFechar = false; _countdown15 = 15; _webCtrl = ctrl; });

    _timer15 = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown15--);
      
      if (_countdown15 == 5) {
         launchUrl(Uri.parse('https://www.effectivecpmnetwork.com/uxdnex1e3?key=1fe6aae31fc64a4f7b7eea79b9505328'), mode: LaunchMode.externalApplication);
      }

      if (_countdown15 <= 0) { t.cancel(); setState(() => _podeFechar = true); }
    });
  }

  void _iniciarRemocao() {
    final (url, idx) = AdRemovalManager.instance.beginSession();
    setState(() {
      _remUrl     = url;
      _remIdx     = idx;
      _remStep    = _RemStep.openLink;
      _remLoading = false;
      _remUrlOpen = false;
      _remError   = '';
    });
  }

  Future<void> _abrirLink() async {
    final uri = Uri.parse(_remUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    setState(() {
      _remUrlOpen = true;
      _remStep    = _RemStep.enterCode;
      _remCountdown = 5;
    });
    _remTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _remCountdown--);
      if (_remCountdown <= 0) t.cancel();
    });
  }

  Future<void> _validarCodigo() async {
    if (_remLoading) return;
    setState(() { _remLoading = true; _remError = ''; });
    final result = await AdRemovalManager.instance.validate(
      _remCodeCtrl.text,
      idx: _remIdx,
      urlOpened: _remUrlOpen,
      isTV: _isTV,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() { _remStep = _RemStep.success; _remLoading = false; });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) widget.onSuccess();
    } else {
      setState(() {
        _remLoading = false;
        _remError   = result.isError
            ? (result.message ?? 'Erro ao validar. Tenta novamente.')
            : (result.message ?? 'Código incorrecto. Verifica e tenta de novo.');
      });
    }
  }

  void _voltarAoInicio() {
    _remTimer?.cancel();
    _remCodeCtrl.clear();
    setState(() {
      _remStep      = _RemStep.hidden;
      _remUrl       = '';
      _remUrlOpen   = false;
      _remError     = '';
      _remCountdown = 0;
    });
  }

  @override Widget build(BuildContext context) {
    if (_anuncioAberto && _webCtrl != null) {
      return Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(color: const Color(0xFF0B0B0F), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(color: Color(0xFF141414), borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
                child: Row(
                  children: [
                    const Icon(Icons.live_tv, color: Color(0xFFE50914), size: 18),
                    const SizedBox(width: 8),
                    const Expanded(child: Text("Suporta o CDCINE 🙏", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500))),
                    if (!_podeFechar)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(value: _countdown15 / 15, color: Colors.white54, strokeWidth: 2)),
                          const SizedBox(width: 6),
                          Text("${_countdown15}s", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ]),
                      )
                    else
                      ElevatedButton.icon(
                        autofocus: true,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: widget.onSuccess,
                        icon: const Icon(Icons.close, color: Colors.white, size: 16),
                        label: const Text("Fechar", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                  child: WebViewWidget(controller: _webCtrl!),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_remStep != _RemStep.hidden) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]),
          padding: const EdgeInsets.all(24),
          child: _buildRemocaoStep(),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFF141414), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)]),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/pobre.jpg', height: 120, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.live_tv, color: Colors.white54, size: 72))),
            const SizedBox(height: 16),
            Text(widget.tituloAdicional, style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 22, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("Para manter o CDCINE gratuito e os servidores online, escolhe uma das opções abaixo:", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                autofocus: true,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF01875F), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _abrirAnuncioInApp,
                icon: const Icon(Icons.bolt, color: Colors.white),
                label: const Text("Ver anúncio rápido (15 seg)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _aguardando60
                  ? Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: _countdown60 / 60, color: Colors.white54, strokeWidth: 2.5)), const SizedBox(width: 12), Text("Aguardando... $_countdown60 seg", style: const TextStyle(color: Colors.white54, fontSize: 13))]))
                  : OutlinedButton.icon(style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Colors.white38), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _iniciarContagemLenta, icon: const Icon(Icons.timer_outlined, color: Colors.white60, size: 18), label: const Text("Aguardar 60 segundos", style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500))),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _remLoading
                  ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 2.5)))
                  : OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE50914), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _iniciarRemocao,
                      icon: const Icon(Icons.block, color: Color(0xFFE50914), size: 18),
                      label: const Text("Remover anúncios (grátis)", style: TextStyle(color: Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
            ),
            if (_remError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_remError, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRemocaoStep() {
    switch (_remStep) {
      case _RemStep.hidden:
        return const SizedBox.shrink();
      case _RemStep.openLink:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, color: Color(0xFFE50914), size: 52),
            const SizedBox(height: 14),
            Text("Remover Anúncios", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24, letterSpacing: 1)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Como funciona:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 8),
                  _RemStep_(icon: Icons.open_in_browser, text: "Abre o link abaixo no navegador"),
                  _RemStep_(icon: Icons.ads_click,       text: "Passa pelos anúncios (é assim que o CDCINE se mantém grátis)"),
                  _RemStep_(icon: Icons.copy_outlined,   text: "Copia o código que aparece"),
                  _RemStep_(icon: Icons.keyboard,        text: "Volta aqui e digita o código"),
                  _RemStep_(icon: Icons.check_circle_outline, text: "24h sem anúncios! (reinicia se fechares o app)"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isTV)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                child: const Row(children: [
                  Icon(Icons.tv, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text("Na TV: abre o link no teu telemóvel, copia o código e digita aqui.", style: TextStyle(color: Colors.amber, fontSize: 12))),
                ]),
              ),
            GestureDetector(
              onTap: _abrirLink,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: const Color(0xFFE50914).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE50914).withOpacity(0.5))),
                child: Row(children: [
                  const Icon(Icons.link, color: Color(0xFFE50914), size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_remUrl, style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                  const Icon(Icons.open_in_new, color: Color(0xFFE50914), size: 16),
                ]),
              ),
            ),
            const SizedBox(height: 6),
            const Text("O código é completamente gratuito 🎉", style: TextStyle(color: Colors.green, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                autofocus: true,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: _isTV ? () => setState(() { _remStep = _RemStep.enterCode; }) : _abrirLink,
                icon: Icon(_isTV ? Icons.keyboard : Icons.open_in_browser, color: Colors.white),
                label: Text(_isTV ? "Já tenho o código →" : "Abrir link e obter código", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _voltarAoInicio, child: const Text("← Voltar", style: TextStyle(color: Colors.white54))),
          ],
        );
      case _RemStep.enterCode:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vpn_key_rounded, color: Color(0xFFE50914), size: 48),
            const SizedBox(height: 14),
            Text("Digita o código", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 22, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("Cola ou digita o código que encontraste na página:", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),
            if (_remCountdown > 0 && !_isTV)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text("Aguarda ${_remCountdown}s antes de continuar...", style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ),
            TextField(
              controller: _remCodeCtrl,
              autofocus: true,
              enabled: _isTV || (_remUrlOpen && _remCountdown <= 0),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3),
              decoration: InputDecoration(
                hintText: 'CÓDIGO AQUI',
                hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 1),
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE50914), width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _validarCodigo(),
            ),
            if (_remError.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_remError, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _remLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: (_isTV || (_remUrlOpen && _remCountdown <= 0)) ? _validarCodigo : null,
                      child: const Text("Confirmar Código", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _voltarAoInicio, child: const Text("← Recomeçar", style: TextStyle(color: Colors.white38))),
          ],
        );
      case _RemStep.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 72),
            const SizedBox(height: 16),
            Text("Anúncios Removidos!", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 26, letterSpacing: 1)),
            const SizedBox(height: 10),
            const Text("🎉 24 horas sem anúncios!\nSe fechar e reabrir o app, o processo repete-se.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
          ],
        );
    }
  }
}

class _RemStep_ extends StatelessWidget {
  final IconData icon;
  final String text;
  const _RemStep_({required this.icon, required this.text});
  @override Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: const Color(0xFFE50914), size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4))),
      ]),
    );
  }
}

enum _RemStep { hidden, openLink, enterCode, success }
