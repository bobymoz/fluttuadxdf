import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

// SUA CHAVE TMDB
const String tmdbApiKey = '9c31b3aeb2e59aa2caf74c745ce15887'; 

void main() {
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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
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
        title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 36, letterSpacing: 2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          tooltip: "Histórico",
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
            )
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
                    hintText: "Pesquisar...",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      searchQuery = value;
                      isSearching = value.isNotEmpty;
                    });
                  },
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFE50914),
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: const [
                  Tab(icon: Icon(Icons.movie_outlined), text: "FILMES"),
                  Tab(icon: Icon(Icons.tv), text: "SÉRIES"),
                  Tab(icon: Icon(Icons.animation), text: "ANIMES"),
                  Tab(icon: Icon(Icons.favorite_border), text: "DORAMAS"),
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

// --- PÁGINA DE CONTEÚDO (LISTAS HORIZONTAIS) ---
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
    } catch (e) {
      debugPrint("Erro Trending: $e");
    }
  }

  // Helper para construir as URLs baseadas na categoria
  Widget buildGenreSections() {
    if (widget.category == 'movie') {
      return Column(children: [
        SectionList(title: "Lançamentos", url: "https://api.themoviedb.org/3/movie/now_playing?api_key=$tmdbApiKey&language=pt-BR", category: 'movie'),
        SectionList(title: "Ação", url: "https://api.themoviedb.org/3/discover/movie?api_key=$tmdbApiKey&language=pt-BR&with_genres=28", category: 'movie'),
        SectionList(title: "Comédia", url: "https://api.themoviedb.org/3/discover/movie?api_key=$tmdbApiKey&language=pt-BR&with_genres=35", category: 'movie'),
        SectionList(title: "Terror", url: "https://api.themoviedb.org/3/discover/movie?api_key=$tmdbApiKey&language=pt-BR&with_genres=27", category: 'movie'),
        SectionList(title: "Romance", url: "https://api.themoviedb.org/3/discover/movie?api_key=$tmdbApiKey&language=pt-BR&with_genres=10749", category: 'movie'),
      ]);
    } else if (widget.category == 'tv') {
      return Column(children: [
        SectionList(title: "Novos Episódios", url: "https://api.themoviedb.org/3/tv/on_the_air?api_key=$tmdbApiKey&language=pt-BR", category: 'tv'),
        SectionList(title: "Ação e Aventura", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=10759", category: 'tv'),
        SectionList(title: "Comédia", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=35", category: 'tv'),
        SectionList(title: "Drama", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=18", category: 'tv'),
      ]);
    } else if (widget.category == 'anime') {
      String baseAnime = "&with_genres=16&with_original_language=ja";
      return Column(children: [
        SectionList(title: "Populares", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR$baseAnime&sort_by=popularity.desc", category: 'anime'),
        SectionList(title: "Shounen (Ação)", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR$baseAnime&with_genres=10759", category: 'anime'),
        SectionList(title: "Comédia", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR$baseAnime&with_genres=35", category: 'anime'),
      ]);
    } else {
      // Dorama
      String baseDorama = "&with_original_language=ko"; // Coreanos
      return Column(children: [
        SectionList(title: "Em Alta", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR$baseDorama&sort_by=popularity.desc", category: 'dorama'),
        SectionList(title: "Romance", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR$baseDorama&with_genres=10749", category: 'dorama'),
        SectionList(title: "Drama", url: "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR$baseDorama&with_genres=18", category: 'dorama'),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CARROSSEL ---
          if (trendingList.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 220,
                autoPlay: true,
                enlargeCenterPage: true,
                autoPlayCurve: Curves.fastOutSlowIn,
                viewportFraction: 0.85,
              ),
              items: trendingList.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () => openPlayer(context, item, widget.category),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage("https://image.tmdb.org/t/p/w780${item['backdrop_path']}"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, Colors.black],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          alignment: Alignment.bottomLeft,
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            item['title'] ?? item['name'] ?? "",
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

          const SizedBox(height: 20),
          // --- LISTAS POR GÊNERO ---
          buildGenreSections(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void openPlayer(BuildContext context, dynamic item, String category) {
    String type = (category == 'movie') ? 'filme' : 'serie';
    Navigator.push(context, MaterialPageRoute(
      builder: (c) => SuperPlayer(
        id: item['id'], 
        title: item['title'] ?? item['name'],
        type: type,
        posterPath: item['poster_path'],
      ),
    ));
  }
}

// --- WIDGET DE LISTA HORIZONTAL (SEÇÃO) ---
class SectionList extends StatefulWidget {
  final String title;
  final String url;
  final String category;

  const SectionList({super.key, required this.title, required this.url, required this.category});

  @override
  State<SectionList> createState() => _SectionListState();
}

class _SectionListState extends State<SectionList> {
  List items = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final res = await http.get(Uri.parse(widget.url));
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            items = json.decode(res.body)['results'];
            items.removeWhere((item) => item['poster_path'] == null);
          });
        }
      }
    } catch (e) { print(e); }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  // Abre a tela "Ver Mais"
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => GenreGridScreen(title: widget.title, url: widget.url, category: widget.category)
                  ));
                },
                child: const Text("Ver mais", style: TextStyle(color: Color(0xFFE50914))),
              )
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: 110,
                margin: const EdgeInsets.only(right: 10),
                child: PosterCard(
                  item: item,
                  onTap: () {
                    String type = (widget.category == 'movie') ? 'filme' : 'serie';
                    Navigator.push(context, MaterialPageRoute(
                      builder: (c) => SuperPlayer(id: item['id'], title: item['title'] ?? item['name'], type: type, posterPath: item['poster_path'])
                    ));
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- TELA DE "VER MAIS" (GRADE COMPLETA) ---
class GenreGridScreen extends StatefulWidget {
  final String title;
  final String url;
  final String category;

  const GenreGridScreen({super.key, required this.title, required this.url, required this.category});

  @override
  State<GenreGridScreen> createState() => _GenreGridScreenState();
}

class _GenreGridScreenState extends State<GenreGridScreen> {
  List items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    try {
      final res = await http.get(Uri.parse(widget.url)); // Pega a mesma URL da seção
      if (res.statusCode == 200) {
        setState(() {
          items = json.decode(res.body)['results'];
          items.removeWhere((item) => item['poster_path'] == null);
          loading = false;
        });
      }
    } catch (e) { setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.red))
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              childAspectRatio: 0.55,
              crossAxisSpacing: 10, 
              mainAxisSpacing: 10
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return PosterCard(
                item: item,
                onTap: () {
                  String type = (widget.category == 'movie') ? 'filme' : 'serie';
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => SuperPlayer(id: item['id'], title: item['title'] ?? item['name'], type: type, posterPath: item['poster_path'])
                  ));
                },
              );
            },
          ),
    );
  }
}

// --- RESULTADOS DA PESQUISA ---
class SearchResults extends StatefulWidget {
  final String query;
  const SearchResults({super.key, required this.query});

  @override
  State<SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  List results = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    search();
  }

  @override
  void didUpdateWidget(covariant SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      search();
    }
  }

  Future<void> search() async {
    setState(() => loading = true);
    final url = "https://api.themoviedb.org/3/search/multi?api_key=$tmdbApiKey&language=pt-BR&query=${widget.query}";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() {
          results = json.decode(res.body)['results'];
          results.removeWhere((item) => item['media_type'] == 'person' || item['poster_path'] == null);
          loading = false;
        });
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: Colors.red));
    if (results.isEmpty) return const Center(child: Text("Nenhum resultado encontrado.", style: TextStyle(color: Colors.grey)));

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 0.55,
        crossAxisSpacing: 10, 
        mainAxisSpacing: 10
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return PosterCard(
          item: item,
          onTap: () {
            String type = item['media_type'] == 'movie' ? 'filme' : 'serie';
            Navigator.push(context, MaterialPageRoute(
              builder: (c) => SuperPlayer(id: item['id'], title: item['title'] ?? item['name'], type: type, posterPath: item['poster_path'])
            ));
          },
        );
      },
    );
  }
}

// --- POSTER CARD ---
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
              child: CachedNetworkImage(
                imageUrl: "https://image.tmdb.org/t/p/w342${item['poster_path']}",
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (c, u) => Shimmer.fromColors(
                  baseColor: Colors.grey[850]!,
                  highlightColor: Colors.grey[800]!,
                  child: Container(color: Colors.black),
                ),
                errorWidget: (c, u, e) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            item['title'] ?? item['name'] ?? "Sem título",
            maxLines: 2, 
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}

// --- PLAYER (SEM TELEGRAM, COM AVISO DE EPISÓDIOS) ---
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

  @override
  void initState() {
    super.initState();
    salvarHistorico();
    
    // MENSAGEM DE AVISO (SnackBar)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Para ver a lista de episódios de uma série ou anime clique no ícone de voltar.", style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFE50914),
          duration: Duration(seconds: 4),
        ),
      );
    });
  }

  void salvarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    
    Map<String, dynamic> item = {
      'id': widget.id,
      'title': widget.title,
      'type': widget.type,
      'poster_path': widget.posterPath,
      'date': DateTime.now().toIso8601String(),
    };

    history.removeWhere((element) => json.decode(element)['id'] == widget.id);
    history.insert(0, json.encode(item));
    if (history.length > 50) history = history.sublist(0, 50);
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    String videoUrl = "";
    if (widget.type == 'filme') {
      videoUrl = "https://superflixapi.one/filme/${widget.id}";
    } else {
      videoUrl = "https://superflixapi.one/serie/${widget.id}/1/1"; 
    }

    String htmlContent = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>body, html { margin: 0; padding: 0; height: 100%; width: 100%; background: #000; overflow: hidden; } iframe { width: 100%; height: 100%; border: none; display: block; } </style>
      </head>
      <body>
        <iframe src="$videoUrl" allow="autoplay; encrypted-media; picture-in-picture; fullscreen" allowfullscreen></iframe>
      </body>
      </html>
    """;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. O VÍDEO
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              useShouldOverrideUrlLoading: true,
              userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile)",
            ),
            onWebViewCreated: (ctrl) {
              webViewController = ctrl;
              ctrl.loadData(
                data: htmlContent, 
                mimeType: "text/html", 
                encoding: "utf-8",
                baseUrl: WebUri("https://superflixapi.one/")
              );
            },
            onLoadStop: (controller, url) async {
              // INJEÇÃO CSS PARA ESCONDER BOTÕES DELES
              await controller.evaluateJavascript(source: """
                var css = 'footer, .footer, .links, a[href*="telegram"], a[href*="t.me"] { display: none !important; }';
                var head = document.head || document.getElementsByTagName('head')[0];
                var style = document.createElement('style');
                style.appendChild(document.createTextNode(css));
                head.appendChild(style);
              """);
            },
            shouldOverrideUrlLoading: (ctrl, nav) async {
              var uri = nav.request.url!;
              if (uri.toString().contains('superflixapi.one')) return NavigationActionPolicy.ALLOW;
              return NavigationActionPolicy.CANCEL;
            },
          ),
          // 2. BOTÃO VOLTAR
          Positioned(
            top: 20, left: 20,
            child: FloatingActionButton.small(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.white,
              child: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TELA DE HISTÓRICO ---
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  void carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList('history') ?? [];
    setState(() {
      history = list.map((e) => json.decode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico")),
      body: history.isEmpty 
        ? const Center(child: Text("Você ainda não assistiu nada.", style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                leading: item['poster_path'] != null 
                  ? Image.network("https://image.tmdb.org/t/p/w92${item['poster_path']}") 
                  : const Icon(Icons.movie),
                title: Text(item['title'], style: const TextStyle(color: Colors.white)),
                subtitle: Text(item['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.grey)),
                trailing: const Icon(Icons.play_arrow, color: Colors.red),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => SuperPlayer(
                      id: item['id'], 
                      title: item['title'], 
                      type: item['type'],
                      posterPath: item['poster_path']
                    )
                  ));
                },
              );
            },
          ),
    );
  }
}
