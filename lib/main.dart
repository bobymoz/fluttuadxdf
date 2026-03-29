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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

const String smartPlayUrl = "https://smartplaylite.xn--n8ja5190f.mba";
const String telegramUrl = "https://t.me/cdcine";
// Unity Ads
const String _unityGameId = "6077055"; // Android
const String _unityInterstitialId = "Cd";
const String _unityRewardedId = "Rewarded_Android";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String _c1 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script>atOptions = {'key' : 'ea3ab4f496752035d9aba623fd8faad5','format' : 'iframe','height' : 50,'width' : 320,'params' : {}};</script><script src="https://www.highperformanceformat.com/ea3ab4f496752035d9aba623fd8faad5/invoke.js"></script></body></html>""";
const String _c2 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script>atOptions = {'key' : '408e7bfeab9af6c469fca0766541b341','format' : 'iframe','height' : 250,'width' : 300,'params' : {}};</script><script src="https://www.highperformanceformat.com/408e7bfeab9af6c469fca0766541b341/invoke.js"></script></body></html>""";


const List<Map<String, String>> officialGenres = [
  {"nome": "Ação", "slug": "4", "img": "https://image.tmdb.org/t/p/w500/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg"},
  {"nome": "Action & Adventure", "slug": "53", "img": "https://image.tmdb.org/t/p/w500/2rmK7mnchw9Xr3XdiTFSxTTLXqv.jpg"},
  {"nome": "Animação", "slug": "6", "img": "https://image.tmdb.org/t/p/w500/kwsE6M5H2ZOUdK1e102Lof9XbEv.jpg"},
  {"nome": "Aventura", "slug": "5", "img": "https://image.tmdb.org/t/p/w500/vI3aUGFluXROUfnigYw3yFesS2y.jpg"},
  {"nome": "Comédia", "slug": "8", "img": "https://image.tmdb.org/t/p/w500/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg"},
  {"nome": "Crime", "slug": "7", "img": "https://image.tmdb.org/t/p/w500/vVpEOvdxVBP2aV166j5Xlvb5Cdc.jpg"},
  {"nome": "Documentário", "slug": "50", "img": "https://image.tmdb.org/t/p/w500/nTvM4mhqNlHIvUkI1gVnW6XP7GG.jpg"},
  {"nome": "Dorama", "slug": "58", "img": "https://image.tmdb.org/t/p/w500/1RydiOa2H1jVvK2nQ95XfA4Y0bA.jpg"},
  {"nome": "Drama", "slug": "51", "img": "https://image.tmdb.org/t/p/w500/xXHZeb1ywGllIlks1c20jbuy8ql.jpg"},
  {"nome": "Faroeste", "slug": "52", "img": "https://image.tmdb.org/t/p/w500/xAUYWjKEXG8y22Q7tD2sB2k9M8h.jpg"},
  {"nome": "Ficção Científica", "slug": "12", "img": "https://image.tmdb.org/t/p/w500/zEqyD0SBt6HL7W9JQoWcbWCPv30.jpg"},
  {"nome": "Terror", "slug": "9", "img": "https://image.tmdb.org/t/p/w500/5kIGw1hLq8d5k0s5dGAKyP7f1E6.jpg"},
  {"nome": "Romance", "slug": "11", "img": "https://image.tmdb.org/t/p/w500/6mJrgL7Mi13XjJeGYJFlD6UEVQ7.jpg"}
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Inicializa Unity Ads
  await UnityAds.init(
    gameId: _unityGameId,
    testMode: false,
    onComplete: () => debugPrint('Unity Ads inicializado'),
    onFailed: (error, msg) => debugPrint('Unity Ads erro: $msg'),
  );
  runApp(const CDcineApp());
}

// ==========================================
// SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.9, curve: Curves.easeIn)));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => const VersionGateScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
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
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFFE50914).withOpacity(0.4), blurRadius: 40, spreadRadius: 5)],
                    ),
                    child: ClipOval(child: Image.asset('assets/icon.png', fit: BoxFit.cover)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 52, letterSpacing: 6)),
                      const SizedBox(height: 6),
                      const Text("O melhor streaming gratuito", style: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: const Color(0xFFE50914).withOpacity(0.6), strokeWidth: 2),
                      ),
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

String cleanTitle(String input) {
  try {
    String text = Uri.decodeFull(input);
    Map<String, String> ents = {
      '&amp;':'&', '&#039;':"'", '&quot;':'"', '&#8211;':'-', '&#8217;':"'", 
      '&lt;':'<', '&gt;':'>', '&aacute;':'á', '&Aacute;':'Á', '&atilde;':'ã', 
      '&Atilde;':'Ã', '&acirc;':'â', '&Acirc;':'Â', '&agrave;':'à', '&Agrave;':'À', 
      '&eacute;':'é', '&Eacute;':'É', '&ecirc;':'ê', '&Ecirc;':'Ê', '&iacute;':'í', 
      '&Iacute;':'Í', '&oacute;':'ó', '&Oacute;':'Ó', '&otilde;':'õ', '&Otilde;':'Õ', 
      '&ocirc;':'ô', '&Ocirc;':'Ô', '&uacute;':'ú', '&Uacute;':'Ú', '&ccedil;':'ç', 
      '&Ccedil;':'Ç', '&ntilde;':'ñ', '&Ntilde;':'Ñ', '&iexcl;':'í'
    };
    ents.forEach((k, v) => text = text.replaceAll(k, v));
    return text.trim();
  } catch (e) {
    return input;
  }
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

Widget _buildGridSkeleton() {
  return GridView.builder(
    padding: const EdgeInsets.all(10), 
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
    itemCount: 12, 
    itemBuilder: (c, i) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[900]!, 
        highlightColor: Colors.grey[800]!, 
        child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)))
      );
    }
  );
}

Widget _buildHorizontalSkeleton() {
  return SizedBox(
    height: 160,
    child: ListView.builder(
      scrollDirection: Axis.horizontal, 
      padding: const EdgeInsets.symmetric(horizontal: 10), 
      itemCount: 5,
      itemBuilder: (c, i) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[900]!, 
          highlightColor: Colors.grey[800]!, 
          child: Container(width: 105, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)))
        );
      }
    ),
  );
}

Widget _buildCarouselSkeleton() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!,
    child: Container(height: 250, margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12))),
  );
}

class DownloadManager {
  static ValueNotifier<double> progress = ValueNotifier(-1.0);
  static ValueNotifier<int> activeDownloadsCount = ValueNotifier(0);
  static ValueNotifier<bool> showFloatingOverlay = ValueNotifier(false);
  
  static String currentTitle = "";
  static CancelToken? cancelToken;

  static Future<void> startDownload(String url, String title, bool isMp4) async {
    // Android 10+ (API 29+) não precisa de permissão para pasta Download pública
    if (Platform.isAndroid) {
      final info = await Permission.storage.status;
      if (!info.isGranted) {
        // Só pede permissão se for Android 9 ou anterior
        // No Android 10+ ignora e tenta diretamente
        final sdkVersion = await _getAndroidSdk();
        if (sdkVersion < 29) {
          final status = await Permission.storage.request();
          if (!status.isGranted) return;
        }
      }
    }

    currentTitle = cleanTitle(title);
    progress.value = 0.0;
    activeDownloadsCount.value = 1;
    showFloatingOverlay.value = true;
    cancelToken = CancelToken();

    try {
      // Tenta pasta Download pública primeiro
      Directory dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        // Fallback para pasta de documentos do app
        dir = Directory('/storage/emulated/0/Documents');
        if (!await dir.exists()) await dir.create(recursive: true);
      }

      String safeTitle = currentTitle.replaceAll(RegExp(r'[^\w\s]+'), '').trim();
      if (safeTitle.isEmpty) safeTitle = 'video_${DateTime.now().millisecondsSinceEpoch}';
      String ext = isMp4 ? "mp4" : "ts";
      final savePath = "${dir.path}/CDCINE_$safeTitle.$ext";

      final dio = Dio();
      await dio.download(
        url, savePath,
        cancelToken: cancelToken,
        options: Options(headers: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"}, receiveTimeout: const Duration(minutes: 30)),
        onReceiveProgress: (rec, total) { if (total != -1) progress.value = rec / total; },
      );
      progress.value = -2.0;
      activeDownloadsCount.value = 0;
      _salvarHistorico(savePath);
      Future.delayed(const Duration(seconds: 4), () { progress.value = -1.0; showFloatingOverlay.value = false; });
    } catch (e) {
      activeDownloadsCount.value = 0;
      if (e is DioException && CancelToken.isCancel(e)) {
        progress.value = -1.0;
        showFloatingOverlay.value = false;
      } else {
        progress.value = -3.0;
        Future.delayed(const Duration(seconds: 4), () { progress.value = -1.0; showFloatingOverlay.value = false; });
      }
    }
  }

  static Future<int> _getAndroidSdk() async {
    try {
      final version = Platform.operatingSystemVersion; // ex: "Android 10 (API 29)"
      final match = RegExp(r'API (\d+)').firstMatch(version);
      if (match != null) return int.parse(match.group(1)!);
      // Fallback por nome de versão
      if (version.contains('Android 10')) return 29;
      if (version.contains('Android 11')) return 30;
      if (version.contains('Android 12')) return 31;
      if (version.contains('Android 13')) return 33;
      if (version.contains('Android 14')) return 34;
    } catch (_) {}
    return 30; // Assume Android 10+ por segurança
  }

  static void hideOverlay() {
    showFloatingOverlay.value = false;
  }

  static void confirmCancelDownload(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text("Cancelar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Deseja cancelar a transferência?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { 
              cancelToken?.cancel(); 
              progress.value = -1.0; 
              activeDownloadsCount.value = 0;
              showFloatingOverlay.value = false;
              Navigator.pop(ctx); 
            },
            child: const Text("Sim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void _salvarHistorico(String path) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> files = prefs.getStringList('downloads') ?? [];
    if (!files.contains(path)) { 
      files.add(path); 
      prefs.setStringList('downloads', files); 
    }
  }
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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B0B0F), elevation: 0),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: { TargetPlatform.android: ZoomPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder() },
        ),
      ),
      builder: (context, child) => Stack(children: [child!, const DraggableDownloadOverlay()]),
      home: const _ConnectivityGate(),
    );
  }
}

class _ConnectivityGate extends StatefulWidget {
  const _ConnectivityGate();
  @override State<_ConnectivityGate> createState() => _ConnectivityGateState();
}
class _ConnectivityGateState extends State<_ConnectivityGate> {
  bool _checking = true;
  bool _noInternet = false;

  @override void initState() { super.initState(); _check(); }

  Future<void> _check() async {
    setState(() { _checking = true; _noInternet = false; });
    try {
      final res = await http.get(Uri.parse("https://www.google.com")).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        if (mounted) setState(() => _checking = false);
        return;
      }
    } catch (_) {}
    if (mounted) setState(() { _checking = false; _noInternet = true; });
  }

  @override Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0B0F),
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
      );
    }
    if (_noInternet) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0B0F),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off, color: Colors.white30, size: 80),
              const SizedBox(height: 24),
              Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 40, letterSpacing: 3)),
              const SizedBox(height: 12),
              const Text("Sem ligação à internet", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Verifica a tua ligação Wi-Fi ou dados móveis e tenta novamente.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: _check,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Tentar novamente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ]),
          ),
        ),
      );
    }
    return const SplashScreen();
  }
}

// ==========================================
// VERIFICAÇÃO DE VERSÃO
// ==========================================
const String _appVersion = "1.0.0";
const String _versionUrl = "https://pastefy.app/FlTl6ufq/raw";

class VersionGateScreen extends StatefulWidget {
  const VersionGateScreen({super.key});
  @override State<VersionGateScreen> createState() => _VersionGateScreenState();
}

class _VersionGateScreenState extends State<VersionGateScreen> {
  bool _checking = true;
  bool _needsUpdate = false;
  bool _blocked = false;
  String _latestVersion = "";
  String _downloadUrl = "";
  String _changelog = "";

  @override void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    try {
      final res = await http.get(Uri.parse(_versionUrl), headers: {"User-Agent": "Mozilla/5.0"}).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        String body = res.body;
        final start = body.indexOf('{');
        final end = body.lastIndexOf('}');
        if (start == -1 || end == -1) throw Exception('JSON not found');
        body = body.substring(start, end + 1);
        final data = json.decode(body);
        _latestVersion = (data['latest_version'] ?? _appVersion).toString().trim();
        _downloadUrl = data['download_url'] ?? "";
        _changelog = data['changelog'] ?? "";
        if (_latestVersion != _appVersion.trim()) {
          if (mounted) setState(() { _needsUpdate = true; _checking = false; });
          return;
        }
        if (mounted) setState(() => _checking = false);
        return;
      }
      // URL acessível mas status != 200 — bloqueia
      if (mounted) setState(() { _blocked = true; _checking = false; });
    } catch (_) {
      // Sem rede ou URL removida — bloqueia
      if (mounted) setState(() { _blocked = true; _checking = false; });
    }
  }

  @override Widget build(BuildContext context) {
    if (_blocked) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0B0F),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Color(0xFFE50914), size: 64),
                  const SizedBox(height: 24),
                  Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 40, letterSpacing: 3)),
                  const SizedBox(height: 12),
                  const Text("App temporariamente indisponível.\nTente novamente mais tarde.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      onPressed: () { setState(() { _checking = true; _blocked = false; }); _checkVersion(); },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Tentar novamente", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_needsUpdate) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0B0F),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.system_update, color: Color(0xFFE50914), size: 72),
                const SizedBox(height: 24),
                Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 42, letterSpacing: 3)),
                const SizedBox(height: 8),
                Text("Atualização Disponível", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 26, letterSpacing: 1)),
                const SizedBox(height: 6),
                Text("v$_appVersion  →  v$_latestVersion", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 24),
                if (_changelog.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("O que há de novo:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(_changelog, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => launchUrl(Uri.parse(_downloadUrl), mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text("Baixar Atualização", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Esta versão não é mais suportada.\nAtualize para continuar usando o CDCINE.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.5)),
              ],
            ),
          ),
        ),
      );
    }
    // Silencioso: sempre mostra MainScreen, bloqueio aparece só se _needsUpdate = true
    return const MainScreen();
  }
}

class DraggableDownloadOverlay extends StatefulWidget {
  const DraggableDownloadOverlay({super.key});
  @override State<DraggableDownloadOverlay> createState() => _DraggableDownloadOverlayState();
}
class _DraggableDownloadOverlayState extends State<DraggableDownloadOverlay> {
  double bottomOffset = 80; 
  double leftOffset = 20;
  
  @override Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DownloadManager.showFloatingOverlay,
      builder: (context, show, child) {
        if (!show) return const SizedBox.shrink();
        
        return ValueListenableBuilder<double>(
          valueListenable: DownloadManager.progress,
          builder: (context, val, _) {
            if (val == -1.0) return const SizedBox.shrink();
            Color bgColor = Colors.grey[900]!; 
            String text = "A transferir: ${DownloadManager.currentTitle} ${(val * 100).toStringAsFixed(0)}%";
            Widget icon = SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: val, color: const Color(0xFFE50914), strokeWidth: 3));
            
            if (val == -2.0) { 
              bgColor = Colors.green[800]!; 
              text = "Transferência Concluída"; 
              icon = const Icon(Icons.check_circle, color: Colors.white); 
            } else if (val == -3.0) { 
              bgColor = Colors.red[800]!; 
              text = "Erro na Transferência"; 
              icon = const Icon(Icons.error, color: Colors.white); 
            }
            
            return Positioned(
              bottom: bottomOffset, left: leftOffset,
              child: GestureDetector(
                onPanUpdate: (details) { setState(() { bottomOffset -= details.delta.dy; leftOffset += details.delta.dx; }); },
                onTap: () { if (navigatorKey.currentState != null) navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const DownloadsScreen())); },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]),
                    child: Row(
                      children: [
                        icon, const SizedBox(width: 15), 
                        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey), 
                          onPressed: () {
                            if (val >= 0.0 && val <= 1.0) {
                              DownloadManager.hideOverlay();
                            } else {
                              DownloadManager.progress.value = -1.0;
                              DownloadManager.showFloatingOverlay.value = false;
                            }
                          }
                        )
                      ],
                    ),
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

final Map<String, List<Map<String, String>>> _apiCache = {};

Future<List<Map<String, String>>> fetchScraperData(String url, {String? filterType}) async {
  if (_apiCache.containsKey(url)) {
    var list = _apiCache[url]!;
    if (filterType != null) return list.where((e) => e['tipo'] == filterType).toList();
    return list;
  }
  try {
    final res = await http.get(Uri.parse(url), headers: {"User-Agent": "Mozilla/5.0"});
    List<Map<String, String>> list = []; Set<String> vistos = {};
    RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
    for (var match in exp.allMatches(res.body)) {
      String id = match.group(3)!; String tipo = match.group(2)!;
      if (!vistos.contains(id)) {
        vistos.add(id); 
        list.add({"imagem": match.group(1)!, "tipo": tipo, "id": id, "titulo": cleanTitle(match.group(4)!)});
      }
    }
    _apiCache[url] = list;
    if (filterType != null) return list.where((e) => e['tipo'] == filterType).toList();
    return list;
  } catch (e) { 
    return []; 
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  bool isSearching = false; 
  String searchQuery = "";

  void _onSearchSubmit(String val) { 
    setState(() { 
      searchQuery = val; 
      isSearching = val.isNotEmpty; 
    }); 
  }
  
  void _clearSearch() { 
    FocusScope.of(context).unfocus();
    setState(() { 
      _searchCtrl.clear(); 
      searchQuery = ""; 
      isSearching = false; 
    }); 
  }

  void _changeTab(int index) {
    setState(() { 
      _currentIndex = index; 
      isSearching = false; 
      _searchCtrl.clear(); 
      searchQuery = ""; 
    });
  }

  @override Widget build(BuildContext context) {
    final List<Widget> views = [
      InicioTab(key: const ValueKey("inicio"), onNavigate: _changeTab),
      const PaginatedCategoryView(key: ValueKey("filmes"), urlPattern: "$smartPlayUrl/posts/filmes/[PAGE]", filterType: "filmes", title: "Filmes"),
      const PaginatedCategoryView(key: ValueKey("series"), urlPattern: "$smartPlayUrl/posts/series/[PAGE]", filterType: "series", title: "Séries"),
      const PaginatedCategoryView(key: ValueKey("animes"), urlPattern: "$smartPlayUrl/posts/animes/[PAGE]", filterType: "animes", title: "Animes"),
      const TvTab(key: ValueKey("tv")),
      const GenerosView(key: ValueKey("generos")),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (isSearching) { 
          _clearSearch(); 
        } else if (_currentIndex != 0) { 
          _changeTab(0); 
        } else { 
          SystemNavigator.pop(); 
        }
      },
      child: Scaffold(
        drawer: Drawer(
          width: 250, backgroundColor: const Color(0xFF121212),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xFFE50914)), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        mainAxisAlignment: MainAxisAlignment.end, 
                        children: [
                          Text("CDCINE", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)), 
                          Text("O melhor conteúdo.", style: TextStyle(color: Colors.white70, fontSize: 12))
                        ]
                      )
                    ),
                    ListTile(
                      leading: const Icon(Icons.send, color: Colors.blueAccent), 
                      title: const Text('Nosso Telegram', style: TextStyle(color: Colors.white)), 
                      onTap: () { launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication); }
                    ),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined, color: Colors.grey),
                      title: const Text('DMCA', style: TextStyle(color: Colors.white)),
                      onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const DmcaScreen())); }
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leadingWidth: 100, 
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Builder(builder: (c) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(c).openDrawer())),
              IconButton(icon: const Icon(Icons.history, color: Colors.white), tooltip: "Histórico", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen()))),
            ],
          ),
          title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 32, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            ValueListenableBuilder<int>(
              valueListenable: DownloadManager.activeDownloadsCount,
              builder: (context, count, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white), 
                      tooltip: "Downloads", 
                      onPressed: () { 
                        DownloadManager.showFloatingOverlay.value = true; 
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const DownloadsScreen())); 
                      }
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8, top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4), 
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      )
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
                  controller: _searchCtrl, 
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Procurar conteúdo...", 
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true, fillColor: Colors.grey[900],
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: isSearching ? IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: _clearSearch) : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: _onSearchSubmit,
                ),
              ),
            ),
          ),
        ),
        body: isSearching ? SearchResults(query: searchQuery) : IndexedStack(index: _currentIndex, children: views),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black, type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white, unselectedItemColor: Colors.grey[600],
          selectedFontSize: 10, unselectedFontSize: 10,
          currentIndex: _currentIndex,
          onTap: _changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Início"),
            BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: "Filmes"),
            BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: "Séries"),
            BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Animes"),
            BottomNavigationBarItem(icon: Icon(Icons.tv), label: "TV"),
            BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: "Gêneros"),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ABA TV — IPTV AO VIVO
// ==========================================

// Fontes IPTV públicas — múltiplas para redundância e mais canais
const List<Map<String, String>> _iptvSources = [
  {'name': 'M3UPT (PT/BR)', 'url': 'https://m3upt.com/iptv'},
  {'name': 'IPTV-ORG Português', 'url': 'https://iptv-org.github.io/iptv/languages/por.m3u'},
  {'name': 'IPTV-ORG Brasil', 'url': 'https://iptv-org.github.io/iptv/countries/br.m3u'},
  {'name': 'IPTV-ORG Portugal', 'url': 'https://iptv-org.github.io/iptv/countries/pt.m3u'},
];

class TvTab extends StatefulWidget {
  const TvTab({super.key});
  @override State<TvTab> createState() => _TvTabState();
}

class _TvTabState extends State<TvTab> with AutomaticKeepAliveClientMixin {
  @override bool get wantKeepAlive => true;

  List<Map<String, String>> _channels = [];
  List<Map<String, String>> _filtered = [];
  bool _loading = true;
  bool _noInternet = false;
  String _search = "";
  int _sourceIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override void initState() { super.initState(); _loadChannels(); }
  @override void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _loadChannels() async {
    setState(() { _loading = true; _noInternet = false; });
    bool anySuccess = false;
    final List<Map<String, String>> all = [];
    final Set<String> seen = {};

    for (final source in _iptvSources) {
      try {
        final res = await http.get(
          Uri.parse(source['url']!),
          headers: {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Accept": "*/*",
            "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.8",
            "Referer": "https://www.google.pt/",
          },
        ).timeout(const Duration(seconds: 12));

        if (res.statusCode == 200 && res.body.contains('#EXTM3U')) {
          final parsed = _parseM3U(res.body);
          for (final ch in parsed) {
            final key = '${ch['name']}_${ch['url']}';
            if (!seen.contains(key)) { seen.add(key); all.add(ch); }
          }
          anySuccess = true;
        }
      } catch (_) {}
    }

    if (!anySuccess && all.isEmpty) {
      if (mounted) setState(() { _loading = false; _noInternet = true; });
      return;
    }

    // Ordena por grupo depois por nome
    all.sort((a, b) {
      final g = a['group']!.compareTo(b['group']!);
      return g != 0 ? g : a['name']!.compareTo(b['name']!);
    });

    if (mounted) setState(() { _channels = all; _filtered = all; _loading = false; });
  }

  List<Map<String, String>> _parseM3U(String content) {
    final List<Map<String, String>> result = [];
    final lines = content.split('\n');
    String? name, logo, group;
    for (final line in lines) {
      final l = line.trim();
      if (l.startsWith('#EXTINF')) {
        name = RegExp(r',(.+)$').firstMatch(l)?.group(1)?.trim() ?? 'Canal';
        logo = RegExp(r'tvg-logo="([^"]*)"').firstMatch(l)?.group(1) ?? '';
        group = RegExp(r'group-title="([^"]*)"').firstMatch(l)?.group(1) ?? 'Outros';
        if (group!.isEmpty) group = 'Outros';
      } else if (l.isNotEmpty && !l.startsWith('#') && name != null) {
        result.add({'name': name, 'logo': logo ?? '', 'group': group ?? 'Outros', 'url': l});
        name = null; logo = null; group = null;
      }
    }
    return result;
  }

  void _onSearch(String q) {
    setState(() {
      _search = q;
      _filtered = q.isEmpty
        ? _channels
        : _channels.where((c) =>
            c['name']!.toLowerCase().contains(q.toLowerCase()) ||
            c['group']!.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  void _openChannel(Map<String, String> ch) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _TvPlayerScreen(name: ch['name']!, url: ch['url']!, logo: ch['logo']!),
    ));
  }

  @override Widget build(BuildContext context) {
    super.build(context);

    if (_noInternet) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, color: Colors.white30, size: 64),
          const SizedBox(height: 16),
          const Text("Sem ligação à internet", style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Verifica a tua ligação e tenta novamente.", style: TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: _loadChannels,
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Tentar novamente", style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: "Pesquisar canal ou grupo...",
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true, fillColor: Colors.grey[900],
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _search.isNotEmpty
                ? IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: () { _searchCtrl.clear(); _onSearch(''); })
                : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (!_loading)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 6),
            child: Row(children: [
              Text("${_filtered.length} canais", style: TextStyle(color: Colors.grey[600], fontSize: 11)),
              const Spacer(),
              TextButton.icon(
                onPressed: _loadChannels,
                icon: const Icon(Icons.refresh, size: 14, color: Colors.grey),
                label: const Text("Atualizar", style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
            ]),
          ),
        if (_loading)
          Expanded(child: ListView.builder(
            itemCount: 12,
            itemBuilder: (_, i) => Shimmer.fromColors(
              baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!,
              child: ListTile(
                leading: Container(width: 52, height: 36, color: Colors.black, margin: const EdgeInsets.symmetric(vertical: 4)),
                title: Container(height: 13, color: Colors.black),
                subtitle: Container(height: 10, color: Colors.black, margin: const EdgeInsets.only(top: 4)),
              ),
            ),
          ))
        else if (_filtered.isEmpty)
          const Expanded(child: Center(child: Text("Nenhum canal encontrado", style: TextStyle(color: Colors.grey))))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final ch = _filtered[i];
                // Separador de grupo
                final showGroup = i == 0 || _filtered[i - 1]['group'] != ch['group'];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showGroup && _search.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(children: [
                          Container(width: 3, height: 14, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)),
                          Text(ch['group']!, style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ]),
                      ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ch['logo']!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: ch['logo']!, width: 52, height: 34, fit: BoxFit.contain,
                              placeholder: (_, __) => _logoPlaceholder(),
                              errorWidget: (_, __, ___) => _logoPlaceholder())
                          : _logoPlaceholder(),
                      ),
                      title: Text(ch['name']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: _search.isNotEmpty && ch['group']!.isNotEmpty
                        ? Text(ch['group']!, style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1)
                        : null,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.12), borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.red.withOpacity(0.35))),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.circle, color: Colors.red, size: 7),
                          SizedBox(width: 4),
                          Text("AO VIVO", style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                      onTap: () => _openChannel(ch),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _logoPlaceholder() => Container(width: 52, height: 34, color: Colors.grey[900], child: const Icon(Icons.tv, color: Colors.white24, size: 18));
}

class _TvPlayerScreen extends StatefulWidget {
  final String name, url, logo;
  const _TvPlayerScreen({required this.name, required this.url, required this.logo});
  @override State<_TvPlayerScreen> createState() => _TvPlayerScreenState();
}

class _TvPlayerScreenState extends State<_TvPlayerScreen> {
  VideoPlayerController? _ctrl;
  ChewieController? _chewie;
  bool _loading = true;
  bool _error = false;

  @override void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    try {
      _ctrl = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
        httpHeaders: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
          "Referer": "https://www.google.pt/",
          "Accept-Language": "pt-PT,pt;q=0.9",
          "Origin": "https://www.google.pt",
        },
      );
      await _ctrl!.initialize();
      _chewie = ChewieController(
        videoPlayerController: _ctrl!,
        autoPlay: true,
        looping: true,
        allowFullScreen: true,
        isLive: true,
        materialProgressColors: ChewieProgressColors(playedColor: const Color(0xFFE50914), handleColor: const Color(0xFFE50914), bufferedColor: Colors.white24, backgroundColor: Colors.white12),
      );
      if (mounted) setState(() => _loading = false);
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  @override void dispose() { _chewie?.dispose(); _ctrl?.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(children: [
          if (widget.logo.isNotEmpty) ...[
            CachedNetworkImage(imageUrl: widget.logo, height: 28, fit: BoxFit.contain, errorWidget: (_, __, ___) => const Icon(Icons.tv, color: Colors.white, size: 22)),
            const SizedBox(width: 10),
          ],
          Expanded(child: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: Colors.white, size: 8), SizedBox(width: 4), Text("AO VIVO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))])),
        ]),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
        : _error
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.signal_wifi_off, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              const Text("Canal indisponível", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              const Text("Este canal pode não funcionar\nfora de Portugal.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 13)),
            ]))
          : Chewie(controller: _chewie!),
    );
  }
}

class InicioTab extends StatefulWidget {
  final Function(int) onNavigate;
  const InicioTab({super.key, required this.onNavigate});
  @override State<InicioTab> createState() => _InicioTabState();
}
class _InicioTabState extends State<InicioTab> with AutomaticKeepAliveClientMixin {
  List carouselItems = []; bool loading = true; int _currentCarouselIndex = 0; 
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _loadInitialData(); }
  void _loadInitialData() async {
    carouselItems = await fetchScraperData("$smartPlayUrl/posts/filmes/1"); 
    if (mounted) setState(() => loading = false);
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loading) _buildCarouselSkeleton()
          else if (carouselItems.isNotEmpty)
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 220, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.45, 
                    onPageChanged: (index, reason) => setState(() => _currentCarouselIndex = index)
                  ),
                  items: carouselItems.map((item) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: item))),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(item['imagem']), fit: BoxFit.cover, alignment: Alignment.topCenter)),
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Colors.transparent, Colors.black87], begin: Alignment.center, end: Alignment.bottomCenter)),
                          alignment: Alignment.bottomCenter, padding: const EdgeInsets.all(10),
                          child: Text(item['titulo'], textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
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
          
          SectionWidget(title: "Lançamentos", urlPattern: "$smartPlayUrl/genre/1/[PAGE]"),
          SectionWidget(title: "Em Alta", urlPattern: "$smartPlayUrl/genre/3/[PAGE]"),
          
          SectionWidget(title: "Filmes", urlPattern: "$smartPlayUrl/posts/filmes/[PAGE]", filterType: "filmes", onSeeAll: () => widget.onNavigate(1)),
          SectionWidget(title: "Séries", urlPattern: "$smartPlayUrl/posts/series/[PAGE]", filterType: "series", onSeeAll: () => widget.onNavigate(2)),
          SectionWidget(title: "Animes", urlPattern: "$smartPlayUrl/posts/animes/[PAGE]", filterType: "animes", onSeeAll: () => widget.onNavigate(3)),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class PaginatedCategoryView extends StatefulWidget {
  final String urlPattern; final String filterType; final String title;
  const PaginatedCategoryView({super.key, required this.urlPattern, required this.filterType, required this.title});
  @override State<PaginatedCategoryView> createState() => _PaginatedCategoryViewState();
}

class _PaginatedCategoryViewState extends State<PaginatedCategoryView> with AutomaticKeepAliveClientMixin {
  List items = []; bool loading = true; int page = 1;
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async {
    setState(() => loading = true);
    var newItems = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", page.toString()), filterType: widget.filterType);
    if(mounted) setState(() { items = newItems; loading = false; });
  }
  void _changePage(int direction) { if (page + direction > 0) { setState(() { page += direction; items.clear(); }); _fetch(); } }

  @override Widget build(BuildContext context) {
    super.build(context);
    if (loading && items.isEmpty) return _buildGridSkeleton();
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildCategoryHeader(widget.title)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
            delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: items[i]), childCount: items.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]), 
                  onPressed: page > 1 ? () => _changePage(-1) : null, 
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14), 
                  label: const Text("Anterior", style: TextStyle(color: Colors.white))
                ),
                Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), 
                  onPressed: items.length >= 10 ? () => _changePage(1) : null, 
                  icon: const Text("Próxima", style: TextStyle(color: Colors.white)), 
                  label: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14)
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class GenerosView extends StatelessWidget {
  const GenerosView({super.key});
  @override Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader("Gêneros"),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: officialGenres.length,
            itemBuilder: (context, index) {
              var genero = officialGenres[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => GridScreen(title: genero['nome']!, urlPattern: "$smartPlayUrl/genre/${genero['slug']}/[PAGE]"))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(imageUrl: genero['img']!, fit: BoxFit.cover),
                      Container(color: Colors.black.withOpacity(0.5)),
                      Center(child: Text(genero['nome']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
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

class SectionWidget extends StatefulWidget {
  final String title; final String urlPattern; final String? filterType; final VoidCallback? onSeeAll;
  const SectionWidget({super.key, required this.title, required this.urlPattern, this.filterType, this.onSeeAll});
  @override State<SectionWidget> createState() => _SectionWidgetState();
}
class _SectionWidgetState extends State<SectionWidget> {
  List items = []; bool loading = true;
  @override void initState() { super.initState(); _fetchData(); }
  void _fetchData() async { 
    List res = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", "1"), filterType: widget.filterType); 
    if (mounted) setState(() { items = res; loading = false; }); 
  }
  @override Widget build(BuildContext context) {
    if (loading) { 
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
            child: Shimmer.fromColors(
              baseColor: Colors.grey[900]!, 
              highlightColor: Colors.grey[800]!, 
              child: Container(height: 20, width: 100, color: Colors.black)
            )
          ), 
          _buildHorizontalSkeleton()
        ]
      ); 
    }
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), 
                  Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                ]
              ),
              GestureDetector(
                onTap: widget.onSeeAll ?? () => Navigator.push(context, MaterialPageRoute(builder: (c) => GridScreen(title: widget.title, urlPattern: widget.urlPattern, filterType: widget.filterType))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                  decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(4)), 
                  child: const Text("VER MAIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, 
            padding: const EdgeInsets.symmetric(horizontal: 10), 
            itemCount: items.length, 
            itemBuilder: (c, i) => Container(width: 105, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: items[i]))
          ),
        ),
      ],
    );
  }
}

class GridScreen extends StatefulWidget {
  final String title; final String urlPattern; final String? filterType;
  const GridScreen({super.key, required this.title, required this.urlPattern, this.filterType});
  @override State<GridScreen> createState() => _GridScreenState();
}
class _GridScreenState extends State<GridScreen> {
  List items = []; bool loading = true; int page = 1;
  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async {
    setState(() => loading = true);
    var newItems = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", page.toString()), filterType: widget.filterType);
    if(mounted) setState(() { items = newItems; loading = false; });
  }
  void _changePage(int direction) { if (page + direction > 0) { setState(() { page += direction; items.clear(); }); _fetch(); } }
  
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 28, letterSpacing: 1)), centerTitle: true),
      body: loading && items.isEmpty ? _buildGridSkeleton() : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildCategoryHeader(widget.title)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
              delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: items[i]), childCount: items.length)
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]), 
                    onPressed: page > 1 ? () => _changePage(-1) : null, 
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14), 
                    label: const Text("Anterior", style: TextStyle(color: Colors.white))
                  ),
                  Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), 
                    onPressed: items.length >= 10 ? () => _changePage(1) : null, 
                    icon: const Text("Próxima", style: TextStyle(color: Colors.white)), 
                    label: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14)
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query;
  const SearchResults({super.key, required this.query});
  
  Future<List> _smartSearch() async {
    String safeQuery = Uri.encodeComponent(query);
    var res = await fetchScraperData("$smartPlayUrl/search/1?search=$safeQuery");
    if (res.isEmpty && query.contains(RegExp(r'[^\w\s]'))) {
      String fallback1 = query.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      if (fallback1.isNotEmpty) res = await fetchScraperData("$smartPlayUrl/search/1?search=${Uri.encodeComponent(fallback1)}");
    }
    if (res.isEmpty && query.contains(" ")) {
      List<String> words = query.replaceAll(RegExp(r'[^\w\s]'), '').split(" ");
      words.removeWhere((w) => w.length <= 2); 
      if (words.isNotEmpty) {
        words.sort((a, b) => b.length.compareTo(a.length)); 
        String fallback2 = Uri.encodeComponent(words.first);
        res = await fetchScraperData("$smartPlayUrl/search/1?search=$fallback2");
      }
    }
    return res;
  }

  @override Widget build(BuildContext context) {
    return FutureBuilder(
      future: _smartSearch(),
      builder: (c, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) return _buildGridSkeleton();
        if (snapshot.data!.isEmpty) return const Center(child: Text("Nenhum resultado encontrado.", style: TextStyle(color: Colors.white)));
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildCategoryHeader("Resultados")),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
                delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: snapshot.data![i]), childCount: snapshot.data!.length)
              ),
            )
          ],
        );
      },
    );
  }
}

class PosterCard extends StatelessWidget {
  final dynamic item; const PosterCard({super.key, required this.item});
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: item))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: item['imagem'], fit: BoxFit.cover, width: double.infinity,
                placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[800]!, child: Container(color: Colors.black)),
                errorWidget: (c, u, e) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(item['titulo'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text("${item['tipo'].toString().toUpperCase()}", style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
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
  InAppWebViewController? webExtrator;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  Timer? _saveTimer;
  Timer? _adTimer;
  bool _rewardedLoaded = false;
  List<Map> _serversDisponiveis = [];

  bool isDataLoaded = false;
  String sinopse = "";
  String backdrop = "";
  List temporadas = []; List episodios = [];
  String? tempSelecionada; String epAtivoNome = "";
  List recomendacoes = [];
  
  bool isPlaying = false;
  bool isServerLoading = false;
  bool isSynopsisExpanded = false;
  bool _showControls = false;
  bool _isFullscreen = false;
  bool _isBuffering = false;
  Timer? _hideControlsTimer;
  int _extracaoStatus = 0;

  int savedPositionSeconds = 0;
  String? savedEpId;
  String? savedEpNome;
  bool _autoPlayDisparado = false;

  @override void initState() { 
    super.initState(); 
    _salvarHistoricoGeral(); 
    _fetchRecomendacoes(); 
    _checkResumeData();
  }

  @override void dispose() {
    _saveTimer?.cancel();
    _adTimer?.cancel();
    _hideControlsTimer?.cancel();
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _exitFullscreen();
    super.dispose();
  }

  void _enterFullscreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) setState(() => _isFullscreen = false);
  }

  void _checkResumeData() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString("resume_${widget.item['id']}");
    if (data != null) {
      var map = json.decode(data);
      savedPositionSeconds = map['position'] ?? 0;
      savedEpId = map['ep_id'];
      savedEpNome = map['ep_nome'];
    }
  }

  void _iniciarSalvamentoContinuo() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_videoPlayerController != null) {
        final pos = _videoPlayerController!.value.position;
        if (pos.inSeconds > 0) {
          final prefs = await SharedPreferences.getInstance();
          Map<String, dynamic> data = {"position": pos.inSeconds, "ep_id": savedEpId, "ep_nome": epAtivoNome};
          prefs.setString("resume_${widget.item['id']}", json.encode(data));
        }
      }
    });
  }

  void _fetchRecomendacoes() async {
    var res = await fetchScraperData("$smartPlayUrl/posts/${widget.item['tipo']}/1", filterType: widget.item['tipo']);
    if(mounted) setState(() { recomendacoes = res.where((e) => e['id'] != widget.item['id']).take(6).toList(); });
  }

  void _onExtratorLoaded() async {
    if (isDataLoaded && _extracaoStatus == 0) return;
    if (isDataLoaded && _extracaoStatus == 0) return; // já carregado, ignora
    if (webExtrator == null) return;
    try {
      if (_extracaoStatus == 0) {
        var dadosJs = await webExtrator!.evaluateJavascript(source: """
          (function() {
            var data = {sinopse: "Sinopse não disponível", backdrop: ""};
            var syn = document.querySelector('.synopsis'); if(syn) data.sinopse = syn.innerText;
            var bg = document.querySelector('.backdrop img'); if(bg) data.backdrop = bg.src;
            return JSON.stringify(data);
          })();
        """);
        if (dadosJs != null && mounted) {
          var d = json.decode(dadosJs.toString());
          sinopse = cleanTitle(d['sinopse']); backdrop = d['backdrop'] ?? widget.item['imagem'];
        }

        if (widget.item['tipo'] == 'filmes') {
           setState(() { isDataLoaded = true; }); 
           return;
        }

        var seasonsRes = await webExtrator!.evaluateJavascript(source: "window.CookieManager ? window.CookieManager.get('seasons_${widget.item['id']}') : null");
        if (seasonsRes != null && seasonsRes.toString().isNotEmpty && seasonsRes.toString() != "null") {
          List sList = json.decode(seasonsRes.toString());
          List temp = [];
          for (int i = 0; i < sList.length; i++) {
            String id = sList[i]['ID']?.toString() ?? sList[i]['id']?.toString() ?? "";
            String nome = sList[i]['nome']?.toString() ?? sList[i]['name']?.toString() ?? "Temporada ${i + 1}";
            if (id.isNotEmpty) temp.add({"id": id, "nome": cleanTitle(nome)});
          }
          if (temp.isNotEmpty && mounted) {
            setState(() { temporadas = temp; tempSelecionada = temp[0]['id']; });
            _carregarEpisodiosUrl(temp[0]['id']); 
            return;
          }
        }
        _extrairEpisodiosDiretos();
      } 
      else if (_extracaoStatus == 1) {
        _extrairEpisodiosDiretos();
      }
    } catch (e) { setState(() => isDataLoaded = true); } 
  }

  void _carregarEpisodiosUrl(String seasonId) {
    _extracaoStatus = 1;
    webExtrator?.loadUrl(urlRequest: URLRequest(url: WebUri("$smartPlayUrl/season/$seasonId/episodes")));
  }

  void _extrairEpisodiosDiretos() async {
    try {
      var epsRes = await webExtrator!.evaluateJavascript(source: """
        (function(){
          var eps = []; var imgs = document.querySelectorAll("img[onclick*='loadEpisodePlayers']");
          for(var i=0; i<imgs.length; i++) {
            var m = imgs[i].getAttribute('onclick').match(/loadEpisodePlayers\\('(\\d+)'/);
            if(m) eps.push({id: m[1], full_nome: imgs[i].getAttribute('alt')});
          } return JSON.stringify(eps);
        })();
      """);
      if (epsRes != null && mounted) {
        List eList = json.decode(epsRes.toString());
        setState(() {
          episodios = eList.map((e) {
            String fullNome = cleanTitle(e['full_nome'].toString());
            var nums = RegExp(r'\d+').allMatches(fullNome);
            String numFormatado = nums.isNotEmpty ? nums.last.group(0)! : "▶"; 
            return {"id": e['id'].toString(), "full_nome": fullNome, "num": numFormatado};
          }).toList();
        });

        setState(() { isDataLoaded = true; }); 

        if (!_autoPlayDisparado && savedEpId != null && savedEpId!.isNotEmpty) {
          _autoPlayDisparado = true;
          _abrirServidores(savedEpId!, savedEpNome ?? "Episódio", false);
        }
      }
    } catch (e) { setState(() => isDataLoaded = true); }
  }

  Future<void> _abrirServidores(String idVideo, String nomeVideo, bool isParaDownload) async {
    if (savedEpId != null && savedEpId != idVideo) {
      savedPositionSeconds = 0;
    }

    if (!isParaDownload) {
      setState(() { isPlaying = true; isServerLoading = true; epAtivoNome = nomeVideo; savedEpId = idVideo; });
    }

    String urlApi = widget.item['tipo'] == 'filmes' ? "$smartPlayUrl/player/movie" : "$smartPlayUrl/player/episode";
    Map payload = widget.item['tipo'] == 'filmes' ? {"movie_id": idVideo, "action_type": "PLAY"} : {"ep_id": idVideo, "action_type": "PLAY"};

    try {
      final res = await http.post(Uri.parse(urlApi), headers: {"User-Agent": "Mozilla/5.0", "Content-Type": "application/json", "Referer": smartPlayUrl}, body: json.encode(payload));
      var data = json.decode(res.body);
      
      if (data['success'] == true && data['players'] != null) {
        List players = data['players'];
        if (players.isEmpty) { 
          if (!isParaDownload) setState(() { isServerLoading = false; isPlaying = false; }); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Servidores indisponíveis."))); 
          return; 
        }
        
        List<Map> servers = players.map((p) {
          String url = p["file"].toString().replaceAll("&amp;", "&");
          String tipo = p["type"]?.toString() ?? "Video";
          String name = cleanTitle((p["title"] ?? "").toString());
          String idioma = name;
          if (idioma.isEmpty || idioma.toLowerCase() == "video") {
            if (url.toLowerCase().contains("/dub/")) idioma = "Dublado";
            else if (url.toLowerCase().contains("/leg/")) idioma = "Legendado";
            else idioma = "Opção";
          }
          return {"url": url, "tipo": tipo, "idioma": idioma, "isMp4": tipo.toUpperCase().contains("MP4")};
        }).toList();

        _serversDisponiveis = servers;

        // Verifica se tem dublado E legendado — se sim, oferece escolha
        final temDublado = servers.any((s) => s['idioma'].toString().toLowerCase().contains('dublado'));
        final temLegendado = servers.any((s) => s['idioma'].toString().toLowerCase().contains('legendado'));

        if (!isParaDownload && temDublado && temLegendado) {
          // Mostra seletor de idioma
          _mostrarSeletorIdioma(servers, nomeVideo);
          return;
        }

        // Selecção automática de servidor
        Map? serverEscolhido = servers.cast<Map?>().firstWhere((s) => s!['isMp4'] == true && s['idioma'].toString().toLowerCase().contains('dublado'), orElse: () => null);
        serverEscolhido ??= servers.cast<Map?>().firstWhere((s) => s!['isMp4'] == true, orElse: () => null);
        serverEscolhido ??= servers.cast<Map?>().firstWhere((s) => s!['idioma'].toString().toLowerCase().contains('dublado'), orElse: () => null);
        serverEscolhido ??= servers.first;

        if (serverEscolhido == null) return;

        if (isParaDownload) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Row(children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
              SizedBox(width: 12),
              Text("A preparar download...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
            backgroundColor: const Color(0xFFE50914),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
          _mostrarUnityInterstitial(
            onComplete: () {
              DownloadManager.startDownload(
                serverEscolhido!['url'], nomeVideo, serverEscolhido['isMp4']);
            },
          );
        } else {
          _iniciarExoPlayerComFallback(servers, serverEscolhido, nomeVideo);
        }
      }
    } catch (e) { 
      if (!isParaDownload) setState(() { isServerLoading = false; isPlaying = false; });
    }
  }

  void _mostrarSeletorIdioma(List<Map> servers, String nomeVideo) {
    final dublado = servers.firstWhere((s) => s['idioma'].toString().toLowerCase().contains('dublado') && s['isMp4'] == true,
        orElse: () => servers.firstWhere((s) => s['idioma'].toString().toLowerCase().contains('dublado'), orElse: () => servers.first));
    final legendado = servers.firstWhere((s) => s['idioma'].toString().toLowerCase().contains('legendado') && s['isMp4'] == true,
        orElse: () => servers.firstWhere((s) => s['idioma'].toString().toLowerCase().contains('legendado'), orElse: () => servers.first));

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text("Selecionar idioma", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            _idiomaBtn(ctx, "🎙️ Dublado", const Color(0xFFE50914), () => _iniciarExoPlayerComFallback(servers, dublado, nomeVideo)),
            const SizedBox(height: 10),
            _idiomaBtn(ctx, "💬 Legendado", Colors.white12, () => _iniciarExoPlayerComFallback(servers, legendado, nomeVideo)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _idiomaBtn(BuildContext ctx, String label, Color cor, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: cor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () { Navigator.pop(ctx); onTap(); },
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    );
  }

  Future<void> _iniciarExoPlayerComFallback(List<Map> servers, Map serverPrincipal, String nomeVideo) async {
    // Tenta o servidor principal com timeout
    try {
      final ctrl = VideoPlayerController.networkUrl(
        Uri.parse(serverPrincipal['url']),
        httpHeaders: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"},
      );
      await ctrl.initialize().timeout(const Duration(seconds: 12));
      await _iniciarExoPlayer(serverPrincipal['url'], nomeVideo, controllerPreinit: ctrl);
      return;
    } catch (_) {}

    // Fallback para outros servidores
    final outrosServers = servers.where((s) => s['url'] != serverPrincipal['url']).toList();
    for (final s in outrosServers) {
      try {
        final ctrl = VideoPlayerController.networkUrl(
          Uri.parse(s['url']),
          httpHeaders: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"},
        );
        await ctrl.initialize().timeout(const Duration(seconds: 12));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Servidor alternativo carregado"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ));
        }
        await _iniciarExoPlayer(s['url'], nomeVideo, controllerPreinit: ctrl);
        return;
      } catch (_) {}
    }

    // Todos falharam
    if (mounted) {
      setState(() { isServerLoading = false; isPlaying = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhum servidor disponível."), backgroundColor: Colors.red));
    }
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _mostrarUnityInterstitial({required VoidCallback onComplete}) {
    UnityAds.load(
      placementId: _unityInterstitialId,
      onComplete: (id) {
        UnityAds.showVideoAd(
          placementId: _unityInterstitialId,
          onComplete: (id) => onComplete(),
          onFailed: (id, error, msg) => onComplete(),
          onSkipped: (id) => onComplete(),
        );
      },
      onFailed: (id, error, msg) => onComplete(),
    );
  }

  void _mostrarRewardedPopup() {
    if (_isFullscreen) _exitFullscreen();
    _videoPlayerController?.pause();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RewardedPopup(
        onVerAnuncio: () {
          Navigator.pop(ctx);
          // Usa o já carregado, ou carrega agora se necessário
          if (_rewardedLoaded) {
            UnityAds.showVideoAd(
              placementId: _unityRewardedId,
              onComplete: (id) { _rewardedLoaded = false; if (mounted) _videoPlayerController?.play(); },
              onFailed: (id, error, msg) { if (mounted) _videoPlayerController?.play(); },
              onSkipped: (id) { if (mounted) _videoPlayerController?.play(); },
            );
          } else {
            UnityAds.load(
              placementId: _unityRewardedId,
              onComplete: (id) {
                UnityAds.showVideoAd(
                  placementId: _unityRewardedId,
                  onComplete: (id) { _rewardedLoaded = false; if (mounted) _videoPlayerController?.play(); },
                  onFailed: (id, error, msg) { if (mounted) _videoPlayerController?.play(); },
                  onSkipped: (id) { if (mounted) _videoPlayerController?.play(); },
                );
              },
              onFailed: (id, error, msg) { if (mounted) _videoPlayerController?.play(); },
            );
          }
        },
        onAguardar: () {
          Navigator.pop(ctx);
          if (mounted) _videoPlayerController?.play();
        },
      ),
    );
  }

  void _iniciarExoPlayer(String url, String tituloEpisodio, {VideoPlayerController? controllerPreinit}) async {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    setState(() { _showControls = false; _isBuffering = false; });

    _videoPlayerController = controllerPreinit ?? VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"},
    );

    if (controllerPreinit == null) {
      await _videoPlayerController!.initialize();
    }

    if (savedPositionSeconds > 0) {
      await _videoPlayerController!.seekTo(Duration(seconds: savedPositionSeconds));
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFFE50914),
        handleColor: const Color(0xFFE50914),
        bufferedColor: Colors.white38,
        backgroundColor: Colors.white24,
      ),
      placeholder: Container(color: Colors.black),
      errorBuilder: (ctx, msg) => Center(child: Text(msg, style: const TextStyle(color: Colors.white))),
    );

    _videoPlayerController!.addListener(() {
      if (!mounted) return;
      final val = _videoPlayerController!.value;
      final buf = val.isBuffering;
      if (buf != _isBuffering) setState(() => _isBuffering = buf);
    });

    if (mounted) setState(() { isServerLoading = false; });

    _iniciarSalvamentoContinuo();

    // Pré-carrega o Rewarded antecipadamente
    _rewardedLoaded = false;
    UnityAds.load(
      placementId: _unityRewardedId,
      onComplete: (id) { if (mounted) setState(() => _rewardedLoaded = true); },
      onFailed: (id, error, msg) {},
    );

    // Mostra popup Rewarded a cada 3 minutos — espera carregar até 10s
    _adTimer?.cancel();
    _adTimer = Timer(const Duration(minutes: 3), () async {
      if (!mounted) return;
      // Se ainda não carregou, aguarda até 10s
      if (!_rewardedLoaded) {
        for (int i = 0; i < 10; i++) {
          await Future.delayed(const Duration(seconds: 1));
          if (_rewardedLoaded || !mounted) break;
        }
      }
      if (mounted) _mostrarRewardedPopup();
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _salvarHistoricoGeral() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hist = prefs.getStringList('history') ?? [];
    Map<String, dynamic> it = {'id': widget.item['id'], 'title': widget.item['titulo'], 'type': widget.item['tipo'], 'poster_path': widget.item['imagem']};
    hist.removeWhere((e) => json.decode(e)['id'] == widget.item['id']);
    hist.insert(0, json.encode(it));
    await prefs.setStringList('history', hist);
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

  Widget _buildPlayerArea() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fundo quando não reproduz
        if (!isPlaying || isServerLoading) ...[
          CachedNetworkImage(imageUrl: backdrop.isNotEmpty ? backdrop : widget.item['imagem'], fit: BoxFit.cover, alignment: Alignment.topCenter),
          Container(color: Colors.black.withOpacity(0.6)),
        ],

        // Player Chewie profissional
        if (isPlaying && !isServerLoading && _chewieController != null)
          Chewie(controller: _chewieController!),

        // Loading servidor
        if (isPlaying && isServerLoading)
          Container(color: Colors.black, child: const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))),

        // Buffering por cima do Chewie
        if (isPlaying && !isServerLoading && _isBuffering)
          const Center(child: SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: Color(0xFFE50914), strokeWidth: 3))),

        // Não está a reproduzir
        if (!isPlaying && widget.item['tipo'] == 'filmes')
          Center(child: IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 70), onPressed: () => _abrirServidores(widget.item['id'], widget.item['titulo'], false))),
        if (!isPlaying && widget.item['tipo'] != 'filmes')
          const Center(child: Text("Selecione um episódio abaixo", style: TextStyle(color: Colors.white, fontSize: 16))),

        // Botão voltar SEMPRE visível no topo esquerdo + cast no topo direito
        Positioned(
          top: 8, left: 4,
          child: SafeArea(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20, shadows: [Shadow(color: Colors.black, blurRadius: 8)]),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        if (isPlaying && !isServerLoading)
          Positioned(
            top: 8, right: 4,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.cast, color: Colors.white, size: 22, shadows: [Shadow(color: Colors.black, blurRadius: 8)]),
                tooltip: "Transmitir para TV",
                onPressed: () async {
                  // Abre configurações nativas de cast do Android
                  try {
                    await SystemChannels.platform.invokeMethod('SystemNavigator.routeUpdated');
                  } catch (_) {}
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Ativa o Cast no menu de notificações do teu Android ou usa um Chromecast"),
                      backgroundColor: Color(0xFF1C1C1C),
                      duration: Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
              ),
            ),
          ),
      ],
    );
  }

  @override Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isFullscreen) { _exitFullscreen(); return false; }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F13),
        body: Stack(
          children: [
            // Layout normal — sempre no tree, escondido em fullscreen
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  color: Colors.black,
                  child: AspectRatio(aspectRatio: 16 / 9, child: _buildPlayerArea()),
                ),
                // InAppWebView SEMPRE no tree (nunca destruído)
                SizedBox(height: 1, width: 1, child: InAppWebView(
                  initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
                  initialUrlRequest: URLRequest(url: WebUri("$smartPlayUrl/posts/${widget.item['tipo']}/post/${widget.item['id']}")),
                  onWebViewCreated: (c) => webExtrator = c,
                  onLoadStop: (c, u) { _onExtratorLoaded(); },
                )),
                Expanded(
                  child: !isDataLoaded
                    ? _buildPlayerSkeleton()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(child: Text(cleanTitle(widget.item['titulo']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                              if (widget.item['tipo'] == 'filmes')
                                GestureDetector(
                                  onTap: () => _abrirServidores(widget.item['id'], widget.item['titulo'], true),
                                  child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)), child: const Row(children: [Icon(Icons.download, color: Colors.white, size: 16), SizedBox(width: 5), Text("BAIXAR", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))])),
                                )
                            ]),
                            const SizedBox(height: 10),
                            Text("${widget.item['tipo'].toString().toUpperCase()}", style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () => setState(() => isSynopsisExpanded = !isSynopsisExpanded),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(sinopse, maxLines: isSynopsisExpanded ? null : 3, overflow: isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                                if (sinopse.length > 150)
                                  Padding(padding: const EdgeInsets.only(top: 5), child: Text(isSynopsisExpanded ? "Mostrar menos" : "Ver mais...", style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12)))
                              ]),
                            ),
                            const SizedBox(height: 20),
                            if (widget.item['tipo'] != 'filmes' && temporadas.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                                child: DropdownButtonHideUnderline(child: DropdownButton<String>(dropdownColor: Colors.grey[900], value: tempSelecionada, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['nome']))).toList(), onChanged: (val) { if (val != null) { setState(() { tempSelecionada = val; episodios.clear(); _extracaoStatus = 1; isDataLoaded = false; }); _carregarEpisodiosUrl(val); } })),
                              ),
                              const SizedBox(height: 10),
                            ],
                            if (widget.item['tipo'] != 'filmes') ...[
                              if (episodios.isEmpty)
                                SizedBox(height: 45, child: ListView.builder(itemCount: 5, scrollDirection: Axis.horizontal, itemBuilder: (c,i) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[700]!, child: Container(width: 45, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6))))))
                              else
                                SizedBox(
                                  height: 45,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal, itemCount: episodios.length,
                                    itemBuilder: (ctx, i) {
                                      var ep = episodios[i]; bool isAtivo = epAtivoNome == "${widget.item['titulo']} - ${ep['full_nome']}";
                                      return GestureDetector(
                                        onTap: () => _abrirServidores(ep['id'], "${widget.item['titulo']} - ${ep['full_nome']}", false),
                                        onLongPress: () => _abrirServidores(ep['id'], "${widget.item['titulo']} - ${ep['full_nome']}", true),
                                        child: Container(width: 45, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: isAtivo ? const Color(0xFFE50914) : const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), border: Border.all(color: isAtivo ? Colors.transparent : Colors.white12)), child: Center(child: isAtivo ? const Icon(Icons.play_arrow, color: Colors.white, size: 20) : Text(ep['num'], style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.bold)))),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.withOpacity(0.3))), child: const Row(children: [Icon(Icons.info_outline, color: Colors.blue, size: 16), SizedBox(width: 8), Expanded(child: Text("Dica: Pressione e segure o episódio para transferir..", style: TextStyle(color: Colors.blue, fontSize: 11)))])),
                            ],
                            if (recomendacoes.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Row(children: [Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), const Text("Recomendações", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
                              const SizedBox(height: 10),
                              SizedBox(height: 160, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: recomendacoes.length, itemBuilder: (ctx, i) { var rec = recomendacoes[i]; return GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PlayerScreen(item: rec))), child: Container(width: 105, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: rec))); }))
                            ]
                          ],
                        ),
                      ),
                ),
              ],
            ),

            // Tela cheia — cobre tudo por cima sem destruir o layout de baixo
            if (_isFullscreen)
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: _buildPlayerArea(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class HistoryScreen extends StatefulWidget { const HistoryScreen({super.key}); @override State<HistoryScreen> createState() => _HistoryScreenState(); }
class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];
  @override void initState() { super.initState(); carregar(); }
  void carregar() async { final prefs = await SharedPreferences.getInstance(); setState(() => history = (prefs.getStringList('history') ?? []).map((e) => json.decode(e) as Map<String, dynamic>).toList()); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico")),
      body: history.isEmpty ? const Center(child: Text("Ainda não assistiu a nada.", style: TextStyle(color: Colors.grey))) : ListView.builder(itemCount: history.length, itemBuilder: (c, i) {
        var item = history[i];
        return ListTile(
          leading: CachedNetworkImage(imageUrl: item['poster_path'], width: 50, fit: BoxFit.cover),
          title: Text(cleanTitle(item['title']), style: const TextStyle(color: Colors.white)), subtitle: Text(item['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.grey)), trailing: const Icon(Icons.play_arrow, color: Colors.red),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: {'id': item['id'], 'titulo': item['title'], 'tipo': item['type'], 'imagem': item['poster_path']}))),
        );
      }),
    );
  }
}

class DownloadsScreen extends StatefulWidget { const DownloadsScreen({super.key}); @override State<DownloadsScreen> createState() => _DownloadsScreenState(); }
class _DownloadsScreenState extends State<DownloadsScreen> {
  List<String> files = [];
  @override void initState() { super.initState(); carregar(); }
  void carregar() async { final prefs = await SharedPreferences.getInstance(); setState(() => files = prefs.getStringList('downloads') ?? []); }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("As Minhas Transferências")),
      body: Column(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: DownloadManager.progress,
            builder: (context, progress, child) {
              if (progress >= 0.0 && progress <= 1.0) {
                return Card(
                  color: Colors.grey[900], margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: CircularProgressIndicator(value: progress, color: const Color(0xFFE50914)),
                    title: Text(DownloadManager.currentTitle, style: const TextStyle(color: Colors.white)),
                    subtitle: Text("A transferir: ${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.greenAccent)),
                    trailing: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), tooltip: "Cancelar", onPressed: () => DownloadManager.confirmCancelDownload(context)),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: files.isEmpty 
              ? const Center(child: Text("Nenhuma transferência concluída.", style: TextStyle(color: Colors.grey))) 
              : ListView.builder(itemCount: files.length, itemBuilder: (c, i) {
                  String name = files[i].split('/').last.replaceAll('CDCINE_', '');
                  return ListTile(
                    leading: const Icon(Icons.video_file, color: Colors.greenAccent, size: 40), 
                    title: Text(name, style: const TextStyle(color: Colors.white)), 
                    subtitle: const Text("Guardado na Galeria - Clique para ver"), 
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final prefs = await SharedPreferences.getInstance(); files.removeAt(i); prefs.setStringList('downloads', files); setState(() {}); }),
                    onTap: () { OpenFilex.open(files[i]); },
                  );
                }),
          ),
        ],
      )
    );
  }
}

// ==========================================
// POPUP REWARDED
// ==========================================
class _RewardedPopup extends StatefulWidget {
  final VoidCallback onVerAnuncio;
  final VoidCallback onAguardar;
  const _RewardedPopup({required this.onVerAnuncio, required this.onAguardar});
  @override State<_RewardedPopup> createState() => _RewardedPopupState();
}

class _RewardedPopupState extends State<_RewardedPopup> {
  int _countdown = 30;
  bool _aguardando = false;
  Timer? _timer;

  @override void dispose() { _timer?.cancel(); super.dispose(); }

  void _iniciarContagem() {
    setState(() { _aguardando = true; _countdown = 30; });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) { t.cancel(); widget.onAguardar(); }
    });
  }

  @override Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 30)],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/pobre.jpg', height: 120, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.live_tv, color: Colors.white54, size: 72)),
            ),
            const SizedBox(height: 16),
            Text("Para continuar assistindo", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 22, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text(
              "Para manter o CDCINE gratuito,\npreciso da sua ajuda!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),

            // Opção 1 — Ver anúncio
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onVerAnuncio,
                icon: const Icon(Icons.play_circle_outline, color: Colors.white),
                label: const Text("Ver anúncio (~10 seg)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 10),

            // Opção 2 — Aguardar
            SizedBox(
              width: double.infinity,
              child: _aguardando
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: _countdown / 30, color: Colors.white54, strokeWidth: 2.5)),
                      const SizedBox(width: 12),
                      Text("Aguardando... $_countdown seg", style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ]),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white38),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _iniciarContagem,
                    icon: const Icon(Icons.timer_outlined, color: Colors.white60, size: 18),
                    label: const Text("Aguardar 30 segundos", style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class DmcaScreen extends StatelessWidget {
  const DmcaScreen({super.key});

  Widget _dmcaItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFFE50914).withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFE50914), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        title: const Text("DMCA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B0B0F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.shield, color: Color(0xFFE50914), size: 28),
              const SizedBox(width: 10),
              Text("Notificação de violação de\ndireitos autorais",
                style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 22, letterSpacing: 1),
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              "Para enviar uma notificação de violação de direitos autorais ao ChauThanh.INFO, você precisará realizar os seguintes passos: (consulte seu advogado ou a Seção 512(c)(3) da Lei de Direitos Autorais para confirmar esses requisitos)",
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 20),
            _dmcaItem(Icons.person_outline, "Informações sobre a pessoa/empresa que reivindica os direitos autorais."),
            _dmcaItem(Icons.link, "Envio da identificação do material protegido por direitos autorais, fornecendo os URLs correspondentes."),
            _dmcaItem(Icons.contact_mail_outlined, "Informações que nos permitam entrar em contato com a empresa/empresa em questão, como e-mail, número de telefone ou endereço físico."),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Todas as informações acima devem ser enviadas para:",
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => launchUrl(Uri.parse("mailto:cdcine@horsefucker.org?subject=DMCA%20Notice"), mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.email_outlined, color: Colors.white),
                      label: const Text("Enviar notificação DMCA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Quaisquer outros meios de envio não serão aceitos e não receberão resposta.",
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                "O conteúdo protegido por direitos autorais será analisado em até 24 horas e removido em até 48 horas.",
                style: TextStyle(color: Colors.blue, fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Text(
                "Observe também que, de acordo com a Seção 512(f), qualquer pessoa que, conscientemente, declare falsamente que um material ou atividade infringe direitos autorais poderá ser responsabilizada.",
                style: TextStyle(color: Colors.orange, fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}