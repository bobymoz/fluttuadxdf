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

const String tmdbApiKey = '9c31b3aeb2e59aa2caf74c745ce15887';
const String telegramUrl = "https://t.me/cdcine";
const String smartPlayUrl = "https://smartplaylite.xn--n8ja5190f.mba";

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
      progress.value = -2.0; // Sucesso
      _salvarHistoricoDownload(savePath);
      Future.delayed(const Duration(seconds: 4), () => progress.value = -1.0);
    } catch (e) {
      progress.value = -3.0; // Erro
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
// 1. TELA PRINCIPAL (UI RESTAURADA TMDB)
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
                tabs: const [Tab(text: "FILMES"), Tab(text: "SÉRIES"), Tab(text: "ANIMES"), Tab(text: "DORAMAS")],
              ),
            ],
          ),
        ),
      ),
      body: isSearching 
        ? SearchResults(query: searchQuery) 
        : TabBarView(
            controller: _tabController,
            children: const [ContentPage(category: 'movie'), ContentPage(category: 'tv'), ContentPage(category: 'anime'), ContentPage(category: 'dorama')],
          ),
    );
  }
}

// ==========================================
// 2. PLAYER PROFISSIONAL & DETALHES (Estilo UniTV)
// ==========================================
class SuperPlayer extends StatefulWidget {
  final int tmdbId;
  final String title;
  final String type; // 'movie' ou 'tv'
  final String? posterPath;

  const SuperPlayer({super.key, required this.tmdbId, required this.title, required this.type, this.posterPath});

  @override
  State<SuperPlayer> createState() => _SuperPlayerState();
}

class _SuperPlayerState extends State<SuperPlayer> {
  // TMDB Data
  String sinopse = "";
  double nota = 0.0;
  bool _isLoadingInfo = true;

  // SmartPlayLite Data (Extrator)
  InAppWebViewController? webExtractor;
  String smartPlayId = "";
  String smartPlayType = ""; // 'filmes' ou 'series' ou 'animes'
  List temporadas = [];
  List episodios = [];
  String? tempSelecionada;
  String epSelecionadoNome = "";

  // Player State
  String videoTocandoUrl = "";
  bool isPlaying = false;
  bool _isScraping = false;

  @override
  void initState() {
    super.initState();
    _salvarHistorico();
    _fetchTmdbInfo();
    _findInSmartPlay();
  }

  // 1. Busca Sinopse e Nota Lindas do TMDB
  Future<void> _fetchTmdbInfo() async {
    try {
      final res = await http.get(Uri.parse("https://api.themoviedb.org/3/${widget.type}/${widget.tmdbId}?api_key=$tmdbApiKey&language=pt-BR"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        setState(() {
          sinopse = data['overview'] ?? "Sem sinopse.";
          nota = (data['vote_average'] ?? 0).toDouble();
          _isLoadingInfo = false;
        });
      }
    } catch (e) { setState(() => _isLoadingInfo = false); }
  }

  // 2. Procura o Filme/Série no Motor Python (SmartPlayLite)
  Future<void> _findInSmartPlay() async {
    setState(() => _isScraping = true);
    try {
      // Limpa o título para a busca (tira acentos para achar mais fácil)
      String busca = widget.title.split(":")[0]; 
      final res = await http.get(Uri.parse("$smartPlayUrl/search/1?search=$busca"));
      
      RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
      var matches = exp.allMatches(res.body).toList();

      if (matches.isNotEmpty) {
        // Pega o primeiro resultado mais provável
        smartPlayType = matches[0].group(1)!;
        smartPlayId = matches[0].group(2)!;

        if (smartPlayType == 'filmes') {
          setState(() => _isScraping = false);
          // É filme, já pode mostrar botão de Play/Servers
        } else {
          // É série/anime, carrega a WebView invisível para puxar episódios
          _iniciarExtratorInvisivel();
        }
      } else {
        setState(() => _isScraping = false);
      }
    } catch (e) { setState(() => _isScraping = false); }
  }

  // 3. O "Playwright" do Flutter (Extrai Temporadas via JS)
  void _iniciarExtratorInvisivel() {
    if (smartPlayId.isEmpty) return;
    // A WebView invisível é criada no método Build e controlada aqui
  }

  void _onExtratorLoaded() async {
    if (webExtractor == null) return;
    try {
      var seasonsRes = await webExtractor!.evaluateJavascript(source: "window.CookieManager.get('seasons_$smartPlayId')");
      if (seasonsRes != null && seasonsRes.toString().isNotEmpty) {
        List sList = json.decode(seasonsRes.toString());
        List temp = [];
        for (int i = 0; i < sList.length; i++) {
          String id = sList[i]['ID']?.toString() ?? sList[i]['id']?.toString() ?? "";
          String nome = sList[i]['nome']?.toString() ?? sList[i]['name']?.toString() ?? "Temporada ${i + 1}";
          if (id.isNotEmpty) temp.add({"id": id, "nome": nome});
        }
        if (temp.isNotEmpty) {
          setState(() { temporadas = temp; tempSelecionada = temp[0]['id']; _isScraping = false; });
          _carregarEpisodiosJS(temp[0]['id']);
          return;
        }
      }
      // Se não tem temporadas, tenta puxar episódios diretos da tela
      _extrairEpisodiosDaTela();
    } catch (e) { setState(() => _isScraping = false); }
  }

  void _carregarEpisodiosJS(String seasonId) {
    setState(() => episodios = []);
    webExtractor?.loadUrl(urlRequest: URLRequest(url: WebUri("$smartPlayUrl/season/$seasonId/episodes")));
  }

  void _extrairEpisodiosDaTela() async {
    try {
      var epsRes = await webExtractor!.evaluateJavascript(source: """
        (function(){
          var eps = [];
          var imgs = document.querySelectorAll("img[onclick*='loadEpisodePlayers']");
          for(var i=0; i<imgs.length; i++) {
            var m = imgs[i].getAttribute('onclick').match(/loadEpisodePlayers\\('(\\d+)'/);
            if(m) eps.push({id: m[1], nome: imgs[i].getAttribute('alt')});
          }
          return JSON.stringify(eps);
        })();
      """);
      if (epsRes != null) {
        List eList = json.decode(epsRes.toString());
        setState(() {
          episodios = eList.map((e) {
            String num = e['nome'].toString().replaceAll(RegExp(r'[^0-9]'), '');
            return {"id": e['id'].toString(), "full_nome": e['nome'].toString(), "num": num.isEmpty ? "▶" : num};
          }).toList();
          _isScraping = false;
        });
      }
    } catch (e) { setState(() => _isScraping = false); }
  }

  // 4. Modal de Servidores e Qualidade (Para Play e Download)
  Future<void> _abrirServidores(String idVideo, String nomeVideo, bool paraDownload) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: Color(0xFFE50914))));
    
    String urlApi = smartPlayType == 'filmes' ? "$smartPlayUrl/player/movie" : "$smartPlayUrl/player/episode";
    Map payload = smartPlayType == 'filmes' ? {"movie_id": idVideo, "action_type": "PLAY"} : {"ep_id": idVideo, "action_type": "PLAY"};

    try {
      final res = await http.post(Uri.parse(urlApi), headers: {"User-Agent": "Mozilla/5.0", "Content-Type": "application/json", "Referer": smartPlayUrl}, body: json.encode(payload));
      Navigator.pop(context); // Fecha loading
      
      var data = json.decode(res.body);
      if (data['success'] == true && data['players'] != null) {
        List players = data['players'];
        if (players.isEmpty) return;
        
        List<Map> servers = players.map((p) {
          String url = p["file"].toString().replaceAll("&amp;", "&");
          String tipo = p["type"]?.toString() ?? "Video";
          String name = (p["title"] ?? "").toString();
          String idioma = (url.contains("/dub/") || name.toLowerCase().contains("dub")) ? "Dublado" : (url.contains("/leg/") || name.toLowerCase().contains("leg")) ? "Legendado" : "Padrão";
          return {"url": url, "tipo": tipo, "idioma": idioma, "isMp4": tipo.toUpperCase().contains("MP4")};
        }).toList();

        _mostrarModalServidores(servers, nomeVideo, paraDownload);
      }
    } catch (e) { Navigator.pop(context); }
  }

  void _mostrarModalServidores(List<Map> servers, String titulo, bool paraDownload) {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(paraDownload ? "Escolha o Servidor para Baixar" : "Escolha o Servidor para Assistir", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              ...servers.map((s) {
                if (paraDownload && !s['isMp4']) return const SizedBox.shrink(); // Esconde M3U8 no download
                return Card(
                  color: s['isMp4'] ? const Color(0xFF153a1d) : Colors.black,
                  shape: RoundedRectangleBorder(side: BorderSide(color: s['isMp4'] ? Colors.green : Colors.grey[800]!), borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    leading: Icon(paraDownload ? Icons.download : (s['isMp4'] ? Icons.ondemand_video : Icons.stream), color: s['isMp4'] ? Colors.greenAccent : Colors.red),
                    title: Text(s['idioma'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(s['isMp4'] ? "Premium (MP4)" : "Normal (M3U8)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (paraDownload) {
                        DownloadManager.startDownload(s['url'], titulo, true);
                      } else {
                        setState(() { videoTocandoUrl = s['url']; isPlaying = true; epSelecionadoNome = titulo; });
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
    List<String> history = prefs.getStringList('history') ?? [];
    Map<String, dynamic> item = {'id': widget.tmdbId, 'title': widget.title, 'type': widget.type, 'poster_path': widget.posterPath, 'date': DateTime.now().toIso8601String()};
    history.removeWhere((e) => json.decode(e)['id'] == widget.tmdbId);
    history.insert(0, json.encode(item));
    await prefs.setStringList('history', history);
  }

  @override
  Widget build(BuildContext context) {
    // PLAYER PROFISSIONAL PLYR.IO + HLS.JS
    String htmlPlayerPro = """
      <!DOCTYPE html>
      <html lang="pt-br">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <link rel="stylesheet" href="https://cdn.plyr.io/3.7.8/plyr.css" />
        <style>body, html { margin: 0; padding: 0; background: #000; height: 100vh; overflow: hidden; } 
               :root { --plyr-color-main: #E50914; } /* Cor Vermelha Netflix */
               video { width: 100%; height: 100%; object-fit: contain; }
        </style>
      </head>
      <body>
        <video id="player" controls crossorigin playsinline></video>
        <script src="https://cdn.plyr.io/3.7.8/plyr.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
        <script>
          document.addEventListener('DOMContentLoaded', () => {
            const video = document.getElementById('player');
            const source = "$videoTocandoUrl";
            const defaultOptions = { controls: ['play-large', 'play', 'progress', 'current-time', 'mute', 'volume', 'settings', 'pip', 'fullscreen'], settings: ['speed'] };
            
            if (Hls.isSupported() && source.includes('.m3u8')) {
              const hls = new Hls();
              hls.loadSource(source);
              hls.attachMedia(video);
              window.player = new Plyr(video, defaultOptions);
              hls.on(Hls.Events.MANIFEST_PARSED, function() { window.player.play(); });
            } else {
              video.src = source;
              window.player = new Plyr(video, defaultOptions);
              window.player.play();
            }
          });
        </script>
      </body>
      </html>
    """;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontSize: 16))),
      body: Column(
        children: [
          // ================= ÁREA DO VÍDEO =================
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
                    if (widget.posterPath != null) CachedNetworkImage(imageUrl: "https://image.tmdb.org/t/p/w780${widget.posterPath}", fit: BoxFit.cover, alignment: Alignment.topCenter),
                    Container(color: Colors.black.withOpacity(0.7)),
                    if (_isScraping)
                      const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.red), SizedBox(height: 10), Text("Buscando no servidor...", style: TextStyle(color: Colors.white))]))
                    else if (smartPlayId.isNotEmpty && smartPlayType == 'filmes')
                      Center(child: IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 70), onPressed: () => _abrirServidores(smartPlayId, widget.title, false)))
                    else if (smartPlayId.isNotEmpty && smartPlayType != 'filmes')
                      const Center(child: Text("Selecione um episódio abaixo", style: TextStyle(color: Colors.white, fontSize: 16)))
                    else
                      const Center(child: Text("Mídia não encontrada no servidor principal.", style: TextStyle(color: Colors.grey))),
                  ],
                ),
          ),

          // EXTRACTOR INVISÍVEL (Mantém o sistema funcionando)
          if (smartPlayType != 'filmes' && smartPlayId.isNotEmpty)
            SizedBox(
              height: 1, width: 1,
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
                initialUrlRequest: URLRequest(url: WebUri("$smartPlayUrl/posts/$smartPlayType/post/$smartPlayId")),
                onWebViewCreated: (c) => webExtractor = c,
                onLoadStop: (c, u) { _onExtratorLoaded(); _extrairEpisodiosDaTela(); },
              ),
            ),

          // ================= ÁREA DE INFOS E EPISÓDIOS =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título, Nota e Botões de Ação
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
                                Text(nota.toStringAsFixed(1), style: const TextStyle(fontSize: 16, color: Colors.white70)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Botão Baixar (Filmes)
                      if (smartPlayId.isNotEmpty && smartPlayType == 'filmes')
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          icon: const Icon(Icons.download, color: Colors.white), label: const Text("Baixar", style: TextStyle(color: Colors.white)),
                          onPressed: () => _abrirServidores(smartPlayId, widget.title, true),
                        )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Sinopse
                  if (_isLoadingInfo)
                    Shimmer.fromColors(baseColor: Colors.grey[800]!, highlightColor: Colors.grey[700]!, child: Container(height: 60, color: Colors.white))
                  else
                    Text(sinopse, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 20),

                  // TEMPORADAS E EPISÓDIOS (Séries)
                  if (smartPlayType != 'filmes' && temporadas.isNotEmpty) ...[
                    const Divider(color: Colors.white24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.grey[900],
                          value: tempSelecionada,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['nome']))).toList(),
                          onChanged: (val) {
                            if (val != null) { setState(() { tempSelecionada = val; _isScraping = true; }); _carregarEpisodiosJS(val); }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Lista de Episódios em Blocos
                    if (episodios.isEmpty && _isScraping)
                      const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                    else
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: episodios.length,
                          itemBuilder: (ctx, i) {
                            var ep = episodios[i];
                            bool isAtivo = epSelecionadoNome == "${widget.title} - ${ep['full_nome']}";
                            return GestureDetector(
                              onTap: () => _abrirServidores(ep['id'], "${widget.title} - ${ep['full_nome']}", false),
                              onLongPress: () => _abrirServidores(ep['id'], "${widget.title} - ${ep['full_nome']}", true), // Segurar para baixar
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
                    const Text("Dica: Segure o dedo em um episódio para BAIXAR.", style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
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
// 3. UI ORIGINAL RESTAURADA (Carrossel, Grid, Shimmer)
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
    String url = widget.category == 'movie' ? "https://api.themoviedb.org/3/trending/movie/day?api_key=$tmdbApiKey&language=pt-BR" 
               : widget.category == 'tv' ? "https://api.themoviedb.org/3/trending/tv/day?api_key=$tmdbApiKey&language=pt-BR" 
               : widget.category == 'anime' ? "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_genres=16&with_original_language=ja&sort_by=popularity.desc"
               : "https://api.themoviedb.org/3/discover/tv?api_key=$tmdbApiKey&language=pt-BR&with_original_language=ko&sort_by=popularity.desc";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        setState(() { trendingList = json.decode(res.body)['results']; trendingList.removeWhere((i) => i['backdrop_path'] == null); loading = false; });
      }
    } catch (e) {}
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
              options: CarouselOptions(height: 220, autoPlay: true, enlargeCenterPage: true, autoPlayCurve: Curves.fastOutSlowIn, viewportFraction: 0.85),
              items: trendingList.map((item) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(tmdbId: item['id'], title: item['title'] ?? item['name'], type: widget.category == 'movie' ? 'movie' : 'tv', posterPath: item['poster_path']))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), image: DecorationImage(image: NetworkImage("https://image.tmdb.org/t/p/w780${item['backdrop_path']}"), fit: BoxFit.cover)),
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: const LinearGradient(colors: [Colors.transparent, Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                      alignment: Alignment.bottomLeft, padding: const EdgeInsets.all(10),
                      child: Text(item['title'] ?? item['name'] ?? "", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

class SectionList extends StatefulWidget {
  final String title, url, category;
  const SectionList({super.key, required this.title, required this.url, required this.category});
  @override
  State<SectionList> createState() => _SectionListState();
}
class _SectionListState extends State<SectionList> {
  List items = [];
  @override
  void initState() { super.initState(); fetch(); }
  Future<void> fetch() async {
    try { final res = await http.get(Uri.parse(widget.url)); if (res.statusCode == 200) { if (mounted) setState(() { items = json.decode(res.body)['results']; items.removeWhere((i) => i['poster_path'] == null); }); } } catch (e) {}
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
              TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => GenreGridScreen(title: widget.title, url: widget.url, category: widget.category))), child: const Text("Ver mais", style: TextStyle(color: Color(0xFFE50914))))
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 10), itemCount: items.length,
            itemBuilder: (context, index) => Container(width: 110, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: items[index], category: widget.category)),
          ),
        ),
      ],
    );
  }
}

class GenreGridScreen extends StatefulWidget {
  final String title, url, category;
  const GenreGridScreen({super.key, required this.title, required this.url, required this.category});
  @override
  State<GenreGridScreen> createState() => _GenreGridScreenState();
}
class _GenreGridScreenState extends State<GenreGridScreen> {
  List items = []; bool loading = true; int _page = 1;
  @override
  void initState() { super.initState(); fetch(); }
  Future<void> fetch() async {
    try { final res = await http.get(Uri.parse("${widget.url}&page=$_page")); if (res.statusCode == 200) { if (mounted) setState(() { items.clear(); items.addAll(json.decode(res.body)['results']); items.removeWhere((i) => i['poster_path'] == null); loading = false; }); } } catch (e) { if(mounted) setState(() => loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: loading ? const Center(child: CircularProgressIndicator(color: Colors.red)) : Column(
        children: [
          Expanded(child: GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: items.length, itemBuilder: (context, index) => PosterCard(item: items[index], category: widget.category))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: () { setState(() { _page++; loading = true; }); fetch(); }, child: const Text("CARREGAR NOVOS FILMES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
          ),
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.red));
        List results = json.decode(snapshot.data!.body)['results'];
        results.removeWhere((i) => i['media_type'] == 'person' || i['poster_path'] == null);
        return GridView.builder(padding: const EdgeInsets.all(10), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), itemCount: results.length, itemBuilder: (c, i) => PosterCard(item: results[i], category: results[i]['media_type'] == 'movie' ? 'movie' : 'tv'));
      },
    );
  }
}

class PosterCard extends StatelessWidget {
  final dynamic item; final String category;
  const PosterCard({super.key, required this.item, required this.category});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(tmdbId: item['id'], title: item['title'] ?? item['name'], type: category == 'movie' ? 'movie' : 'tv', posterPath: item['poster_path']))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: "https://image.tmdb.org/t/p/w342${item['poster_path']}", fit: BoxFit.cover, width: double.infinity,
                placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[800]!, child: Container(color: Colors.black)),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(item['title'] ?? item['name'] ?? "", maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ==========================================
// 4. HISTÓRICO E DOWNLOADS
// ==========================================
class HistoryScreen extends StatefulWidget { const HistoryScreen({super.key}); @override State<HistoryScreen> createState() => _HistoryScreenState(); }
class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> history = [];
  @override
  void initState() { super.initState(); carregar(); }
  void carregar() async { final prefs = await SharedPreferences.getInstance(); setState(() => history = (prefs.getStringList('history') ?? []).map((e) => json.decode(e) as Map<String, dynamic>).toList()); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Histórico")),
      body: history.isEmpty ? const Center(child: Text("Você ainda não assistiu nada.", style: TextStyle(color: Colors.grey))) : ListView.builder(itemCount: history.length, itemBuilder: (c, i) {
        var item = history[i];
        return ListTile(
          leading: item['poster_path'] != null ? Image.network("https://image.tmdb.org/t/p/w92${item['poster_path']}") : const Icon(Icons.movie),
          title: Text(item['title'], style: const TextStyle(color: Colors.white)), subtitle: Text(item['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.grey)), trailing: const Icon(Icons.play_arrow, color: Colors.red),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => SuperPlayer(tmdbId: item['id'], title: item['title'], type: item['type'], posterPath: item['poster_path']))),
        );
      }),
    );
  }
}

class DownloadsScreen extends StatefulWidget { const DownloadsScreen({super.key}); @override State<DownloadsScreen> createState() => _DownloadsScreenState(); }
class _DownloadsScreenState extends State<DownloadsScreen> {
  List<String> files = [];
  @override
  void initState() { super.initState(); carregar(); }
  void carregar() async { final prefs = await SharedPreferences.getInstance(); setState(() => files = prefs.getStringList('downloads') ?? []); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meus Downloads")),
      body: files.isEmpty ? const Center(child: Text("Nenhum download concluído.", style: TextStyle(color: Colors.grey))) : ListView.builder(itemCount: files.length, itemBuilder: (c, i) {
        String name = files[i].split('/').last;
        return ListTile(leading: const Icon(Icons.video_file, color: Colors.greenAccent, size: 40), title: Text(name, style: const TextStyle(color: Colors.white)), subtitle: const Text("Salvo na Galeria/Downloads"), trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final prefs = await SharedPreferences.getInstance(); files.removeAt(i); prefs.setStringList('downloads', files); setState(() {}); }));
      }),
    );
  }
}
