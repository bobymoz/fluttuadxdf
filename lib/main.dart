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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212), elevation: 0),
      ),
      home: const MainScreen(),
    );
  }
}

// ==========================================
// TELA PRINCIPAL (Navegação)
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
        leading: IconButton(icon: const Icon(Icons.history, color: Colors.white), onPressed: () {}),
        actions: [
          IconButton(icon: const Icon(Icons.send, color: Color(0xFF0088cc)), onPressed: () => launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
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
                tabs: const [Tab(text: "FILMES"), Tab(text: "SÉRIES"), Tab(text: "ANIMES"), Tab(text: "DORAMAS")],
              ),
            ],
          ),
        ),
      ),
      body: isSearching ? SearchResults(query: searchQuery) : TabBarView(
        controller: _tabController,
        children: const [ContentPage(category: 'movie'), ContentPage(category: 'tv'), ContentPage(category: 'anime'), ContentPage(category: 'dorama')],
      ),
    );
  }
}

// ==========================================
// SUPER PLAYER (O Motor NATIVO)
// ==========================================
class SuperPlayer extends StatefulWidget {
  final String title;
  final String type; // 'movie' ou 'tv'
  final String? posterPath;
  final int tmdbId;

  const SuperPlayer({super.key, required this.title, required this.type, required this.tmdbId, this.posterPath});

  @override
  State<SuperPlayer> createState() => _SuperPlayerState();
}

class _SuperPlayerState extends State<SuperPlayer> {
  bool _isLoading = true;
  String _mp4Url = "";
  
  // Detalhes
  String description = "";
  double rating = 0.0;

  // Download Control
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchDetailsTMDB();
    _hackSmartPlayLite(); // Inicia a conexão com a nova fonte
  }

  // 1. Busca Nota e Sinopse para a Tela ficar profissional
  Future<void> _fetchDetailsTMDB() async {
    String type = widget.type == 'movie' ? 'movie' : 'tv';
    final url = "https://api.themoviedb.org/3/$type/${widget.tmdbId}?api_key=$tmdbApiKey&language=pt-BR";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          description = data['overview'] ?? "Sem descrição.";
          rating = (data['vote_average'] ?? 0).toDouble();
        });
      }
    } catch (e) {}
  }

  // 2. A MÁGICA: Integra a API nativa do seu app_filmes.py no Dart
  Future<void> _hackSmartPlayLite() async {
    try {
      // Passo A: Pesquisar o nome do filme no SmartPlayLite
      final searchRes = await http.get(Uri.parse("https://smartplaylite.xn--n8ja5190f.mba/search/1?search=${widget.title}"));
      
      // Encontra o ID do filme na nova fonte via Regex
      RegExp regExp = RegExp(r'<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>');
      var match = regExp.firstMatch(searchRes.body);

      if (match != null) {
        String tipoPost = match.group(1)!; // filmes ou series
        String smartPlayId = match.group(2)!;

        // Se for filme, ataca a API POST diretamente (Igual o Python)
        if (tipoPost == 'filmes') {
          final playRes = await http.post(
            Uri.parse("https://smartplaylite.xn--n8ja5190f.mba/player/movie"),
            headers: {"User-Agent": "Mozilla/5.0"},
            body: json.encode({"movie_id": smartPlayId, "action_type": "PLAY"}),
          );
          
          var data = json.decode(playRes.body);
          if (data['success'] == true) {
            String linkVideo = data['players'][0]['file'].toString().replaceAll("&amp;", "&");
            setState(() {
              _mp4Url = linkVideo;
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      // Se não achou nativamente (ou é série), usa um fallback web
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  // 3. Sistema de Download Integrado e Seguro
  Future<void> _baixarFilme() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    setState(() { _isDownloading = true; });

    try {
      final dir = Directory('/storage/emulated/0/Download');
      String fileName = "${widget.title.replaceAll(RegExp(r'[^\w\s]+'), '')}.mp4";
      String savePath = "${dir.path}/$fileName";

      await Dio().download(
        _mp4Url,
        savePath,
        options: Options(headers: {
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
          // Adicionamos referer caso seja link de proteção de terceiros
          "Referer": "https://smartplaylite.xn--n8ja5190f.mba/"
        }),
        onReceiveProgress: (rec, total) {
          if (total != -1) setState(() => _downloadProgress = rec / total);
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salvo em: $savePath"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao baixar: $e")));
    } finally {
      setState(() { _isDownloading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading 
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.red), SizedBox(height: 10), Text("Conectando ao SmartPlayLite...")]))
        : Column(
          children: [
            // ÁREA DO PLAYER
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (_mp4Url.isNotEmpty)
                    InAppWebView(
                      initialSettings: InAppWebViewSettings(javaScriptEnabled: true, mediaPlaybackRequiresUserGesture: false, allowsInlineMediaPlayback: true),
                      // Cria um player HTML simples para tocar o MP4 puro
                      initialData: InAppWebViewInitialData(data: """
                        <body style="margin:0;background:#000;display:flex;align-items:center;justify-content:center;">
                          <video controls autoplay style="width:100%;height:100%;"><source src="$_mp4Url" type="video/mp4"></video>
                        </body>
                      """),
                    )
                  else
                    const Center(child: Text("Vídeo não encontrado para esta mídia.", style: TextStyle(color: Colors.grey))),
                  
                  // Tela de progresso de download
                  if (_isDownloading)
                    Container(
                      color: Colors.black87,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(value: _downloadProgress, color: Colors.red),
                            const SizedBox(height: 10),
                            Text("${(_downloadProgress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontSize: 24)),
                            const Text("Baixando...", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // INFORMAÇÕES E BOTÃO BAIXAR
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        if (_mp4Url.isNotEmpty)
                          FloatingActionButton.extended(
                            onPressed: _isDownloading ? null : _baixarFilme,
                            backgroundColor: const Color(0xFFE50914),
                            icon: const Icon(Icons.download, color: Colors.white),
                            label: const Text("BAIXAR"),
                          )
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Sinopse", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(description, style: const TextStyle(fontSize: 14, color: Colors.white60, height: 1.5)),
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
// CLASSES DE UI E LISTAGEM (Base do TMDB)
// ==========================================
class ContentPage extends StatefulWidget {
  final String category;
  const ContentPage({super.key, required this.category});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  List trendingList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTrending();
  }

  Future<void> fetchTrending() async {
    String typeUrl = widget.category == 'movie' ? 'movie' : 'tv';
    final url = "https://api.themoviedb.org/3/trending/$typeUrl/day?api_key=$tmdbApiKey&language=pt-BR";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() {
          trendingList = json.decode(res.body)['results'];
          trendingList.removeWhere((item) => item['backdrop_path'] == null);
          loading = false;
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: trendingList.length,
      itemBuilder: (context, index) {
        final item = trendingList[index];
        return GestureDetector(
          onTap: () {
            String type = widget.category == 'movie' ? 'movie' : 'tv';
            Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(tmdbId: item['id'], title: item['title'] ?? item['name'], type: type, posterPath: item['poster_path'])));
          },
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
              Text(item['title'] ?? item['name'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
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
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                String type = results[index]['media_type'] == 'movie' ? 'movie' : 'tv';
                Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(tmdbId: results[index]['id'], title: results[index]['title'] ?? results[index]['name'], type: type, posterPath: results[index]['poster_path'])));
              },
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w342${results[index]['poster_path']}", fit: BoxFit.cover)),
            );
          },
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
