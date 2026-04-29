import 'dart:convert';
import 'dart:io';
import 'dart:async';
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
String get _adsterraLink => String.fromCharCodes([104, 116, 116, 112, 115, 58, 47, 47, 119, 119, 119, 46, 112, 114, 111, 102, 105, 116, 97, 98, 108, 101, 99, 112, 109, 114, 97, 116, 101, 110, 101, 116, 119, 111, 114, 107, 46, 99, 111, 109, 47, 106, 114, 101, 99, 121, 104, 116, 113, 63, 107, 101, 121, 61, 98, 98, 97, 98, 48, 101, 50, 50, 102, 50, 102, 99, 54, 49, 51, 52, 53, 99, 49, 56, 100, 55, 48, 102, 57, 52, 102, 98, 99, 97, 101, 53]);

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

class CDcineApp extends StatelessWidget {
  const CDcineApp({super.key});
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
        pageTransitionsTheme: const PageTransitionsTheme(builders: { TargetPlatform.android: ZoomPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder() }),
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

const String _appVersion = "1.1.0";
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
// DOWNLOADS
// ==========================================
class DownloadManager {
  static ValueNotifier<double> progress = ValueNotifier(-1.0);
  static ValueNotifier<int> activeDownloadsCount = ValueNotifier(0);
  static ValueNotifier<bool> showFloatingOverlay = ValueNotifier(false);
  static String currentTitle = ""; static CancelToken? cancelToken;

  static Future<void> startDownload(String url, String title, bool isMp4) async {
    if (Platform.isAndroid && await _getAndroidSdk() < 29) { 
      final status = await Permission.storage.request(); 
      if (!status.isGranted) return; 
    }
    
    currentTitle = cleanTitle(title); progress.value = 0.0; activeDownloadsCount.value = 1; showFloatingOverlay.value = true; cancelToken = CancelToken();
    
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          try { await dir.create(recursive: true); } catch (e) { dir = Directory('/storage/emulated/0/Documents'); if (!await dir.exists()) await dir.create(recursive: true); }
        }
      }
      
      String safeTitle = currentTitle.replaceAll(RegExp(r'[^\w\s]+'), '').trim(); 
      if (safeTitle.isEmpty) safeTitle = 'video_${DateTime.now().millisecondsSinceEpoch}';
      String ext = isMp4 ? "mp4" : "ts";
      final savePath = "${dir?.path}/CDCINE_$safeTitle.$ext";

      await Dio().download(url, savePath, cancelToken: cancelToken, options: Options(headers: {"Referer": _smartPlayUrl, "User-Agent": "Mozilla/5.0"}), onReceiveProgress: (rec, total) { if (total != -1) progress.value = rec / total; });
      progress.value = -2.0; activeDownloadsCount.value = 0;
      final prefs = await SharedPreferences.getInstance(); List<String> files = prefs.getStringList('downloads') ?? []; if (!files.contains(savePath)) { files.add(savePath); prefs.setStringList('downloads', files); }
      Future.delayed(const Duration(seconds: 4), () { progress.value = -1.0; showFloatingOverlay.value = false; });
    } catch (e) {
      activeDownloadsCount.value = 0; progress.value = CancelToken.isCancel(e as DioException) ? -1.0 : -3.0;
      Future.delayed(const Duration(seconds: 4), () { progress.value = -1.0; showFloatingOverlay.value = false; });
    }
  }
  static Future<int> _getAndroidSdk() async { try { final match = RegExp(r'API (\d+)').firstMatch(Platform.operatingSystemVersion); if (match != null) return int.parse(match.group(1)!); } catch (_) {} return 30; }

  static void hideOverlay() { showFloatingOverlay.value = false; }
  static void confirmCancelDownload(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text("Cancelar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Deseja cancelar a transferência?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não", style: TextStyle(color: Colors.grey))),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () { cancelToken?.cancel(); progress.value = -1.0; activeDownloadsCount.value = 0; showFloatingOverlay.value = false; Navigator.pop(ctx); }, child: const Text("Sim", style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
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
        if (snapshot.data!.isEmpty) return const Center(child: Text("Nenhum resultado encontrado.", style: TextStyle(color: Colors.white)));
        return CustomScrollView(slivers: [
          SliverToBoxAdapter(child: _buildCategoryHeader("Resultados")),
          SliverPadding(padding: const EdgeInsets.all(10), sliver: SliverGrid(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: snapshot.data![i]), childCount: snapshot.data!.length)))
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
  
  bool isDataLoaded = false; bool isPlaying = false; bool isServerLoading = false; bool isSynopsisExpanded = false;
  bool _isFullscreen = false; bool _isBuffering = false;
  
  int savedPositionSeconds = 0; String? savedEpId; String? savedEpNome; bool _autoPlayDisparado = false;
  Timer? _saveTimer; Timer? _adTimer; bool _playerInitializing = false;

  @override void initState() { super.initState(); _salvarHistoricoGeral(); _checkResumeData(); _loadDetails(); }
  @override void dispose() { _saveTimer?.cancel(); _adTimer?.cancel(); _chewieController?.dispose(); _videoPlayerController?.dispose(); _exitFullscreen(); super.dispose(); }

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
        _abrirServidores(savedEpId!, savedEpNome ?? "Episódio", false);
      }
    }
  }

  Future<void> _cleanPlayer() async {
    final oldChewie = _chewieController;
    final oldVideo = _videoPlayerController;
    _chewieController = null;
    _videoPlayerController = null;
    if (mounted) setState(() {});
    oldChewie?.dispose();
    if (oldVideo != null) await oldVideo.dispose();
  }

  Future<void> _abrirServidores(String idVideo, String nomeVideo, bool isParaDownload) async {
    if (savedEpId != null && savedEpId != idVideo) savedPositionSeconds = 0;

    if (!isParaDownload) {
      await _cleanPlayer();
      setState(() { isPlaying = true; isServerLoading = true; epAtivoNome = nomeVideo; savedEpId = idVideo; _serversDisponiveis = []; _urlAtiva = ''; });
    }

    final tipo = widget.item['type']?['slug'] ?? widget.item['tipo'] ?? 'filmes';
    final playersApi = await CoreMediaVault.getPlayers(idVideo, tipo);

    if (playersApi.isEmpty) {
      if (!isParaDownload) setState(() { isServerLoading = false; isPlaying = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Servidores indisponíveis.")));
      return;
    }

    List<Map> servers = playersApi.map((p) {
      String url = p["file"] ?? p["url"] ?? p["link"] ?? "";
      String tipoRaw = p["type"]?.toString() ?? "Video";
      String idioma = p["lang"]?.toString() ?? "Opção";
      // Prioridade do servidor para seleção automática (não descarta nenhum formato)
      bool isMp4 = tipoRaw.toUpperCase().contains("MP4") || url.toLowerCase().contains(".mp4");
      bool isDub = idioma.toLowerCase().contains("dub");
      return {"url": url, "tipo": tipoRaw, "idioma": idioma, "isMp4": isMp4, "isDub": isDub};
    }).where((s) => (s['url'] as String).isNotEmpty).toList();

    _serversDisponiveis = servers;

    // Prioridade: dublado MP4 > dublado qualquer > MP4 > qualquer
    Map? serverEscolhido;
    serverEscolhido = servers.cast<Map?>().firstWhere((s) => s!['isMp4'] == true && s['isDub'] == true, orElse: () => null);
    serverEscolhido ??= servers.cast<Map?>().firstWhere((s) => s!['isDub'] == true, orElse: () => null);
    serverEscolhido ??= servers.cast<Map?>().firstWhere((s) => s!['isMp4'] == true, orElse: () => null);
    serverEscolhido ??= servers.isNotEmpty ? servers.first : null;

    if (serverEscolhido == null) return;

    if (isParaDownload) {
      _mostrarRewardedPopup(
        mensagemDownload: "Para iniciar a transferência,",
        onSuccess: () {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 12), Text("A preparar transferência...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]), backgroundColor: const Color(0xFFE50914), duration: const Duration(seconds: 30), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
          DownloadManager.startDownload(serverEscolhido!['url'], nomeVideo, serverEscolhido['isMp4']);
        }
      );
    } else {
      _playerInitializing = false; 
      _iniciarExoPlayer(serverEscolhido['url'], nomeVideo);
    }
  }

  // ── Sonda a URL para descobrir o tipo real do conteúdo antes de reproduzir
  Future<_ProbeResult> _probeUrl(String url) async {
    final hdrs = {
      "User-Agent": "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/112.0 Mobile Safari/537.36",
      "Referer": _smartPlayUrl,
      "Accept": "*/*",
    };
    try {
      // HEAD rápido para ver Content-Type sem baixar o corpo
      http.Response? head;
      try {
        head = await http.head(Uri.parse(url), headers: hdrs).timeout(const Duration(seconds: 10));
      } catch (_) {}
      final ct = (head?.headers['content-type'] ?? '').toLowerCase();
      if (ct.contains('mpegurl') || ct.contains('x-mpegurl')) {
        return _ProbeResult(url: url, isHls: true);
      }
      if (ct.contains('mp4') || ct.contains('video/mp4') || ct.contains('octet-stream')) {
        // octet-stream pode ser MP4 — confia na extensão se existir
        if (url.toLowerCase().contains('.mp4')) return _ProbeResult(url: url, isHls: false);
      }
      // Extensão conhecida na URL → confia nela
      final lurl = url.toLowerCase();
      if (lurl.contains('.mp4')) return _ProbeResult(url: url, isHls: false);
      if (lurl.contains('.m3u8') || lurl.contains('.m3u') || lurl.contains('.ts')) {
        return _ProbeResult(url: url, isHls: true);
      }
      // Content-Type ambíguo (text/plain, text/html, etc.) → baixar primeiros bytes
      final get = await http.get(Uri.parse(url), headers: hdrs).timeout(const Duration(seconds: 15));
      final body = get.body.trimLeft();
      if (body.startsWith('#EXTM3U')) {
        // É um manifesto M3U8 devolvido como texto puro.
        // Gravamos num ficheiro temporário para o ExoPlayer conseguir lê-lo.
        try {
          final dir = Directory.systemTemp;
          final fname = 'cdcine_${DateTime.now().millisecondsSinceEpoch}.m3u8';
          final f = File('${dir.path}/$fname');
          await f.writeAsString(body);
          return _ProbeResult(url: f.uri.toString(), isHls: true, isLocalFile: true);
        } catch (_) {
          // Se não conseguir gravar em ficheiro, usa URL original e espera que ExoPlayer resolva
          return _ProbeResult(url: url, isHls: true);
        }
      }
      // Desconhecido → tenta como MP4/genérico
      return _ProbeResult(url: url, isHls: false);
    } catch (_) {
      // Erro na sonda → tenta de qualquer forma com a URL original
      final lurl = url.toLowerCase();
      return _ProbeResult(url: url, isHls: lurl.contains('.m3u8') || lurl.contains('.m3u') || lurl.contains('.ts'));
    }
  }

  void _iniciarExoPlayer(String url, String tituloEpisodio) async {
    if (_playerInitializing) return;
    _playerInitializing = true;

    await _cleanPlayer();
    setState(() { _urlAtiva = url; isPlaying = true; isServerLoading = true; _isBuffering = false; });

    final posParaSeek = savedPositionSeconds;
    try {
      // 1️⃣ Sondar a URL ANTES de passar ao player
      final probe = await _probeUrl(url);

      final hdrs = probe.isLocalFile ? <String, String>{} : {
        "Referer": _smartPlayUrl,
        "User-Agent": "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 Chrome/112.0 Mobile Safari/537.36",
        "Accept": "*/*",
      };

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(probe.url),
        httpHeaders: hdrs,
      );

      final timeout = probe.isHls ? const Duration(seconds: 90) : const Duration(seconds: 60);
      await _videoPlayerController!.initialize().timeout(timeout);

      if (posParaSeek > 0 &&
          _videoPlayerController!.value.duration.inSeconds > 0 &&
          posParaSeek < _videoPlayerController!.value.duration.inSeconds) {
        await _videoPlayerController!.seekTo(Duration(seconds: posParaSeek));
      }

      // HLS ao vivo = sem duração definida
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
          // Debounce: espera antes de trocar para evitar erro falso durante carregamento lento
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(seconds: 6), () {
              if (mounted && isPlaying) _tentarProximoServidor();
            });
          });
          return const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 32, height: 32, child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 2.5)),
              SizedBox(height: 12),
              Text("A carregar...", style: TextStyle(color: Colors.white70, fontSize: 13)),
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
      _adTimer = Timer(const Duration(seconds: 60), () {
        if (mounted && isPlaying) {
          _mostrarRewardedPopup(onSuccess: () { if (mounted) _videoPlayerController?.play(); });
        }
      });

    } catch (e) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) _tentarProximoServidor();
    } finally {
      _playerInitializing = false;
    }
  }

  void _tentarProximoServidor() {
    int currentIndex = _serversDisponiveis.indexWhere((s) => s['url'] == _urlAtiva);
    if (currentIndex != -1 && currentIndex < _serversDisponiveis.length - 1) {
      var nextServer = _serversDisponiveis[currentIndex + 1];
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A falhar... a tentar servidor alternativo!"), duration: Duration(seconds: 2)));
      _iniciarExoPlayer(nextServer['url'], epAtivoNome);
    } else {
      if (mounted) {
        setState(() { isServerLoading = false; isPlaying = false; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Todos os servidores falharam."), backgroundColor: Colors.red));
      }
    }
  }

  void _mostrarRewardedPopup({required VoidCallback onSuccess, String mensagemDownload = "Para continuar a assistir"}) {
    if (_isFullscreen) _exitFullscreen(); _videoPlayerController?.pause();
    showDialog(
      context: context, barrierDismissible: false, useRootNavigator: true,
      builder: (ctxPopup) => PopScope(
        canPop: false, 
        child: _RewardedPopup(
          tituloAdicional: mensagemDownload,
          onSuccess: () { 
            Navigator.of(ctxPopup, rootNavigator: true).pop(); // Bug de pop consertado!
            onSuccess(); 
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
        Positioned(top: 8, left: 4, child: SafeArea(child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20, shadows: [Shadow(color: Colors.black, blurRadius: 8)]), onPressed: () => Navigator.pop(context)))),
      ],
    );
  }

  @override Widget build(BuildContext context) {
    String nomeTitulo = widget.item['name'] ?? widget.item['titulo'] ?? "";
    String tipo = widget.item['type']?['slug'] ?? widget.item['tipo'] ?? "filmes";

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
                            if (tipo == 'filmes') Padding(padding: const EdgeInsets.only(left: 8), child: Material(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), child: InkWell(borderRadius: BorderRadius.circular(6), onTap: () => _abrirServidores(widget.item['id'].toString(), nomeTitulo, true), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)), child: const Row(children: [Icon(Icons.download, color: Colors.white, size: 16), SizedBox(width: 5), Text("BAIXAR", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]))))),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Text(tipo.toUpperCase(), style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                            if (details?['year'] != null) ...[const SizedBox(width: 10), Text("•  ${details!['year']}", style: const TextStyle(color: Colors.white54, fontSize: 11))],
                            if (details?['lang'] != null) ...[const SizedBox(width: 10), Text("•  ${details!['lang']}", style: const TextStyle(color: Colors.white54, fontSize: 11))],
                          ]),
                          const SizedBox(height: 15),
                          GestureDetector(onTap: () => setState(() => isSynopsisExpanded = !isSynopsisExpanded), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(sinopse, maxLines: isSynopsisExpanded ? null : 3, overflow: isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)), if (sinopse.length > 150) Padding(padding: const EdgeInsets.only(top: 5), child: Text(isSynopsisExpanded ? "Mostrar menos" : "Ver mais...", style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12)))])),
                          const SizedBox(height: 20),
                          
                          if (tipo != 'filmes' && temporadas.isNotEmpty) ...[
                            // Seletor de temporada — funciona com D-pad na TV Box
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
                                    setState(() { tempSelecionada = val; episodios.clear(); });
                                    _carregarEpisodios(val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (tipo != 'filmes') ...[
                            if (episodios.isEmpty)
                              SizedBox(height: 56, child: ListView.builder(
                                itemCount: 5, scrollDirection: Axis.horizontal,
                                itemBuilder: (c, i) => Shimmer.fromColors(
                                  baseColor: Colors.grey[850]!, highlightColor: Colors.grey[700]!,
                                  child: Container(width: 56, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8))),
                                ),
                              ))
                            else
                              // Lista de episódios com ElevatedButton para foco D-pad na TV Box
                              SizedBox(
                                height: 56,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: episodios.length,
                                  itemBuilder: (ctx, i) {
                                    final ep = episodios[i];
                                    final bool isAtivo = epAtivoNome == "$nomeTitulo - ${ep['full_nome']}";
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
                                            // Anel de foco visível na TV Box (D-pad)
                                          ).copyWith(
                                            overlayColor: MaterialStateProperty.resolveWith((states) {
                                              if (states.contains(MaterialState.focused)) return Colors.white24;
                                              return null;
                                            }),
                                          ),
                                          onPressed: () => _abrirServidores(ep['id'], "$nomeTitulo - ${ep['full_nome']}", false),
                                          onLongPress: () => _abrirServidores(ep['id'], "$nomeTitulo - ${ep['full_nome']}", true),
                                          child: isAtivo
                                              ? const Icon(Icons.play_arrow, color: Colors.white, size: 22)
                                              : Text(ep['num'], style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            const SizedBox(height: 8),
                            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: const Row(children: [Icon(Icons.info_outline, color: Colors.blue, size: 16), SizedBox(width: 8), Expanded(child: Text("Dica: Segura o episódio para transferir.", style: TextStyle(color: Colors.blue, fontSize: 11)))])),
                          ],

                          if (recomendacoes.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Row(children: [Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), const Text("Recomendações", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
                            const SizedBox(height: 10),
                            SizedBox(height: 160, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: recomendacoes.length, itemBuilder: (ctx, i) => GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PlayerScreen(item: recomendacoes[i]))), child: Container(width: 105, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: recomendacoes[i]))))),
                            const SizedBox(height: 12),
                          ],

                          // ── Banner de anúncio permanente ──────────────────
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

// ── Banner de Anúncio Permanente ──────────────────────────────────────────
// Carrega o script de banner do Adsterra num WebView local (loadHtmlString).
// O smart link (_adsterraLink) é usado APENAS no popup de recompensa.
class _BannerAdWidget extends StatefulWidget {
  const _BannerAdWidget();
  @override State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}
class _BannerAdWidgetState extends State<_BannerAdWidget> {
  late final WebViewController _ctrl;
  bool _loaded = false;
  double _height = 250; // altura inicial generosa para não cortar o banner

  // HTML que reporta a altura real do banner de volta ao Flutter
  static const String _bannerHtml = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { background: #141414; width: 100%; overflow-x: hidden; }
    #container-7f576864101a2ea1fe13415641ddaa54 { width: 100%; display: block; }
  </style>
</head>
<body>
  <div id="container-7f576864101a2ea1fe13415641ddaa54"></div>
  <script async="async" data-cfasync="false"
    src="https://pl29099042.profitablecpmratenetwork.com/7f576864101a2ea1fe13415641ddaa54/invoke.js">
  </script>
  <script>
    // Reporta altura real ao Flutter quando o banner carrega
    function reportHeight() {
      var container = document.getElementById('container-7f576864101a2ea1fe13415641ddaa54');
      var h = Math.max(
        document.body.scrollHeight,
        document.body.offsetHeight,
        container ? container.scrollHeight : 0,
        container ? container.offsetHeight : 0
      );
      if (h > 30) { BannerHeight.postMessage(h.toString()); }
    }
    // Tenta várias vezes até o banner estar completamente renderizado
    setTimeout(reportHeight, 500);
    setTimeout(reportHeight, 1000);
    setTimeout(reportHeight, 2000);
    setTimeout(reportHeight, 3500);
    setTimeout(reportHeight, 6000);
    new MutationObserver(function() { setTimeout(reportHeight, 300); }).observe(document.body, { childList: true, subtree: true, attributes: true });
  </script>
</body>
</html>
''';

  @override void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF141414))
      ..addJavaScriptChannel('BannerHeight', onMessageReceived: (msg) {
        final h = double.tryParse(msg.message);
        if (h != null && h > 30 && mounted) {
          setState(() => _height = h + 20); // +20 de margem generosa para não cortar
        }
      })
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) { if (mounted) setState(() => _loaded = true); },
        onNavigationRequest: (req) {
          // Cliques no anúncio abrem no browser externo
          if (!req.url.contains('profitablecpmratenetwork.com') &&
              !req.url.startsWith('about:') &&
              !req.url.startsWith('data:') &&
              !req.url.startsWith('javascript:')) {
            launchUrl(Uri.parse(req.url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadHtmlString(_bannerHtml, baseUrl: 'https://pl29099042.profitablecpmratenetwork.com');
  }

  @override Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
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
                Container(
                  color: const Color(0xFF141414),
                  child: const Center(child: SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 2))),
                ),
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
  List<String> files = []; @override void initState() { super.initState(); carregar(); } void carregar() async { final prefs = await SharedPreferences.getInstance(); setState(() => files = prefs.getStringList('downloads') ?? []); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("As Minhas Transferências")), body: Column(children: [ValueListenableBuilder<double>(valueListenable: DownloadManager.progress, builder: (context, progress, child) { if (progress >= 0.0 && progress <= 1.0) { return Card(color: Colors.grey[900], margin: const EdgeInsets.all(10), child: ListTile(leading: CircularProgressIndicator(value: progress, color: const Color(0xFFE50914)), title: Text(DownloadManager.currentTitle, style: const TextStyle(color: Colors.white)), subtitle: Text("A transferir: ${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.greenAccent)), trailing: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), tooltip: "Cancelar", onPressed: () => DownloadManager.confirmCancelDownload(context)))); } return const SizedBox.shrink(); }), const Divider(color: Colors.white24), Expanded(child: files.isEmpty ? const Center(child: Text("Nenhuma transferência concluída.", style: TextStyle(color: Colors.grey))) : ListView.builder(itemCount: files.length, itemBuilder: (c, i) { String name = files[i].split('/').last.replaceAll('CDCINE_', ''); return ListTile(leading: const Icon(Icons.video_file, color: Colors.greenAccent, size: 40), title: Text(name, style: const TextStyle(color: Colors.white)), subtitle: const Text("Guardado na Galeria - Clique para ver"), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final prefs = await SharedPreferences.getInstance(); files.removeAt(i); prefs.setStringList('downloads', files); setState(() {}); }), onTap: () { OpenFilex.open(files[i]); }); }))])); }
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
// SISTEMA DE ANÚNCIOS (WEBVIEW IN-APP POPUP)
// ==========================================
class _RewardedPopup extends StatefulWidget {
  final VoidCallback onSuccess;
  final String tituloAdicional;
  const _RewardedPopup({required this.onSuccess, this.tituloAdicional = "Para continuar a assistir"});
  @override State<_RewardedPopup> createState() => _RewardedPopupState();
}
class _RewardedPopupState extends State<_RewardedPopup> {
  int _countdown60 = 60;
  int _countdown15 = 15;
  bool _aguardando60 = false;
  bool _anuncioAberto = false;
  bool _podeFechar = false;
  Timer? _timer60;
  Timer? _timer15;
  WebViewController? _webCtrl;

  @override void initState() {
    super.initState();
    if (_adsterraLink.length < 10) exit(0); // Anti-tamper
  }

  @override void dispose() {
    _timer60?.cancel();
    _timer15?.cancel();
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
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          // Bloqueia tentativas de abrir browser externo via intent
          final uri = Uri.tryParse(req.url);
          if (uri != null && uri.scheme == 'intent') return NavigationDecision.prevent;
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(_adsterraLink));

    setState(() { _anuncioAberto = true; _podeFechar = false; _countdown15 = 15; _webCtrl = ctrl; });

    _timer15 = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown15--);
      // Abre automaticamente no navegador externo quando faltam 5 segundos
      if (_countdown15 == 5) {
        launchUrl(Uri.parse(_adsterraLink), mode: LaunchMode.externalApplication);
      }
      if (_countdown15 <= 0) { t.cancel(); setState(() => _podeFechar = true); }
    });
  }

  @override Widget build(BuildContext context) {
    // Modo WebView — anúncio a correr dentro do app
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
              // Header com contador e botão fechar
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
              // WebView com o anúncio
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

    // Tela de escolha inicial
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
          ],
        ),
      ),
    );
  }
}
