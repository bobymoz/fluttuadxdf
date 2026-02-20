import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Configurações Globais
const String tmdbApiKey = '9c31b3aeb2e59aa2caf74c745ce15887';
const String currentAppVersion = "1.0.0";
const String telegramUrl = "https://t.me/cdcine";
const String smartPlayBaseUrl = "https://smartplaylite.xn--n8ja5190f.mba";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CDcineApp());
}

class CDcineApp extends StatelessWidget {
  const CDcineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDCINE PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0B),
        primaryColor: const Color(0xFFE50914),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B0B0B), elevation: 0),
      ),
      home: const MainScreen(),
    );
  }
}

// --- TELA PRINCIPAL ---
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDCINE PRO", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 32)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF0088cc)),
            onPressed: () => launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Buscar no Multiverso...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (value) => setState(() { searchQuery = value; isSearching = value.isNotEmpty; }),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFE50914),
                tabs: const [
                  Tab(text: "FILMES"), Tab(text: "SÉRIES"), Tab(text: "ANIMES"), Tab(text: "DORAMAS"),
                ],
              ),
            ],
          ),
        ),
      ),
      body: isSearching 
        ? SearchResults(query: searchQuery)
        : TabBarView(
            controller: _tabController,
            children: const [
              ContentPage(category: 'movie'),
              ContentPage(category: 'tv'),
              ContentPage(category: 'anime'),
              ContentPage(category: 'dorama'),
            ],
          ),
    );
  }
}

// --- PLAYER E GERENCIADOR DE CONTEÚDO (WEBVIEW + DOWNLOAD) ---
class SuperPlayer extends StatefulWidget {
  final int id;
  final String title;
  final String type;
  final String? posterPath;

  const SuperPlayer({super.key, required this.id, required this.title, required this.type, this.posterPath});

  @override
  State<SuperPlayer> createState() => _SuperPlayerState();
}

class _SuperPlayerState extends State<SuperPlayer> {
  InAppWebViewController? webViewController;
  bool _videoFound = false;
  String _downloadUrl = "";
  double _progress = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _salvarHistorico();
  }

  void _salvarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    Map<String, dynamic> item = {
      'id': widget.id, 'title': widget.title, 'type': widget.type, 'poster_path': widget.posterPath, 'date': DateTime.now().toIso8601String(),
    };
    history.removeWhere((element) => json.decode(element)['id'] == widget.id);
    history.insert(0, json.encode(item));
    await prefs.setStringList('history', history.sublist(0, history.length > 50 ? 50 : history.length));
  }

  // Lógica de Extração baseada na nova fonte 
  void _scannerDeVideo() async {
    if (_videoFound) return;
    try {
      var jsResult = await webViewController!.evaluateJavascript(source: "playerjsSubtitle");
      if (jsResult != null && jsResult.toString().contains("babilonica.top")) {
        String raw = jsResult.toString();
        RegExp reg = RegExp(r'(https?://[^,"]*babilonica[^,"]*\.vtt)');
        var match = reg.firstMatch(raw);
        if (match != null) {
          String base = match.group(1)!.replaceAll(r'\/', '/').split("/Subtitle/")[0];
          setState(() {
            _downloadUrl = "$base/video.mp4";
            _videoFound = true;
          });
        }
      }
    } catch (e) {}
  }

  Future<void> _startDownload() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    setState(() { _isDownloading = true; });
    try {
      final dir = Directory('/storage/emulated/0/Download');
      final path = "${dir.path}/${widget.title.replaceAll(RegExp(r'[^\w\s]+'), '')}.mp4";

      await Dio().download(
        _downloadUrl,
        path,
        options: Options(headers: {
          "Referer": "https://llanfairpwllgwyngy.com/", // Header Obrigatório
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        }),
        onReceiveProgress: (rec, total) {
          if (total != -1) setState(() { _progress = rec / total; });
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Download concluído com sucesso!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro no download: $e")));
    } finally {
      setState(() { _isDownloading = false; _progress = 0; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fluxo da nova fonte
    String finalUrl = widget.type == 'filme' 
        ? "https://superflixapi.one/filme/${widget.id}" 
        : "https://superflixapi.one/serie/${widget.id}/1/1";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_videoFound)
            IconButton(
              icon: const Icon(Icons.download, color: Colors.greenAccent),
              onPressed: _startDownload,
            ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              userAgent: "Mozilla/5.0 (Linux; Android 10; SM-G960F) AppleWebKit/537.36",
            ),
            onWebViewCreated: (ctrl) => webViewController = ctrl,
            onLoadStop: (ctrl, url) {
              Timer.periodic(const Duration(seconds: 3), (t) {
                if (_videoFound) t.cancel();
                _scannerDeVideo();
              });
            },
            initialUrlRequest: URLRequest(url: WebUri(finalUrl)),
          ),
          if (_isDownloading)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(value: _progress, color: Colors.red),
                    const SizedBox(height: 10),
                    Text("${(_progress * 100).toStringAsFixed(0)}% Baixando..."),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- COMPONENTES AUXILIARES (TMDB) ---
class ContentPage extends StatefulWidget {
  final String category;
  const ContentPage({super.key, required this.category});
  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  List trending = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  _fetch() async {
    String url = "https://api.themoviedb.org/3/trending/${widget.category == 'movie' ? 'movie' : 'tv'}/day?api_key=$tmdbApiKey&language=pt-BR";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() { trending = json.decode(res.body)['results']; loading = false; });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return ListView.builder(
      itemCount: trending.length,
      itemBuilder: (context, index) {
        final item = trending[index];
        return ListTile(
          leading: CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w92${item['poster_path']}"),
          title: Text(item['title'] ?? item['name']),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(
            id: item['id'], title: item['title'] ?? item['name'], 
            type: widget.category == 'movie' ? 'filme' : 'serie', posterPath: item['poster_path']
          ))),
        );
      },
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query;
  const SearchResults({super.key, required this.query});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Buscando por: $query..."));
  }
}
