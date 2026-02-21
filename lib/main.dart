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
import 'package:permission_handler/permission_handler.dart';

const String tmdbApiKey = '9c31b3aeb2e59aa2caf74c745ce15887'; 
const String telegramUrl = "https://t.me/cdcine";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CDcineApp());
}

class CDcineApp extends StatelessWidget {
  const CDcineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDCINE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFE50914),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// ==========================================
// TELA INICIAL (MENU E ABAS)
// ==========================================
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
        title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 36, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen())),
        ),
        actions: [
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchQuery = "";
                  _searchController.clear();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF0088cc)),
            onPressed: () => launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(130),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Pesquisar Filmes e Séries...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
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

// ==========================================
// SUPER PLAYER PROFISSIONAL (O CORAÇÃO DO APP)
// ==========================================
class SuperPlayer extends StatefulWidget {
  final int id;
  final String title;
  final String type; // 'filme' ou 'serie'
  final String? posterPath;

  const SuperPlayer({super.key, required this.id, required this.title, required this.type, this.posterPath});

  @override
  State<SuperPlayer> createState() => _SuperPlayerState();
}

class _SuperPlayerState extends State<SuperPlayer> {
  InAppWebViewController? webViewController;
  Timer? _snifferTimer;

  // Dados do TMDB
  String description = "Carregando informações...";
  double rating = 0.0;
  List seasons = [];
  List episodes = [];
  int selectedSeason = 1;
  int selectedEpisode = 1;
  
  // Controle de Player e Download
  String _currentVideoUrl = "";
  String _capturedDownloadUrl = "";
  bool _videoReadyToDownload = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _salvarHistorico();
    _gerarLinkDoPlayer();
    _fetchDetailsTMDB();

    // Inicia o farejador que tenta capturar o MP4 da WebView a cada 3 segundos
    _snifferTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_videoReadyToDownload && webViewController != null) {
        _tentarCapturarMp4();
      }
    });
  }

  @override
  void dispose() {
    _snifferTimer?.cancel();
    super.dispose();
  }

  // 1. GERA O LINK DO PLAYER (InAppWebView)
  void _gerarLinkDoPlayer() {
    setState(() {
      _videoReadyToDownload = false;
      _capturedDownloadUrl = "";
      if (widget.type == 'filme') {
        _currentVideoUrl = "https://superflixapi.one/filme/${widget.id}";
      } else {
        _currentVideoUrl = "https://superflixapi.one/serie/${widget.id}/$selectedSeason/$selectedEpisode";
      }
    });
    // Atualiza a WebView se ela já estiver construída
    webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(_currentVideoUrl)));
  }

  // 2. BUSCA DETALHES, NOTA E TEMPORADAS (TMDB API)
  Future<void> _fetchDetailsTMDB() async {
    String typeUrl = widget.type == 'filme' ? 'movie' : 'tv';
    final url = "https://api.themoviedb.org/3/$typeUrl/${widget.id}?api_key=$tmdbApiKey&language=pt-BR";
    
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          description = data['overview'] != null && data['overview'].isNotEmpty ? data['overview'] : "Nenhuma sinopse disponível.";
          rating = (data['vote_average'] ?? 0).toDouble();
          
          if (widget.type == 'serie' || widget.type == 'anime' || widget.type == 'dorama') {
            seasons = data['seasons'] ?? [];
            seasons.removeWhere((s) => s['season_number'] == 0); // Remove especiais
            if (seasons.isNotEmpty) {
              selectedSeason = seasons[0]['season_number'];
              _fetchEpisodesTMDB(selectedSeason);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Erro TMDB: $e");
    }
  }

  Future<void> _fetchEpisodesTMDB(int seasonNumber) async {
    setState(() { selectedSeason = seasonNumber; episodes = []; });
    final url = "https://api.themoviedb.org/3/tv/${widget.id}/season/$seasonNumber?api_key=$tmdbApiKey&language=pt-BR";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() {
          episodes = json.decode(res.body)['episodes'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Erro Episódios: $e");
    }
  }

  // 3. CAPTURADOR DE VÍDEO E DOWNLOADER
  void _tentarCapturarMp4() async {
    try {
      var result = await webViewController!.evaluateJavascript(source: """
        (function() {
          if (typeof playerjsSubtitle !== 'undefined') return playerjsSubtitle;
          return null;
        })();
      """);

      if (result != null && result.toString().contains("babilonica")) {
        RegExp regExp = RegExp(r'(https?://[^,"]*babilonica[^,"]*\.vtt)');
        var match = regExp.firstMatch(result.toString());
        if (match != null) {
          String linkLegenda = match.group(1)!.replaceAll(r'\/', '/');
          String linkVideo = linkLegenda.split("/Subtitle/")[0] + "/video.mp4";
          
          if (mounted) {
            setState(() {
              _capturedDownloadUrl = linkVideo;
              _videoReadyToDownload = true;
            });
          }
        }
      }
    } catch (e) {}
  }

  Future<void> _iniciarDownload() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    setState(() { _isDownloading = true; _downloadProgress = 0; });

    try {
      final dir = Directory('/storage/emulated/0/Download');
      String safeTitle = widget.title.replaceAll(RegExp(r'[^\w\s]+'), '');
      String epSuffix = widget.type == 'filme' ? '' : '_S${selectedSeason}E$selectedEpisode';
      final savePath = "${dir.path}/$safeTitle$epSuffix.mp4";

      await Dio().download(
        _capturedDownloadUrl,
        savePath,
        options: Options(headers: {
          "Referer": "https://llanfairpwllgwyngy.com/", // Header para burlar o 403
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0",
        }),
        onReceiveProgress: (recebido, total) {
          if (total != -1) setState(() => _downloadProgress = recebido / total);
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download salvo em: $savePath"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro no Download: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() { _isDownloading = false; });
    }
  }

  void _salvarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    Map<String, dynamic> item = { 'id': widget.id, 'title': widget.title, 'type': widget.type, 'poster_path': widget.posterPath, 'date': DateTime.now().toIso8601String() };
    history.removeWhere((element) => json.decode(element)['id'] == widget.id);
    history.insert(0, json.encode(item));
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          // ÁREA DO PLAYER (16:9)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                InAppWebView(
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15",
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                  ),
                  initialUrlRequest: URLRequest(url: WebUri(_currentVideoUrl)),
                  onWebViewCreated: (ctrl) => webViewController = ctrl,
                  shouldOverrideUrlLoading: (ctrl, nav) async {
                    if (nav.request.url.toString().contains('superflix') || nav.request.url.toString().contains('llanfair') || nav.request.url.toString().contains('brbeast')) {
                      return NavigationActionPolicy.ALLOW;
                    }
                    return NavigationActionPolicy.CANCEL; // Bloqueia anúncios
                  },
                ),
                if (_isDownloading)
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(value: _downloadProgress, color: const Color(0xFFE50914)),
                          const SizedBox(height: 10),
                          Text("Baixando: ${(_downloadProgress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // ÁREA DE INFORMAÇÕES E EPISÓDIOS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título, Nota e Botão de Download
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 5),
                                Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 16, color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_videoReadyToDownload)
                        FloatingActionButton.extended(
                          onPressed: _isDownloading ? null : _iniciarDownload,
                          backgroundColor: const Color(0xFFE50914),
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text("BAIXAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Sinopse
                  const Text("Sinopse", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.white60, height: 1.5)),
                  const SizedBox(height: 20),

                  // Seletor de Temporadas e Episódios (Apenas para Séries/Animes)
                  if (widget.type != 'filme' && seasons.isNotEmpty) ...[
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text("Temporada: ", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        DropdownButton<int>(
                          dropdownColor: Colors.grey[900],
                          value: selectedSeason,
                          items: seasons.map((s) {
                            return DropdownMenuItem<int>(
                              value: s['season_number'],
                              child: Text("Temporada ${s['season_number']}", style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) _fetchEpisodesTMDB(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    
                    // Lista de Episódios
                    if (episodes.isEmpty)
                      const Center(child: CircularProgressIndicator(color: Colors.red))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: episodes.length,
                        itemBuilder: (context, index) {
                          var ep = episodes[index];
                          bool isPlaying = (selectedEpisode == ep['episode_number']);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: ep['still_path'] != null 
                                    ? CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w185${ep['still_path']}", width: 100, height: 60, fit: BoxFit.cover)
                                    : Container(width: 100, height: 60, color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.white54)),
                                ),
                                if (isPlaying) const Icon(Icons.play_circle_fill, color: Color(0xFFE50914), size: 30),
                              ],
                            ),
                            title: Text("${ep['episode_number']}. ${ep['name']}", style: TextStyle(color: isPlaying ? const Color(0xFFE50914) : Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text("${ep['runtime'] ?? '--'} min", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            onTap: () {
                              setState(() { selectedEpisode = ep['episode_number']; });
                              _gerarLinkDoPlayer(); // Recarrega a WebView com o novo episódio
                            },
                          );
                        },
                      ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// CLASSES AUXILIARES E UI (PÁGINAS E CARDS)
// ==========================================
class ContentPage extends StatefulWidget {
  final String category;
  const ContentPage({super.key, required this.category});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> with AutomaticKeepAliveClientMixin {
  List trendingList = [];
  bool loading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    fetchTrending();
  }

  Future<void> fetchTrending() async {
    String url = "";
    if (widget.category == 'movie') {
      url = "https://api.themoviedb.org/3/trending/movie/day?api_key=$tmdbApiKey&language=pt-BR";
    } else if (widget.category == 'tv') {
      url = "https://api.themoviedb.org/3/trending/tv/day?api_key=$tmdbApiKey&language=pt-BR";
    } else if (widget.category == 'anime') {
      url = "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=16&with_original_language=ja&sort_by=popularity.desc";
    } else {
      url = "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_original_language=ko&sort_by=popularity.desc";
    }

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() {
          trendingList = json.decode(res.body)['results'];
          trendingList.removeWhere((item) => item['backdrop_path'] == null);
          loading = false;
        });
      }
    } catch (e) { debugPrint("$e"); }
  }

  Widget buildGenreSections() {
    if (widget.category == 'movie') {
      return Column(children: [
        SectionList(title: "Lançamentos", url: "https://api.themoviedb.org/3/movie/now_playing?api_key=$tmdbApiKey&language=pt-BR", category: 'movie'),
        SectionList(title: "Ação", url: "https://api.themoviedb.org/3/discover/movie?api_key=$tmdbApiKey&language=pt-BR&with_genres=28", category: 'movie'),
        SectionList(title: "Comédia", url: "https://api.themoviedb.org/3/discover/movie?api_key=$tmdbApiKey&language=pt-BR&with_genres=35", category: 'movie'),
      ]);
    } else if (widget.category == 'tv') {
      return Column(children: [
        SectionList(title: "Novos Episódios", url: "https://api.themoviedb.org/3/tv/on_the_air?api_key=$tmdbApiKey&language=pt-BR", category: 'tv'),
        SectionList(title: "Ação e Aventura", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=10759", category: 'tv'),
      ]);
    } else if (widget.category == 'anime') {
      return Column(children: [
        SectionList(title: "Populares", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=16&with_original_language=ja&sort_by=popularity.desc", category: 'anime'),
      ]);
    } else {
      return Column(children: [
        SectionList(title: "Em Alta", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_original_language=ko&sort_by=popularity.desc", category: 'dorama'),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trendingList.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(height: 220, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.85),
              items: trendingList.map((item) {
                return GestureDetector(
                  onTap: () {
                    String type = (widget.category == 'movie') ? 'filme' : 'serie';
                    Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(id: item['id'], title: item['title'] ?? item['name'], type: type, posterPath: item['poster_path'])));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: NetworkImage("https://image.tmdb.org/t/p/w780${item['backdrop_path']}"), fit: BoxFit.cover),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          buildGenreSections(),
        ],
      ),
    );
  }
}

class SectionList extends StatelessWidget {
  final String title;
  final String url;
  final String category;

  const SectionList({super.key, required this.title, required this.url, required this.category});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: http.get(Uri.parse(url)),
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        List items = json.decode(snapshot.data!.body)['results'];
        items.removeWhere((item) => item['poster_path'] == null);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 110, margin: const EdgeInsets.only(right: 10),
                    child: PosterCard(
                      item: items[index],
                      onTap: () {
                        String type = (category == 'movie') ? 'filme' : 'serie';
                        Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(id: items[index]['id'], title: items[index]['title'] ?? items[index]['name'], type: type, posterPath: items[index]['poster_path'])));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class PosterCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const PosterCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w342${item['poster_path']}", fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          const SizedBox(height: 5),
          Text(item['title'] ?? item['name'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query;
  const SearchResults({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: http.get(Uri.parse("https://api.themoviedb.org/3/search/multi?api_key=$tmdbApiKey&language=pt-BR&query=$query")),
      builder: (context, AsyncSnapshot<http.Response> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        List results = json.decode(snapshot.data!.body)['results'];
        results.removeWhere((item) => item['media_type'] == 'person' || item['poster_path'] == null);

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
          itemCount: results.length,
          itemBuilder: (context, index) => PosterCard(
            item: results[index],
            onTap: () {
              String type = results[index]['media_type'] == 'movie' ? 'filme' : 'serie';
              Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(id: results[index]['id'], title: results[index]['title'] ?? results[index]['name'], type: type, posterPath: results[index]['poster_path'])));
            },
          ),
        );
      },
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Histórico")));
  }
}
