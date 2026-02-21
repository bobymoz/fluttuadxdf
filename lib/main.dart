import 'dart:convert';
import 'dart:io';
import 'dart:async';
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
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

const String smartPlayUrl = "https://smartplaylite.xn--n8ja5190f.mba";
const String telegramUrl = "https://t.me/cdcine";

// ==========================================
// ANÚNCIOS ORIGINAIS DO CLIENTE
// ==========================================
const String _c1 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script type="text/javascript">atOptions = {'key' : 'ea3ab4f496752035d9aba623fd8faad5','format' : 'iframe','height' : 50,'width' : 320,'params' : {}};</script><script type="text/javascript" src="//www.highperformanceformat.com/ea3ab4f496752035d9aba623fd8faad5/invoke.js"></script></body></html>""";
const String _c2 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script type="text/javascript">atOptions = {'key' : '408e7bfeab9af6c469fca0766541b341','format' : 'iframe','height' : 250,'width' : 300,'params' : {}};</script><script type="text/javascript" src="//www.highperformanceformat.com/408e7bfeab9af6c469fca0766541b341/invoke.js"></script></body></html>""";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const CDcineApp());
}

// Limpador de Títulos Bugados (Remove %20 e caracteres estranhos)
String cleanTitle(String input) {
  try {
    String text = Uri.decodeFull(input);
    return text.replaceAll('&amp;', '&').replaceAll('&#039;', "'").replaceAll('&quot;', '"').replaceAll('&#8211;', '-').replaceAll('&#8217;', "'").trim();
  } catch (e) {
    return input;
  }
}

// ==========================================
// GERENCIADOR DE DOWNLOADS COM CANCELAMENTO
// ==========================================
class DownloadManager {
  static ValueNotifier<double> progress = ValueNotifier(-1.0);
  static String currentTitle = "";
  static CancelToken? cancelToken;

  static Future<void> startDownload(String url, String title, bool isMp4) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    currentTitle = cleanTitle(title);
    progress.value = 0.0;
    cancelToken = CancelToken();

    try {
      final dir = Directory('/storage/emulated/0/Download');
      String safeTitle = currentTitle.replaceAll(RegExp(r'[^\w\s]+'), '');
      String ext = isMp4 ? "mp4" : "m3u8";
      final savePath = "${dir.path}/CDCINE_$safeTitle.$ext";

      await Dio().download(url, savePath, cancelToken: cancelToken, options: Options(headers: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"}), onReceiveProgress: (rec, total) {
        if (total != -1) progress.value = rec / total;
      });
      progress.value = -2.0; 
      _salvarHistorico(savePath);
      Future.delayed(const Duration(seconds: 4), () => progress.value = -1.0);
    } catch (e) {
      // CORREÇÃO: Verificação segura do tipo DioException exigida pelas novas versões do Dio
      if (e is DioException && CancelToken.isCancel(e)) { 
        progress.value = -1.0; 
      } else { 
        progress.value = -3.0; 
        Future.delayed(const Duration(seconds: 4), () => progress.value = -1.0); 
      }
    }
  }

  static void cancelDownload() {
    cancelToken?.cancel();
    progress.value = -1.0;
  }

  static void _salvarHistorico(String path) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> files = prefs.getStringList('downloads') ?? [];
    if (!files.contains(path)) { files.add(path); prefs.setStringList('downloads', files); }
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
        scaffoldBackgroundColor: const Color(0xFF0F0F13),
        primaryColor: const Color(0xFFE50914),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F0F13), elevation: 0),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const DraggableDownloadOverlay(),
          ],
        );
      },
      home: const MainScreen(),
    );
  }
}

// Widget flutuante de download
class DraggableDownloadOverlay extends StatefulWidget {
  const DraggableDownloadOverlay({super.key});
  @override State<DraggableDownloadOverlay> createState() => _DraggableDownloadOverlayState();
}
class _DraggableDownloadOverlayState extends State<DraggableDownloadOverlay> {
  double bottomOffset = 20; double leftOffset = 20;

  @override Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: DownloadManager.progress,
      builder: (context, val, _) {
        if (val == -1.0) return const SizedBox.shrink();
        Color bgColor = Colors.grey[900]!;
        String text = "A transferir: ${DownloadManager.currentTitle} ${(val * 100).toStringAsFixed(0)}%";
        Widget icon = SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: val, color: const Color(0xFFE50914), strokeWidth: 3));
        if (val == -2.0) { bgColor = Colors.green[800]!; text = "Transferência Concluída"; icon = const Icon(Icons.check_circle, color: Colors.white); } 
        else if (val == -3.0) { bgColor = Colors.red[800]!; text = "Erro na Transferência"; icon = const Icon(Icons.error, color: Colors.white); }
        
        return Positioned(
          bottom: bottomOffset, left: leftOffset,
          child: GestureDetector(
            onPanUpdate: (details) { setState(() { bottomOffset -= details.delta.dy; leftOffset += details.delta.dx; }); },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]),
                child: Row(children: [icon, const SizedBox(width: 15), Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// SCRAPER GLOBAL (API PYTHON-LIKE)
// ==========================================
Future<List<Map<String, String>>> fetchScraperData(String url) async {
  try {
    final res = await http.get(Uri.parse(url), headers: {"User-Agent": "Mozilla/5.0"});
    List<Map<String, String>> list = []; Set<String> vistos = {};
    RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
    for (var match in exp.allMatches(res.body)) {
      String id = match.group(3)!;
      if (!vistos.contains(id)) {
        vistos.add(id);
        list.add({"imagem": match.group(1)!, "tipo": match.group(2)!, "id": id, "titulo": cleanTitle(match.group(4)!)});
      }
    }
    return list;
  } catch (e) { return []; }
}

// ==========================================
// TELA PRINCIPAL (Categorias)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); 
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF121212),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFE50914)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("CDCINE PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  Text("O melhor conteúdo, sem limites.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.blueAccent), 
              title: const Text('O Nosso Telegram', style: TextStyle(color: Colors.white)), 
              onTap: () { launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication); }
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 32, letterSpacing: 2)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.history, color: Colors.white), tooltip: "Histórico", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen()))),
          IconButton(icon: const Icon(Icons.download, color: Colors.white), tooltip: "Downloads", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DownloadsScreen()))),
          IconButton(icon: const Icon(Icons.search, color: Colors.white), tooltip: "Pesquisar", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchScreen()))),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE50914), indicatorWeight: 3, labelColor: Colors.white, unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [Tab(text: "FILMES"), Tab(text: "SÉRIES"), Tab(text: "ANIMES")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [CategoryTab(type: 'filmes'), CategoryTab(type: 'series'), CategoryTab(type: 'animes')],
      ),
    );
  }
}

// ==========================================
// ABAS DE CATEGORIA COM ANÚNCIOS INTERCALADOS
// ==========================================
class CategoryTab extends StatefulWidget {
  final String type; const CategoryTab({super.key, required this.type});
  @override State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> with AutomaticKeepAliveClientMixin {
  List carouselItems = []; bool loading = true;
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _loadInitialData(); }
  void _loadInitialData() async {
    carouselItems = await fetchScraperData("$smartPlayUrl/posts/${widget.type}/1");
    if (mounted) setState(() => loading = false);
  }

  Widget _buildAd(String htmlData, double height) {
    return Container(
      height: height, width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 10),
      child: InAppWebView(
        initialData: InAppWebViewInitialData(data: htmlData),
        initialSettings: InAppWebViewSettings(javaScriptEnabled: true, transparentBackground: true),
        shouldOverrideUrlLoading: (c, nav) async { launchUrl(nav.request.url!, mode: LaunchMode.externalApplication); return NavigationActionPolicy.CANCEL; },
      ),
    );
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    if (loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (carouselItems.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(height: 250, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.45),
              items: carouselItems.map((item) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: item))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: NetworkImage(item['imagem']), fit: BoxFit.cover)),
                  ),
                );
              }).toList(),
            ),
          
          _buildAd(_c1, 50), 
          
          if (widget.type == 'filmes') ...[
            SectionWidget(title: "Lançamentos", urlPattern: "$smartPlayUrl/posts/filmes/[PAGE]"),
            SectionWidget(title: "Ação", urlPattern: "$smartPlayUrl/search/[PAGE]?search=ação"),
            _buildAd(_c2, 250), 
            SectionWidget(title: "Comédia", urlPattern: "$smartPlayUrl/search/[PAGE]?search=comédia"),
            SectionWidget(title: "Terror", urlPattern: "$smartPlayUrl/search/[PAGE]?search=terror"),
          ] else if (widget.type == 'series') ...[
            SectionWidget(title: "Séries em Alta", urlPattern: "$smartPlayUrl/posts/series/[PAGE]"),
            SectionWidget(title: "Ação", urlPattern: "$smartPlayUrl/search/[PAGE]?search=ação"),
            _buildAd(_c2, 250),
            SectionWidget(title: "Drama", urlPattern: "$smartPlayUrl/search/[PAGE]?search=drama"),
            SectionWidget(title: "Ficção Científica", urlPattern: "$smartPlayUrl/search/[PAGE]?search=ficção"),
            SectionWidget(title: "Comédia", urlPattern: "$smartPlayUrl/search/[PAGE]?search=comédia"),
          ] else if (widget.type == 'animes') ...[
            SectionWidget(title: "Animes Recentes", urlPattern: "$smartPlayUrl/posts/animes/[PAGE]"),
            SectionWidget(title: "Shounen", urlPattern: "$smartPlayUrl/search/[PAGE]?search=shounen"),
            _buildAd(_c2, 250),
            SectionWidget(title: "Aventura", urlPattern: "$smartPlayUrl/search/[PAGE]?search=aventura"),
            SectionWidget(title: "Isekai", urlPattern: "$smartPlayUrl/search/[PAGE]?search=isekai"),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class SectionWidget extends StatefulWidget {
  final String title; final String urlPattern;
  const SectionWidget({super.key, required this.title, required this.urlPattern});
  @override State<SectionWidget> createState() => _SectionWidgetState();
}
class _SectionWidgetState extends State<SectionWidget> {
  List items = [];
  @override void initState() { super.initState(); _fetchData(); }
  void _fetchData() async { List res = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", "1")); if (mounted) setState(() => items = res); }
  @override Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => GridScreen(title: widget.title, urlPattern: widget.urlPattern))),
                child: const Text("Ver mais", style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10), itemCount: items.length,
            itemBuilder: (c, i) => Container(width: 110, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: items[i])),
          ),
        ),
      ],
    );
  }
}

class GridScreen extends StatefulWidget {
  final String title; final String urlPattern;
  const GridScreen({super.key, required this.title, required this.urlPattern});
  @override State<GridScreen> createState() => _GridScreenState();
}
class _GridScreenState extends State<GridScreen> {
  List items = []; bool loading = true; int page = 1;
  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async {
    setState(() => loading = true);
    var newItems = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", page.toString()));
    if(mounted) setState(() { items = newItems; loading = false; });
  }
  void _changePage(int direction) { if (page + direction > 0) { setState(() { page += direction; items.clear(); }); _fetch(); } }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading && items.isEmpty ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))) : Column(
        children: [
          Expanded(child: GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: items.length, itemBuilder: (c, i) => PosterCard(item: items[i]))),
          Container(
            color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]), onPressed: page > 1 ? () => _changePage(-1) : null, child: const Icon(Icons.arrow_back, color: Colors.white)),
                Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), onPressed: items.length >= 10 ? () => _changePage(1) : null, child: const Icon(Icons.arrow_forward, color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// PESQUISA INDIVIDUAL E LIMPA
// ==========================================
class SearchScreen extends StatefulWidget { const SearchScreen({super.key}); @override State<SearchScreen> createState() => _SearchScreenState(); }
class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  List items = []; bool loading = false; bool searched = false;
  void _doSearch(String query) async {
    if (query.isEmpty) return;
    setState(() { loading = true; searched = true; });
    var res = await fetchScraperData("$smartPlayUrl/search/1?search=$query");
    setState(() { items = res; loading = false; });
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl, style: const TextStyle(color: Colors.white), autofocus: true,
          decoration: const InputDecoration(hintText: "Procurar conteúdo...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
          onSubmitted: _doSearch,
        ),
      ),
      body: loading ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))) 
        : (!searched ? const Center(child: Icon(Icons.search, size: 80, color: Colors.white24)) 
        : (items.isEmpty ? const Center(child: Text("Nenhum resultado encontrado.")) 
        : GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: items.length, itemBuilder: (c, i) => PosterCard(item: items[i])))),
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
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item['imagem'], fit: BoxFit.cover, width: double.infinity,
                placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[800]!, child: Container(color: Colors.black)),
                errorWidget: (c, u, e) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
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
// TELA DO PLAYER (EXOPLAYER, AUTO-RESUME, FIX DE LOOP)
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

  String sinopse = "A carregar informações...";
  String backdrop = "";
  List temporadas = []; List episodios = [];
  String? tempSelecionada; String epAtivoNome = "";
  List recomendacoes = [];
  
  bool isPlaying = false;
  bool isServerLoading = false;
  bool isSynopsisExpanded = false;
  int _extracaoStatus = 0; 

  // Variáveis de Continuar a Assistir (Resume)
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
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  // CONTINUAR DE ONDE PAROU
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
      if (_videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
        int pos = _videoPlayerController!.value.position.inSeconds;
        if (pos > 0) {
          final prefs = await SharedPreferences.getInstance();
          Map<String, dynamic> data = {"position": pos, "ep_id": savedEpId, "ep_nome": epAtivoNome};
          prefs.setString("resume_${widget.item['id']}", json.encode(data));
        }
      }
    });
  }

  void _fetchRecomendacoes() async {
    var res = await fetchScraperData("$smartPlayUrl/posts/${widget.item['tipo']}/1");
    if(mounted) setState(() { recomendacoes = res.where((e) => e['id'] != widget.item['id']).take(6).toList(); });
  }

  void _onExtratorLoaded() async {
    if (webExtrator == null) return;
    try {
      if (_extracaoStatus == 0) {
        var dadosJs = await webExtrator!.evaluateJavascript(source: """
          (function() {
            var data = {sinopse: "Sinopse indisponível", backdrop: ""};
            var syn = document.querySelector('.synopsis'); if(syn) data.sinopse = syn.innerText;
            var bg = document.querySelector('.backdrop img'); if(bg) data.backdrop = bg.src;
            return JSON.stringify(data);
          })();
        """);
        if (dadosJs != null && mounted) {
          var d = json.decode(dadosJs.toString());
          setState(() { sinopse = d['sinopse']; backdrop = d['backdrop'] ?? widget.item['imagem']; });
        }

        if (widget.item['tipo'] == 'filmes') return;

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
    } catch (e) {}
  }

  void _carregarEpisodiosUrl(String seasonId) {
    setState(() { episodios = []; _extracaoStatus = 1; }); 
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

        // AUTO-RESUME PARA SÉRIES
        if (!_autoPlayDisparado && savedEpId != null && savedEpId!.isNotEmpty) {
          _autoPlayDisparado = true;
          _abrirServidores(savedEpId!, savedEpNome ?? "Episódio", false);
        }
      }
    } catch (e) {}
  }

  Future<void> _abrirServidores(String idVideo, String nomeVideo, bool isParaDownload) async {
    setState(() { isPlaying = true; isServerLoading = true; epAtivoNome = nomeVideo; savedEpId = idVideo; });
    
    String urlApi = widget.item['tipo'] == 'filmes' ? "$smartPlayUrl/player/movie" : "$smartPlayUrl/player/episode";
    Map payload = widget.item['tipo'] == 'filmes' ? {"movie_id": idVideo, "action_type": "PLAY"} : {"ep_id": idVideo, "action_type": "PLAY"};

    try {
      final res = await http.post(Uri.parse(urlApi), headers: {"User-Agent": "Mozilla/5.0", "Content-Type": "application/json", "Referer": smartPlayUrl}, body: json.encode(payload));
      
      var data = json.decode(res.body);
      if (data['success'] == true && data['players'] != null) {
        List players = data['players'];
        if (players.isEmpty) { setState(() => isServerLoading = false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Nenhum servidor online."))); return; }
        
        List<Map> servers = players.map((p) {
          String url = p["file"].toString().replaceAll("&amp;", "&");
          String tipo = p["type"]?.toString() ?? "Video";
          String name = (p["title"] ?? "").toString();
          String idioma = (url.contains("/dub/") || name.toLowerCase().contains("dub")) ? "Dublado" : (url.contains("/leg/") || name.toLowerCase().contains("leg")) ? "Legendado" : "Opção";
          return {"url": url, "tipo": tipo, "idioma": idioma, "isMp4": tipo.toUpperCase().contains("MP4")};
        }).toList();

        setState(() => isServerLoading = false);
        _mostrarModalServidores(servers, nomeVideo, isParaDownload);
      }
    } catch (e) { setState(() => isServerLoading = false); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao conectar ao servidor."))); }
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
              Text(isParaDownload ? "Servidores para Download:" : "Servidores de Reprodução:", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              ...servers.map((s) {
                if (isParaDownload && !s['isMp4']) return const SizedBox.shrink(); 
                return Card(
                  color: s['isMp4'] ? const Color(0xFF153a1d) : Colors.black,
                  shape: RoundedRectangleBorder(side: BorderSide(color: s['isMp4'] ? Colors.green : Colors.grey[800]!), borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    title: Text(s['idioma'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(s['isMp4'] ? "Premium (MP4)" : "Padrão (M3U8)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (isParaDownload) {
                        setState(() => isPlaying = false);
                        DownloadManager.startDownload(s['url'], titulo, true);
                      } else {
                        _iniciarExoPlayer(s['url'], titulo);
                      }
                    },
                  ),
                );
              }).toList()
            ],
          ),
        );
      }
    ).whenComplete(() {
      if (isServerLoading || (_chewieController == null && isPlaying)) {
        setState(() { isPlaying = false; isServerLoading = false; });
      }
    });
  }

  void _iniciarExoPlayer(String url, String tituloEpisodio) async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    setState(() { isPlaying = true; isServerLoading = true; });

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url), httpHeaders: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"});
    await _videoPlayerController!.initialize();

    if (savedPositionSeconds > 0) {
      await _videoPlayerController!.seekTo(Duration(seconds: savedPositionSeconds));
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true, looping: false, aspectRatio: 16 / 9, allowPlaybackSpeedChanging: true,
      materialProgressColors: ChewieProgressColors(playedColor: const Color(0xFFE50914), handleColor: const Color(0xFFE50914), backgroundColor: Colors.grey[800]!, bufferedColor: Colors.white54),
    );
    
    setState(() => isServerLoading = false);
    _iniciarSalvamentoContinuo();
  }

  void _salvarHistoricoGeral() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hist = prefs.getStringList('history') ?? [];
    Map<String, dynamic> it = {'id': widget.item['id'], 'title': widget.item['titulo'], 'type': widget.item['tipo'], 'poster_path': widget.item['imagem']};
    hist.removeWhere((e) => json.decode(e)['id'] == widget.item['id']);
    hist.insert(0, json.encode(it));
    await prefs.setStringList('history', hist);
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. ÁREA DO VÍDEO
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: backdrop.isNotEmpty ? backdrop : widget.item['imagem'], fit: BoxFit.cover, alignment: Alignment.topCenter),
                  Container(color: Colors.black.withOpacity(0.6)),
                  
                  if (!isPlaying && widget.item['tipo'] == 'filmes')
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 70), 
                        onPressed: () {
                          // AUTO-RESUME PARA FILMES
                          if (!_autoPlayDisparado && savedPositionSeconds > 0) {
                            _autoPlayDisparado = true;
                            _abrirServidores(widget.item['id'], widget.item['titulo'], false);
                          } else {
                            _abrirServidores(widget.item['id'], widget.item['titulo'], false);
                          }
                        }
                      )
                    ),
                  
                  if (!isPlaying && widget.item['tipo'] != 'filmes')
                    const Center(child: Text("Selecione um episódio abaixo", style: TextStyle(color: Colors.white, fontSize: 16))),
                  
                  if (isPlaying && isServerLoading)
                    Container(color: Colors.black.withOpacity(0.8), child: const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))),

                  if (isPlaying && !isServerLoading && _chewieController != null)
                    Chewie(controller: _chewieController!),

                  if (!isPlaying)
                    Positioned(top: 10, left: 10, child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))),
                ],
              ),
            ),
          ),

          SizedBox(
            height: 1, width: 1,
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
              initialUrlRequest: URLRequest(url: WebUri("$smartPlayUrl/posts/${widget.item['tipo']}/post/${widget.item['id']}")),
              onWebViewCreated: (c) => webExtrator = c,
              onLoadStop: (c, u) { _onExtratorLoaded(); },
            ),
          ),

          // 2. INFORMAÇÕES
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
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        icon: const Icon(Icons.download, color: Colors.white), label: const Text("TRANSFERIR", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          if (widget.item['tipo'] == 'filmes') _abrirServidores(widget.item['id'], widget.item['titulo'], true);
                          else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pressione durante algum tempo no episódio que deseja transferir.")));
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  const Text("Sinopse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => isSynopsisExpanded = !isSynopsisExpanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sinopse,
                          maxLines: isSynopsisExpanded ? null : 3,
                          overflow: isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                        ),
                        if (sinopse.length > 150)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(isSynopsisExpanded ? "Mostrar menos" : "Ver mais...", style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12)),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (widget.item['tipo'] != 'filmes' && temporadas.isNotEmpty) ...[
                    const Divider(color: Colors.white24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.grey[900], value: tempSelecionada,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['nome']))).toList(),
                          onChanged: (val) { if (val != null) { setState(() { tempSelecionada = val; episodios.clear(); _extracaoStatus = 1; }); _carregarEpisodiosUrl(val); } },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  if (widget.item['tipo'] != 'filmes') ...[
                    if (episodios.isEmpty && sinopse != "A carregar informações...")
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
                              onLongPress: () => _abrirServidores(ep['id'], "${widget.item['titulo']} - ${ep['full_nome']}", true), 
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
                    const Text("Dica: Pressione durante algum tempo num episódio para fazer TRANSFERÊNCIA.", style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                  ],

                  if (recomendacoes.isNotEmpty) ...[
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),
                    const Text("Recomendações", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal, itemCount: recomendacoes.length,
                        itemBuilder: (ctx, i) {
                          var rec = recomendacoes[i];
                          return GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PlayerScreen(item: rec))),
                            child: Container(
                              width: 100, margin: const EdgeInsets.only(right: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: rec['imagem'], fit: BoxFit.cover, width: double.infinity))),
                                  const SizedBox(height: 5),
                                  Text(rec['titulo'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
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
// TELAS DE HISTÓRICO E DOWNLOADS
// ==========================================
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
          title: Text(item['title'], style: const TextStyle(color: Colors.white)), subtitle: Text(item['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.grey)), trailing: const Icon(Icons.play_arrow, color: Colors.red),
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
                    trailing: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), tooltip: "Cancelar", onPressed: DownloadManager.cancelDownload),
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
                  return ListTile(leading: const Icon(Icons.video_file, color: Colors.greenAccent, size: 40), title: Text(name, style: const TextStyle(color: Colors.white)), subtitle: const Text("Guardado na Galeria"), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final prefs = await SharedPreferences.getInstance(); files.removeAt(i); prefs.setStringList('downloads', files); setState(() {}); }));
                }),
          ),
        ],
      )
    );
  }
}
