import 'dart:convert';
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

const String smartPlayUrl = "https://smartplaylite.xn--n8ja5190f.mba";
const String telegramUrl = "https://t.me/cdcine";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CDcineApp());
}

// ==========================================
// GERENCIADOR GLOBAL DE DOWNLOADS
// ==========================================
class DownloadManager {
  static ValueNotifier<double> progress = ValueNotifier(-1.0);
  static String currentTitle = "";
  static List<String> downloadedFiles = [];

  static Future<void> startDownload(String url, String title, bool isMp4) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    currentTitle = title;
    progress.value = 0.0;

    try {
      final dir = Directory('/storage/emulated/0/Download');
      String safeTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '');
      String ext = isMp4 ? "mp4" : "m3u8";
      final savePath = "${dir.path}/CDCINE_$safeTitle.$ext";

      await Dio().download(
        url, savePath,
        options: Options(headers: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"}),
        onReceiveProgress: (rec, total) {
          if (total != -1) progress.value = rec / total;
        },
      );
      progress.value = -2.0; 
      _salvarHistoricoDownload(savePath);
      Future.delayed(const Duration(seconds: 4), () => progress.value = -1.0);
    } catch (e) {
      progress.value = -3.0; 
      Future.delayed(const Duration(seconds: 4), () => progress.value = -1.0);
    }
  }

  static void _salvarHistoricoDownload(String path) async {
    final prefs = await SharedPreferences.getInstance();
    downloadedFiles = prefs.getStringList('downloads') ?? [];
    if (!downloadedFiles.contains(path)) {
      downloadedFiles.add(path);
      prefs.setStringList('downloads', downloadedFiles);
    }
  }
}

class CDcineApp extends StatelessWidget {
  const CDcineApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CDCINE PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFE50914),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212), elevation: 0),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            ValueListenableBuilder<double>(
              valueListenable: DownloadManager.progress,
              builder: (context, val, _) {
                if (val == -1.0) return const SizedBox.shrink();
                Color bgColor = Colors.grey[900]!;
                String text = "Baixando: ${DownloadManager.currentTitle} ${(val * 100).toStringAsFixed(0)}%";
                Widget icon = SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: val, color: const Color(0xFFE50914), strokeWidth: 3));
                if (val == -2.0) { bgColor = Colors.green[800]!; text = "Download Concluído!"; icon = const Icon(Icons.check_circle, color: Colors.white); } 
                else if (val == -3.0) { bgColor = Colors.red[800]!; text = "Erro no Download!"; icon = const Icon(Icons.error, color: Colors.white); }
                return Positioned(
                  bottom: 20, left: 20, right: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
                      child: Row(children: [icon, const SizedBox(width: 15), Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
      home: const MainScreen(),
    );
  }
}

// ==========================================
// 1. TELA PRINCIPAL (UI RESTAURADA - SEM TMDB)
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
        leading: IconButton(icon: const Icon(Icons.history, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen()))),
        actions: [
          IconButton(icon: const Icon(Icons.download_done, color: Colors.greenAccent), tooltip: "Meus Downloads", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DownloadsScreen()))),
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
                    hintText: "Pesquisar Filmes, Séries, Animes...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true, fillColor: Colors.grey[900],
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: (val) => setState(() { searchQuery = val; isSearching = val.isNotEmpty; }),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFE50914), indicatorWeight: 3, labelColor: Colors.white, unselectedLabelColor: Colors.grey,
                tabs: const [Tab(text: "INÍCIO"), Tab(text: "FILMES"), Tab(text: "SÉRIES"), Tab(text: "ANIMES")],
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
              InicioTab(), // Carrosséis Restaurados
              CategoryGridTab(category: 'filmes'),
              CategoryGridTab(category: 'series'),
              CategoryGridTab(category: 'animes'),
            ],
          ),
    );
  }
}

// SCRAPER GLOBAL (Substitui o TMDB)
Future<List<Map<String, String>>> fetchScraperData(String url) async {
  try {
    final res = await http.get(Uri.parse(url), headers: {"User-Agent": "Mozilla/5.0"});
    List<Map<String, String>> list = [];
    Set<String> vistos = {};
    RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
    for (var match in exp.allMatches(res.body)) {
      String id = match.group(3)!;
      if (!vistos.contains(id)) {
        vistos.add(id);
        list.add({"imagem": match.group(1)!, "tipo": match.group(2)!, "id": id, "titulo": match.group(4)!.replaceAll(RegExp(r'<[^>]*>'), '').trim()});
      }
    }
    return list;
  } catch (e) { return []; }
}

// ABA INÍCIO (Carrosséis)
class InicioTab extends StatefulWidget { const InicioTab({super.key}); @override State<InicioTab> createState() => _InicioTabState(); }
class _InicioTabState extends State<InicioTab> with AutomaticKeepAliveClientMixin {
  List filmes = [], series = [], animes = [];
  bool loading = true;
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _loadAll(); }
  void _loadAll() async {
    filmes = await fetchScraperData("$smartPlayUrl/posts/filmes/1");
    series = await fetchScraperData("$smartPlayUrl/posts/series/1");
    animes = await fetchScraperData("$smartPlayUrl/posts/animes/1");
    if(mounted) setState(() => loading = false);
  }

  Widget _buildCarousel(String title, List items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 10), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
        CarouselSlider(
          options: CarouselOptions(height: 220, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.85),
          items: items.map((item) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerModernoScreen(item: item))),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: NetworkImage(item['imagem']), fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: const LinearGradient(colors: [Colors.transparent, Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  alignment: Alignment.bottomLeft, padding: const EdgeInsets.all(10),
                  child: Text(item['titulo'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    return SingleChildScrollView(child: Column(children: [_buildCarousel("Filmes Populares", filmes), _buildCarousel("Séries em Alta", series), _buildCarousel("Animes Recentes", animes), const SizedBox(height: 30)]));
  }
}

// ABA CATEGORIA ESPECÍFICA (PAGINAÇÃO QUE SUBSTITUI A TELA)
class CategoryGridTab extends StatefulWidget { final String category; const CategoryGridTab({super.key, required this.category}); @override State<CategoryGridTab> createState() => _CategoryGridTabState(); }
class _CategoryGridTabState extends State<CategoryGridTab> with AutomaticKeepAliveClientMixin {
  List items = []; bool loading = true; int page = 1;
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _fetchPage(); }
  void _fetchPage() async {
    setState(() => loading = true);
    var newItems = await fetchScraperData("$smartPlayUrl/posts/${widget.category}/$page");
    if(mounted) setState(() { items = newItems; loading = false; });
  }

  void _changePage(int change) {
    if (page + change > 0) {
      setState(() { page += change; items.clear(); });
      _fetchPage();
    }
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    if (loading && items.isEmpty) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: items.length,
            itemBuilder: (c, i) => PosterCard(item: items[i]),
          ),
        ),
        // PAGINAÇÃO QUE SUBSTITUI (Não acumula)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]), onPressed: page > 1 ? () => _changePage(-1) : null, child: const Text("< Anterior")),
              Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), onPressed: () => _changePage(1), child: const Text("Próxima >", style: TextStyle(color: Colors.white))),
            ],
          ),
        )
      ],
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query; const SearchResults({super.key, required this.query});
  @override Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchScraperData("$smartPlayUrl/search/1?search=$query"),
      builder: (c, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
        if (snapshot.data!.isEmpty) return const Center(child: Text("Nada encontrado."));
        return GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: snapshot.data!.length, itemBuilder: (c, i) => PosterCard(item: snapshot.data![i]));
      },
    );
  }
}

class PosterCard extends StatelessWidget {
  final dynamic item; const PosterCard({super.key, required this.item});
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerModernoScreen(item: item))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item['imagem'], fit: BoxFit.cover, width: double.infinity,
                placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[800]!, child: Container(color: Colors.black)),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(4)), child: Text(item['tipo'].toString().toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
          const SizedBox(height: 2),
          Text(item['titulo'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. TELA DO PLAYER PROFISSIONAL (VIDEO.JS + DETALHES NATIVOS)
// ==========================================
class PlayerModernoScreen extends StatefulWidget {
  final Map item; const PlayerModernoScreen({super.key, required this.item});
  @override State<PlayerModernoScreen> createState() => _PlayerModernoScreenState();
}

class _PlayerModernoScreenState extends State<PlayerModernoScreen> {
  InAppWebViewController? webExtrator;
  String sinopse = "Carregando detalhes...";
  List temporadas = []; List episodios = [];
  String? tempSelecionada; String epAtivoNome = "";
  
  String urlVideoTocando = "";
  bool isPlaying = false; bool isMp4 = false;

  @override void initState() { super.initState(); _salvarHistorico(); }

  // WEBVIEW INVISÍVEL: Faz o trabalho do Playwright para pegar a Sinopse e os Episódios
  void _onExtratorLoaded() async {
    if (webExtrator == null) return;
    try {
      // 1. Pega Sinopse
      var sinopseHtml = await webExtrator!.evaluateJavascript(source: "document.querySelector('.wp-content p') ? document.querySelector('.wp-content p').innerText : 'Sinopse não informada.'");
      if (sinopseHtml != null && mounted) setState(() => sinopse = sinopseHtml.toString());

      if (widget.item['tipo'] == 'filmes') return;

      // 2. Pega Temporadas
      var seasonsRes = await webExtrator!.evaluateJavascript(source: "window.CookieManager.get('seasons_${widget.item['id']}')");
      if (seasonsRes != null && seasonsRes.toString().isNotEmpty) {
        List sList = json.decode(seasonsRes.toString());
        List temp = [];
        for (int i = 0; i < sList.length; i++) {
          String id = sList[i]['ID']?.toString() ?? sList[i]['id']?.toString() ?? "";
          String nome = sList[i]['nome']?.toString() ?? sList[i]['name']?.toString() ?? "Temp ${i + 1}";
          if (id.isNotEmpty) temp.add({"id": id, "nome": nome});
        }
        if (temp.isNotEmpty && mounted) {
          setState(() { temporadas = temp; tempSelecionada = temp[0]['id']; });
          _carregarEpisodios(temp[0]['id']);
          return;
        }
      }
      _extrairEpisodiosDiretos(); // Fallback Animes
    } catch (e) {}
  }

  void _carregarEpisodios(String seasonId) {
    setState(() => episodios = []);
    webExtrator?.loadUrl(urlRequest: URLRequest(url: WebUri("$smartPlayUrl/season/$seasonId/episodes")));
  }

  void _extrairEpisodiosDiretos() async {
    try {
      var epsRes = await webExtrator!.evaluateJavascript(source: """
        (function(){
          var eps = []; var imgs = document.querySelectorAll("img[onclick*='loadEpisodePlayers']");
          for(var i=0; i<imgs.length; i++) {
            var m = imgs[i].getAttribute('onclick').match(/loadEpisodePlayers\\('(\\d+)'/);
            if(m) eps.push({id: m[1], nome: imgs[i].getAttribute('alt')});
          } return JSON.stringify(eps);
        })();
      """);
      if (epsRes != null && mounted) {
        List eList = json.decode(epsRes.toString());
        setState(() {
          episodios = eList.map((e) {
            String num = e['nome'].toString().replaceAll(RegExp(r'[^0-9]'), '');
            return {"id": e['id'].toString(), "full_nome": e['nome'].toString(), "num": num.isEmpty ? "▶" : num};
          }).toList();
        });
      }
    } catch (e) {}
  }

  // BUSCAR SERVIDORES NA API PYTHON-LIKE
  Future<void> _abrirServidores(String idVideo, String nomeVideo, bool isParaDownload) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))));
    String urlApi = widget.item['tipo'] == 'filmes' ? "$smartPlayUrl/player/movie" : "$smartPlayUrl/player/episode";
    Map payload = widget.item['tipo'] == 'filmes' ? {"movie_id": idVideo, "action_type": "PLAY"} : {"ep_id": idVideo, "action_type": "PLAY"};

    try {
      final res = await http.post(Uri.parse(urlApi), headers: {"User-Agent": "Mozilla/5.0", "Content-Type": "application/json", "Referer": smartPlayUrl}, body: json.encode(payload));
      Navigator.pop(context);
      
      var data = json.decode(res.body);
      if (data['success'] == true && data['players'] != null) {
        List players = data['players'];
        if (players.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhum servidor."))); return; }
        
        List<Map> servers = players.map((p) {
          String url = p["file"].toString().replaceAll("&amp;", "&");
          String tipo = p["type"]?.toString() ?? "Video";
          String name = (p["title"] ?? "").toString();
          String idioma = (url.contains("/dub/") || name.toLowerCase().contains("dub")) ? "Dublado" : (url.contains("/leg/") || name.toLowerCase().contains("leg")) ? "Legendado" : "Opção";
          return {"url": url, "tipo": tipo, "idioma": idioma, "isMp4": tipo.toUpperCase().contains("MP4")};
        }).toList();

        _mostrarModalServidores(servers, nomeVideo, isParaDownload);
      }
    } catch (e) { Navigator.pop(context); }
  }

  void _mostrarModalServidores(List<Map> servers, String titulo, bool isParaDownload) {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(isParaDownload ? "Baixar Servidor:" : "Assistir Servidor:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              ...servers.map((s) {
                if (isParaDownload && !s['isMp4']) return const SizedBox.shrink(); // Apenas MP4 para download
                return Card(
                  color: s['isMp4'] ? const Color(0xFF153a1d) : Colors.black,
                  shape: RoundedRectangleBorder(side: BorderSide(color: s['isMp4'] ? Colors.green : Colors.grey[800]!), borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: Icon(isParaDownload ? Icons.download : (s['isMp4'] ? Icons.ondemand_video : Icons.stream), color: s['isMp4'] ? Colors.greenAccent : Colors.red),
                    title: Text(s['idioma'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(s['isMp4'] ? "Premium (Recomendado MP4)" : "Padrão (Streaming M3U8)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (isParaDownload) {
                        DownloadManager.startDownload(s['url'], titulo, true);
                      } else {
                        setState(() { urlVideoTocando = s['url']; isPlaying = true; isMp4 = s['isMp4']; epAtivoNome = titulo; });
                      }
                    },
                  ),
                );
              }).toList()
            ],
          ),
        );
      }
    );
  }

  void _salvarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hist = prefs.getStringList('history') ?? [];
    Map<String, dynamic> it = {'id': widget.item['id'], 'title': widget.item['titulo'], 'type': widget.item['tipo'], 'poster_path': widget.item['imagem']};
    hist.removeWhere((e) => json.decode(e)['id'] == widget.item['id']);
    hist.insert(0, json.encode(it));
    await prefs.setStringList('history', hist);
  }

  @override Widget build(BuildContext context) {
    // PLAYER PROFISSIONAL VIDEO.JS (A pedido, com Animações e Controles Completos)
    String ext = urlVideoTocando.contains(".m3u8") ? "application/x-mpegURL" : "video/mp4";
    String htmlPlayerPro = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link href="https://vjs.zencdn.net/8.10.0/video-js.css" rel="stylesheet" />
        <style>
          body, html { margin: 0; padding: 0; background: #000; height: 100vh; overflow: hidden; }
          .video-js { width: 100vw; height: 100vh; }
          .vjs-theme-sea .vjs-control-bar { background-color: rgba(0,0,0,0.8); }
          .vjs-big-play-button { top: 50% !important; left: 50% !important; transform: translate(-50%, -50%); border-radius: 50% !important; height: 2.5em !important; width: 2.5em !important; background-color: #E50914 !important; border: none !important; }
          .vjs-loading-spinner { border-color: #E50914 !important; }
        </style>
      </head>
      <body>
        <video id="my-video" class="video-js vjs-default-skin" controls preload="auto" autoplay playsinline data-setup='{"fluid": false}'>
          <source src="$urlVideoTocando" type="$ext" />
        </video>
        <script src="https://vjs.zencdn.net/8.10.0/video.min.js"></script>
        <script>
          var player = videojs('my-video');
          player.ready(function() { player.play(); });
        </script>
      </body>
      </html>
    """;

    return Scaffold(
      appBar: AppBar(title: Text(widget.item['titulo'], style: const TextStyle(fontSize: 16))),
      body: Column(
        children: [
          // 1. ÁREA DO VÍDEO
          AspectRatio(
            aspectRatio: 16 / 9,
            child: isPlaying 
              ? InAppWebView(
                  initialSettings: InAppWebViewSettings(javaScriptEnabled: true, mediaPlaybackRequiresUserGesture: false, allowsInlineMediaPlayback: true),
                  initialData: InAppWebViewInitialData(data: htmlPlayerPro),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(imageUrl: widget.item['imagem'], fit: BoxFit.cover, alignment: Alignment.topCenter),
                    Container(color: Colors.black.withOpacity(0.7)),
                    if (widget.item['tipo'] == 'filmes')
                      Center(child: IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 70), onPressed: () => _abrirServidores(widget.item['id'], widget.item['titulo'], false)))
                    else
                      const Center(child: Text("Selecione um episódio abaixo", style: TextStyle(color: Colors.white, fontSize: 16))),
                  ],
                ),
          ),

          // WEBVIEW EXTRATORA INVISÍVEL
          SizedBox(
            height: 1, width: 1,
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
              initialUrlRequest: URLRequest(url: WebUri("$smartPlayUrl/posts/${widget.item['tipo']}/post/${widget.item['id']}")),
              onWebViewCreated: (c) => webExtrator = c,
              onLoadStop: (c, u) { _onExtratorLoaded(); _extrairEpisodiosDiretos(); },
            ),
          ),

          // 2. INFORMAÇÕES E EPISÓDIOS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(widget.item['titulo'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                      // BOTÃO DOWNLOAD PRINCIPAL
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        icon: const Icon(Icons.download, color: Colors.white), label: const Text("BAIXAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          if (widget.item['tipo'] == 'filmes') _abrirServidores(widget.item['id'], widget.item['titulo'], true);
                          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Segure o dedo sobre o episódio que deseja baixar.")));
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  const Text("Sinopse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(sinopse, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 20),

                  // EPISÓDIOS EM BLOCOS (Estilo UniTV)
                  if (widget.item['tipo'] != 'filmes' && temporadas.isNotEmpty) ...[
                    const Divider(color: Colors.white24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.grey[900], value: tempSelecionada,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['nome']))).toList(),
                          onChanged: (val) { if (val != null) { setState(() { tempSelecionada = val; episodios.clear(); }); _carregarEpisodios(val); } },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (widget.item['tipo'] != 'filmes') ...[
                    if (episodios.isEmpty && sinopse != "Carregando detalhes...")
                      const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                    else
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal, itemCount: episodios.length,
                          itemBuilder: (ctx, i) {
                            var ep = episodios[i];
                            bool isAtivo = epAtivoNome == "${widget.item['titulo']} - ${ep['full_nome']}";
                            return GestureDetector(
                              onTap: () => _abrirServidores(ep['id'], "${widget.item['titulo']} - ${ep['full_nome']}", false),
                              onLongPress: () => _abrirServidores(ep['id'], "${widget.item['titulo']} - ${ep['full_nome']}", true), // Segura para baixar!
                              child: Container(
                                width: 50, margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(color: isAtivo ? const Color(0xFFE50914) : Colors.grey[850], borderRadius: BorderRadius.circular(6)),
                                child: Center(child: Text(ep['num'], style: TextStyle(color: isAtivo ? Colors.white : Colors.grey[300], fontSize: 16, fontWeight: FontWeight.bold))),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                    const Text("Dica: Segure o dedo em um episódio para fazer o DOWNLOAD.", style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                  ]
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 4. HISTÓRICO E TELA DE DOWNLOADS
// ==========================================
class HistoryScreen extends StatefulWidget { const HistoryScreen({super.key}); @override State<HistoryScreen> createState() => _HistoryScreenState(); }
class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];
  @override void initState() { super.initState(); carregar(); }
  void carregar() async { final prefs = await SharedPreferences.getInstance(); setState(() => history = (prefs.getStringList('history') ?? []).map((e) => json.decode(e) as Map<String, dynamic>).toList()); }
  
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico")),
      body: history.isEmpty ? const Center(child: Text("Você ainda não assistiu nada.", style: TextStyle(color: Colors.grey))) : ListView.builder(itemCount: history.length, itemBuilder: (c, i) {
        var item = history[i];
        return ListTile(
          leading: item['poster_path'] != null && item['poster_path'].toString().startsWith('http') ? Image.network(item['poster_path'], width: 50, fit: BoxFit.cover) : const Icon(Icons.movie),
          title: Text(item['title'], style: const TextStyle(color: Colors.white)), subtitle: Text(item['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.grey)), trailing: const Icon(Icons.play_arrow, color: Colors.red),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerModernoScreen(item: {'id': item['id'], 'titulo': item['title'], 'tipo': item['type'], 'imagem': item['poster_path']}))),
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
      appBar: AppBar(title: const Text("Meus Downloads")),
      body: files.isEmpty ? const Center(child: Text("Nenhum download concluído.", style: TextStyle(color: Colors.grey))) : ListView.builder(itemCount: files.length, itemBuilder: (c, i) {
        String name = files[i].split('/').last;
        return ListTile(leading: const Icon(Icons.video_file, color: Colors.greenAccent, size: 40), title: Text(name, style: const TextStyle(color: Colors.white)), subtitle: const Text("Salvo na Galeria/Downloads"), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final prefs = await SharedPreferences.getInstance(); files.removeAt(i); prefs.setStringList('downloads', files); setState(() {}); }));
      }),
    );
  }
}
