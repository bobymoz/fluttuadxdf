import 'dart:convert';
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
        // Transições Profissionais (Zoom/Fade)
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

// --- TELA PRINCIPAL COM ABAS ---
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
    // 4 Categorias: Filmes, Séries, Animes, Doramas
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
          preferredSize: const Size.fromHeight(130), // Altura para Busca + Tabs
          child: Column(
            children: [
              // --- BARRA DE PESQUISA ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Pesquisar filmes, animes...",
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
              
              // --- CATEGORIAS (ABAS) ---
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
              ContentPage(category: 'movie'),     // Filmes
              ContentPage(category: 'tv'),        // Séries
              ContentPage(category: 'anime'),     // Animes
              ContentPage(category: 'dorama'),    // Doramas
            ],
          ),
    );
  }
}

// --- PÁGINA DE CONTEÚDO (CARROSSEL + GRADE) ---
class ContentPage extends StatefulWidget {
  final String category; // movie, tv, anime, dorama
  const ContentPage({super.key, required this.category});

  @override
  State<ContentPage> createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> with AutomaticKeepAliveClientMixin {
  List contentList = [];
  List trendingList = [];
  bool loading = true;

  @override
  bool get wantKeepAlive => true; // Mantém a aba carregada ao trocar

  @override
  void initState() {
    super.initState();
    fetchContent();
  }

  Future<void> fetchContent() async {
    String urlGrid = "";
    String urlTrending = "";

    // Lógica inteligente para separar o conteúdo no TMDB
    if (widget.category == 'movie') {
      urlGrid = "https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&language=pt-BR&page=1";
      urlTrending = "https://api.themoviedb.org/3/trending/movie/day?api_key=$tmdbApiKey&language=pt-BR";
    } else if (widget.category == 'tv') {
      urlGrid = "https://api.themoviedb.org/3/tv/popular?api_key=$tmdbApiKey&language=pt-BR&page=1";
      urlTrending = "https://api.themoviedb.org/3/trending/tv/day?api_key=$tmdbApiKey&language=pt-BR";
    } else if (widget.category == 'anime') {
      // Filtro para Animes: Gênero Animação (16) + Lingua Japonesa (ja)
      urlGrid = "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=16&with_original_language=ja&sort_by=popularity.desc";
      urlTrending = urlGrid;
    } else if (widget.category == 'dorama') {
      // Filtro para Doramas: Lingua Coreana (ko)
      urlGrid = "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_original_language=ko&sort_by=popularity.desc";
      urlTrending = urlGrid;
    }

    try {
      final resGrid = await http.get(Uri.parse(urlGrid));
      final resTrend = await http.get(Uri.parse(urlTrending));

      if (resGrid.statusCode == 200) {
        setState(() {
          contentList = json.decode(resGrid.body)['results'];
          trendingList = json.decode(resTrend.body)['results'];
          // Remove itens sem imagem
          trendingList.removeWhere((item) => item['backdrop_path'] == null);
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessário para o KeepAlive
    
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CARROSSEL AUTOMÁTICO ---
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

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text("Mais Populares", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // --- GRADE DE CONTEÚDO ---
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: contentList.length,
            itemBuilder: (context, index) {
              final item = contentList[index];
              return PosterCard(
                item: item,
                onTap: () => openPlayer(context, item, widget.category),
              );
            },
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void openPlayer(BuildContext context, dynamic item, String category) {
    // Define se é filme ou série para a SuperFlix
    // Anime e Dorama são tratados como 'serie' na API da SuperFlix
    String type = (category == 'movie') ? 'filme' : 'serie';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => SuperPlayer(
          id: item['id'], 
          title: item['title'] ?? item['name'],
          type: type,
          posterPath: item['poster_path'],
        ),
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
          // Remove pessoas, só queremos filmes/series
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
        crossAxisCount: 3, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
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

// --- COMPONENTE DO POSTER (REUTILIZÁVEL) ---
class PosterCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const PosterCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: "https://image.tmdb.org/t/p/w342${item['poster_path']}",
          fit: BoxFit.cover,
          placeholder: (c, u) => Shimmer.fromColors(
            baseColor: Colors.grey[850]!,
            highlightColor: Colors.grey[800]!,
            child: Container(color: Colors.black),
          ),
          errorWidget: (c, u, e) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
        ),
      ),
    );
  }
}

// --- TELA DO PLAYER E DOWNLOAD ---
class SuperPlayer extends StatefulWidget {
  final int id;
  final String title;
  final String type; // filme ou serie
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
  }

  // Salva no SharedPreferences para a tela de Histórico
  void salvarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];
    
    // Cria um JSON do item
    Map<String, dynamic> item = {
      'id': widget.id,
      'title': widget.title,
      'type': widget.type,
      'poster_path': widget.posterPath,
      'date': DateTime.now().toIso8601String(),
    };

    // Remove duplicatas (se já assistiu antes, sobe pro topo)
    history.removeWhere((element) => json.decode(element)['id'] == widget.id);
    history.insert(0, json.encode(item)); // Adiciona no início

    // Limita a 50 itens
    if (history.length > 50) history = history.sublist(0, 50);

    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    // URL baseada no tipo
    // OBS: Para séries/animes, estamos mandando para a Temporada 1, Ep 1 por padrão
    // A interface da SuperFlix dentro do iframe permite trocar eps
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
        <style>body{margin:0;background:#000;overflow:hidden}iframe{width:100%;height:100%;border:none}</style>
      </head>
      <body>
        <iframe src="$videoUrl" allow="autoplay; encrypted-media; picture-in-picture; fullscreen" allowfullscreen></iframe>
      </body>
      </html>
    """;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ÁREA DO VÍDEO (16:9)
            AspectRatio(
              aspectRatio: 16/9,
              child: InAppWebView(
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
                    baseUrl: WebUri("https://superflixapi.one/") // Truque do Iframe
                  );
                },
                shouldOverrideUrlLoading: (ctrl, nav) async {
                  var uri = nav.request.url!;
                  if (uri.toString().contains('superflixapi.one')) return NavigationActionPolicy.ALLOW;
                  return NavigationActionPolicy.CANCEL; // Bloqueia Ads
                },
              ),
            ),

            // INFORMAÇÕES E BOTÕES
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF121212),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(widget.type == 'filme' ? Icons.movie : Icons.tv, color: Colors.grey, size: 16),
                        const SizedBox(width: 5),
                        Text(widget.type.toUpperCase(), style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // BOTÃO DE DOWNLOAD (VISUAL)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.download_rounded, color: Colors.white),
                        label: const Text("Baixar Episódio/Filme", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Download indisponível no momento (Servidor Protegido)."))
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Sinopse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    const Text(
                      "Para ver a sinopse completa e mais detalhes, continue assistindo. O player carrega automaticamente a melhor qualidade disponível.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
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
