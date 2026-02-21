import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';

const String baseUrl = "https://smartplaylite.xn--n8ja5190f.mba";

void main() {
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

// ==========================================
// 1. TELA INICIAL (Scraper da Home e Busca)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, String>> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHome();
  }

  // Equivalente à Rota /api/home
  Future<void> _fetchHome() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(baseUrl),
        headers: {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0"},
      );
      _parseHtml(res.body);
    } catch (e) {
      debugPrint("Erro Home: $e");
      setState(() => isLoading = false);
    }
  }

  // Equivalente à Rota /api/search
  Future<void> _search(String q) async {
    if (q.isEmpty) { _fetchHome(); return; }
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/search/1?search=$q"),
        headers: {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"},
      );
      _parseHtml(res.body);
    } catch (e) {
      debugPrint("Erro Search: $e");
      setState(() => isLoading = false);
    }
  }

  // Extrator Regex (Igual ao Python)
  void _parseHtml(String html) {
    List<Map<String, String>> novosItens = [];
    Set<String> vistos = {};
    
    RegExp exp = RegExp(r'<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>', dotAll: true);
    for (var match in exp.allMatches(html)) {
      String id = match.group(3)!;
      if (!vistos.contains(id)) {
        vistos.add(id);
        novosItens.add({
          "imagem": match.group(1)!,
          "tipo": match.group(2)!,
          "id": id,
          "titulo": match.group(4)!.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
        });
      }
    }
    setState(() { items = novosItens; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 36, letterSpacing: 2)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar filmes, animes ou séries...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[900],
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onSubmitted: _search,
            ),
          ),
        ),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.red))
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              var item = items[i];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailsScreen(item: item))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: item['imagem']!, 
                          fit: BoxFit.cover, 
                          width: double.infinity,
                          errorWidget: (c, u, e) => Container(color: Colors.grey[800], child: const Icon(Icons.movie, color: Colors.white)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(4)),
                      child: Text(item['tipo']!.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    const SizedBox(height: 2),
                    Text(item['titulo']!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ],
                ),
              );
            },
          ),
    );
  }
}

// ==========================================
// 2. DETALHES, TEMPORADAS, EPISÓDIOS E SERVIDORES
// ==========================================
class DetailsScreen extends StatefulWidget {
  final Map<String, String> item;
  const DetailsScreen({super.key, required this.item});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  InAppWebViewController? webController;
  List<Map<String, String>> temporadas = [];
  List<Map<String, String>> episodios = [];
  bool isExtracting = true;
  String currentStatus = "Acessando servidor...";
  bool _extractingEpisodes = false;

  @override
  void initState() {
    super.initState();
    if (widget.item['tipo'] == 'filmes') {
      setState(() { isExtracting = false; currentStatus = "Filme pronto."; });
    }
  }

  // Executado quando a WebView invisível termina de carregar a página
  void _onWebViewLoaded() async {
    if (webController == null) return;

    if (_extractingEpisodes) {
      // MODO EXTRAÇÃO DE EPISÓDIOS (Rota /api/episodes)
      try {
        var epsRes = await webController!.evaluateJavascript(source: """
          (function(){
            var eps = [];
            var imgs = document.querySelectorAll("img[onclick*='loadEpisodePlayers']");
            for(var i=0; i<imgs.length; i++) {
              var oc = imgs[i].getAttribute('onclick');
              var m = oc.match(/loadEpisodePlayers\\('(\\d+)'/);
              if(m) eps.push({id: m[1], nome: imgs[i].getAttribute('alt')});
            }
            return JSON.stringify(eps);
          })();
        """);

        if (epsRes != null) {
          List eList = json.decode(epsRes.toString());
          setState(() {
            episodios = eList.map((e) => {"id": e['id'].toString(), "nome": e['nome'].toString()}).toList();
            isExtracting = false;
          });
        }
      } catch (e) {
        setState(() { currentStatus = "Erro ao ler episódios."; isExtracting = false; });
      }

    } else {
      // MODO EXTRAÇÃO DE TEMPORADAS (Rota /api/details)
      try {
        var seasonsRes = await webController!.evaluateJavascript(source: "window.CookieManager.get('seasons_${widget.item['id']}')");
        if (seasonsRes != null && seasonsRes.toString().isNotEmpty) {
          List sList = json.decode(seasonsRes.toString());
          List<Map<String, String>> tempT = [];
          for (int i = 0; i < sList.length; i++) {
            var s = sList[i];
            String tId = s['ID']?.toString() ?? s['id']?.toString() ?? s['seasonId']?.toString() ?? s['tmdbId']?.toString() ?? "";
            String tName = s['nome']?.toString() ?? s['name']?.toString() ?? "Temporada ${i + 1}";
            if (tId.isNotEmpty) tempT.add({"id": tId, "nome": tName});
          }
          if (tempT.isNotEmpty) {
            setState(() { temporadas = tempT; isExtracting = false; });
            return;
          }
        }

        // Se não tem temporadas (ex: alguns animes), extrai os episódios diretos
        _extractingEpisodes = true;
        _onWebViewLoaded();

      } catch (e) {
        setState(() { currentStatus = "Erro de extração."; isExtracting = false; });
      }
    }
  }

  void _fetchEpisodesFromSeason(String seasonId) {
    setState(() { 
      isExtracting = true; 
      currentStatus = "Carregando episódios..."; 
      episodios = []; 
      _extractingEpisodes = true; 
    });
    // Navega a WebView invisível para a página da temporada
    webController?.loadUrl(urlRequest: URLRequest(url: WebUri("$baseUrl/season/$seasonId/episodes")));
  }

  // =====================================
  // BUSCAR SERVIDORES E DETECTAR DUBLADO/LEGENDADO
  // =====================================
  Future<void> _fetchServersAndPlay(String idVideo, String videoTitle) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: Colors.red)));
    
    String tipo = widget.item['tipo']!;
    String urlApi = tipo == 'filmes' ? "$baseUrl/player/movie" : "$baseUrl/player/episode";
    Map payload = tipo == 'filmes' ? {"movie_id": idVideo, "action_type": "PLAY"} : {"ep_id": idVideo, "action_type": "PLAY"};

    try {
      final res = await http.post(
        Uri.parse(urlApi),
        headers: {"User-Agent": "Mozilla/5.0", "Content-Type": "application/json", "Referer": baseUrl},
        body: json.encode(payload),
      );
      
      Navigator.pop(context); // Fecha o loading
      var data = json.decode(res.body);
      
      if (data['success'] == true && data['players'] != null) {
        List players = data['players'];
        if (players.isEmpty) { _msg("Nenhum servidor retornou vídeo."); return; }
        
        List<Map<String, String>> serversTratados = [];
        
        // APLICAÇÃO DA INTELIGÊNCIA DO PYTHON
        for (var p in players) {
          String urlVideo = p["file"].toString().replaceAll("&amp;", "&");
          String tipoVideo = p["type"]?.toString() ?? "Video";
          String nomeOriginal = (p["title"] ?? p["name"] ?? "").toString();
          String idioma = "";

          // Identifica Dublado ou Legendado
          if (urlVideo.toLowerCase().contains("/dub/") || nomeOriginal.toLowerCase().contains("dub")) {
            idioma = "Dublado";
          } else if (urlVideo.toLowerCase().contains("/leg/") || nomeOriginal.toLowerCase().contains("leg")) {
            idioma = "Legendado";
          } else {
            idioma = nomeOriginal.isNotEmpty ? nomeOriginal : "Opção $tipoVideo";
          }

          serversTratados.add({
            "url": urlVideo,
            "tipo": tipoVideo,
            "idioma": idioma
          });
        }

        _showServersDialog(serversTratados, videoTitle);
      } else {
        _msg("Falha: O servidor recusou a entrega.");
      }
    } catch (e) {
      Navigator.pop(context);
      _msg("Erro de conexão com o servidor.");
    }
  }

  void _showServersDialog(List<Map<String, String>> players, String videoTitle) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Escolha um Servidor", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              ...players.map((p) {
                bool isMp4 = p['tipo']!.toUpperCase().contains("MP4");
                return Card(
                  color: isMp4 ? const Color(0xFF153a1d) : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: isMp4 ? Colors.green : Colors.grey[800]!),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: Icon(isMp4 ? Icons.ondemand_video : Icons.stream, color: isMp4 ? Colors.greenAccent : Colors.red),
                    title: Text(p['idioma']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(isMp4 ? "Formato: MP4 (Toca Liso)" : "Formato: M3U8 (Streaming)", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    trailing: const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(videoUrl: p['url']!, title: videoTitle, isMp4: isMp4)));
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

  void _msg(String txt) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(txt), backgroundColor: Colors.red));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.item['titulo']!)),
      body: Column(
        children: [
          // CABEÇALHO DO ITEM
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(imageUrl: widget.item['imagem']!, width: 120, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item['titulo']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(4)), child: Text(widget.item['tipo']!.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                      const SizedBox(height: 20),
                      if (widget.item['tipo'] == 'filmes')
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914), padding: const EdgeInsets.all(12)),
                          icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                          label: const Text("VER SERVIDORES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onPressed: () => _fetchServersAndPlay(widget.item['id']!, widget.item['titulo']!),
                        )
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(color: Colors.white24),

          // WEBVIEW OCULTA (Motor de Extração - O Playwright do Flutter)
          if (widget.item['tipo'] != 'filmes')
            SizedBox(
              height: 1, width: 1,
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
                initialUrlRequest: URLRequest(url: WebUri("$baseUrl/posts/${widget.item['tipo']}/post/${widget.item['id']}")),
                onWebViewCreated: (ctrl) => webController = ctrl,
                onLoadStop: (ctrl, url) => _onWebViewLoaded(),
              ),
            ),

          // ÁREA DE LISTAGEM (Temporadas e Episódios)
          Expanded(
            child: isExtracting 
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(color: Colors.red), const SizedBox(height: 10), Text(currentStatus, style: const TextStyle(color: Colors.grey))]))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (temporadas.isNotEmpty) ...[
                      const Text("Escolha a Temporada:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: temporadas.map((t) => ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900], side: const BorderSide(color: Colors.grey)),
                          onPressed: () => _fetchEpisodesFromSeason(t['id']!),
                          child: Text(t['nome']!, style: const TextStyle(color: Colors.white)),
                        )).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (episodios.isNotEmpty) ...[
                      const Text("Episódios:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      ...episodios.map((ep) => Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.play_circle_outline, color: Color(0xFFE50914), size: 30),
                          title: Text(ep['nome']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          onTap: () => _fetchServersAndPlay(ep['id']!, "${widget.item['titulo']} - ${ep['nome']}"),
                        ),
                      )).toList()
                    ]
                  ],
                ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// 3. TELA DE REPRODUÇÃO E DOWNLOAD
// ==========================================
class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  final bool isMp4;
  
  const PlayerScreen({super.key, required this.videoUrl, required this.title, required this.isMp4});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool isDownloading = false;
  double progress = 0;

  Future<void> _startDownload() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    setState(() { isDownloading = true; });

    try {
      final dir = Directory('/storage/emulated/0/Download');
      String safeTitle = widget.title.replaceAll(RegExp(r'[^\w\s]+'), '');
      String ext = widget.isMp4 ? "mp4" : "m3u8";
      final savePath = "${dir.path}/$safeTitle.$ext";

      await Dio().download(
        widget.videoUrl,
        savePath,
        options: Options(headers: {
          "Referer": baseUrl, 
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0"
        }),
        onReceiveProgress: (rec, total) {
          if (total != -1) setState(() => progress = rec / total);
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Salvo em: $savePath"), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao baixar: $e"), backgroundColor: Colors.red));
    } finally {
      setState(() { isDownloading = false; progress = 0; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // HTML customizado para o Player (Suporta MP4 nativo e M3U8 via hls.js igual ao seu frontend Python)
    String htmlPlayer = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
        <style>body, html { margin: 0; padding: 0; background: #000; height: 100%; display: flex; align-items: center; justify-content: center; overflow: hidden;} video { width: 100%; height: 100%; outline: none; }</style>
      </head>
      <body>
        <video id="video" controls autoplay playsinline></video>
        <script>
          var video = document.getElementById('video');
          var url = "${widget.videoUrl}";
          if (Hls.isSupported() && url.includes('.m3u8')) {
            var hls = new Hls();
            hls.loadSource(url);
            hls.attachMedia(video);
            hls.on(Hls.Events.MANIFEST_PARSED, function() { video.play(); });
          } else {
            video.src = url;
            video.play();
          }
        </script>
      </body>
      </html>
    """;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 14)),
        actions: [
          if (widget.isMp4) // Permite download se for MP4
            IconButton(
              icon: const Icon(Icons.download, color: Colors.greenAccent), 
              onPressed: isDownloading ? null : _startDownload,
              tooltip: "Baixar MP4",
            )
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
              ),
              initialData: InAppWebViewInitialData(data: htmlPlayer),
            ),
          ),
          if (isDownloading)
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF181818),
              child: Column(
                children: [
                  LinearProgressIndicator(value: progress, color: const Color(0xFFE50914), backgroundColor: Colors.grey[900]),
                  const SizedBox(height: 10),
                  Text("Baixando: ${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey, size: 40),
                const SizedBox(height: 10),
                Text(
                  widget.isMp4 
                    ? "Servidor Premium selecionado. Você pode baixar este vídeo no botão ⬇️ no topo."
                    : "Servidor Streaming (M3U8) selecionado. Download direto desativado. Se travar, volte e escolha outro servidor.",
                  style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
