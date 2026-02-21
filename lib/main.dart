import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

const String baseUrl = "https://smartplaylite.xn--n8ja5190f.mba";
const String telegramUrl = "https://t.me/cdcine";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CDcineApp());
}

// ==========================================
// GERENCIADOR DE DOWNLOADS GLOBAL
// ==========================================
class DownloadManager {
  static ValueNotifier<double> progress = ValueNotifier(-1.0);
  static String currentTitle = "";

  static Future<void> startDownload(String url, String title, bool isMp4) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    currentTitle = title;
    progress.value = 0.0;

    try {
      final dir = Directory('/storage/emulated/0/Download');
      String safeTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '');
      String ext = isMp4 ? "mp4" : "m3u8";
      final savePath = "${dir.path}/JINOCA_$safeTitle.$ext";

      await Dio().download(
        url,
        savePath,
        options: Options(headers: {
          "Referer": baseUrl,
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0"
        }),
        onReceiveProgress: (rec, total) {
          if (total != -1) progress.value = rec / total;
        },
      );
      // Sucesso
      progress.value = -2.0; 
      Future.delayed(const Duration(seconds: 3), () => progress.value = -1.0);
    } catch (e) {
      progress.value = -3.0; // Erro
      Future.delayed(const Duration(seconds: 3), () => progress.value = -1.0);
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
        scaffoldBackgroundColor: const Color(0xFF0F0F13), // Fundo UniTV Style
        primaryColor: const Color(0xFF0088CC),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0F0F13), elevation: 0),
      ),
      builder: (context, child) {
        // Overlay Global de Download
        return Stack(
          children: [
            child!,
            ValueListenableBuilder<double>(
              valueListenable: DownloadManager.progress,
              builder: (context, val, _) {
                if (val == -1.0) return const SizedBox.shrink();
                
                Color bgColor = Colors.blueGrey[900]!;
                String text = "Baixando: ${DownloadManager.currentTitle} ${(val * 100).toStringAsFixed(0)}%";
                Widget icon = SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: val, color: Colors.blue, strokeWidth: 3));

                if (val == -2.0) {
                  bgColor = Colors.green[800]!;
                  text = "Download Concluído!";
                  icon = const Icon(Icons.check_circle, color: Colors.white);
                } else if (val == -3.0) {
                  bgColor = Colors.red[800]!;
                  text = "Erro no Download!";
                  icon = const Icon(Icons.error, color: Colors.white);
                }

                return Positioned(
                  bottom: 20, left: 20, right: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)]),
                      child: Row(
                        children: [
                          icon, const SizedBox(width: 15),
                          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        ],
                      ),
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
// TELA INICIAL (Categorias e Carrossel)
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List filmes = [];
  List series = [];
  List animes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    setState(() => isLoading = true);
    filmes = await _fetchSection('filmes');
    series = await _fetchSection('series');
    animes = await _fetchSection('animes');
    setState(() => isLoading = false);
  }

  Future<List> _fetchSection(String tipo) async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/posts/$tipo/1"), headers: {"User-Agent": "Mozilla/5.0"});
      List novosItens = [];
      Set vistos = {};
      RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
      for (var match in exp.allMatches(res.body)) {
        String id = match.group(3)!;
        if (!vistos.contains(id)) {
          vistos.add(id);
          novosItens.add({"imagem": match.group(1)!, "tipo": match.group(2)!, "id": id, "titulo": match.group(4)!.replaceAll(RegExp(r'<[^>]*>'), '').trim()});
        }
      }
      return novosItens;
    } catch (e) { return []; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JINOCA", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
        actions: [
          IconButton(icon: const Icon(Icons.send, color: Colors.blue), onPressed: () => launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Buscar no multiverso...",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true, fillColor: const Color(0xFF1C1C24),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onSubmitted: (val) {
                if(val.isNotEmpty) Navigator.push(context, MaterialPageRoute(builder: (_) => GridScreen(titulo: "Busca: $val", tipo: "busca", query: val)));
              },
            ),
          ),
        ),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator(color: Colors.blue)) : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Filmes Populares", "filmes", filmes),
            _buildSection("Séries em Alta", "series", series),
            _buildSection("Animes Recentes", "animes", animes),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String tipo, List items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GridScreen(titulo: title, tipo: tipo))),
                child: const Text("Ver mais >", style: TextStyle(color: Colors.grey, fontSize: 14)),
              )
            ],
          ),
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 180, viewportFraction: 0.35, enlargeCenterPage: false, enableInfiniteScroll: false, padEnds: false,
          ),
          items: items.map((item) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerModernoScreen(item: item))),
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(imageUrl: item['imagem'], fit: BoxFit.cover, width: double.infinity),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(item['titulo'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ==========================================
// TELA DE GRID (Ver Mais / Busca / Paginação)
// ==========================================
class GridScreen extends StatefulWidget {
  final String titulo;
  final String tipo;
  final String query;
  const GridScreen({super.key, required this.titulo, required this.tipo, this.query = ""});
  @override
  State<GridScreen> createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  List items = [];
  int pagina = 1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMais();
  }

  Future<void> _carregarMais() async {
    String url = widget.tipo == 'busca' 
        ? "$baseUrl/search/$pagina?search=${widget.query}" 
        : "$baseUrl/posts/${widget.tipo}/$pagina";
    
    try {
      final res = await http.get(Uri.parse(url), headers: {"User-Agent": "Mozilla/5.0"});
      List novosItens = [];
      Set vistos = {};
      RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
      for (var match in exp.allMatches(res.body)) {
        String id = match.group(3)!;
        if (!vistos.contains(id)) {
          vistos.add(id);
          novosItens.add({"imagem": match.group(1)!, "tipo": match.group(2)!, "id": id, "titulo": match.group(4)!.replaceAll(RegExp(r'<[^>]*>'), '').trim()});
        }
      }
      setState(() { items.addAll(novosItens); isLoading = false; });
    } catch (e) { setState(() => isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo, style: const TextStyle(fontSize: 18))),
      body: isLoading && items.isEmpty ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                var item = items[i];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerModernoScreen(item: item))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(imageUrl: item['imagem'], fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          if (items.isNotEmpty && widget.tipo != 'busca') // Busca geralmente não pagina bem na fonte
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C1C24), minimumSize: const Size(double.infinity, 50)),
                onPressed: () { setState(() { pagina++; isLoading = true; }); _carregarMais(); },
                child: const Text("Carregar Mais", style: TextStyle(color: Colors.white)),
              ),
            )
        ],
      ),
    );
  }
}

// ==========================================
// TELA DO PLAYER AVANÇADO (Estilo UniTV)
// ==========================================
class PlayerModernoScreen extends StatefulWidget {
  final Map item;
  const PlayerModernoScreen({super.key, required this.item});
  @override
  State<PlayerModernoScreen> createState() => _PlayerModernoScreenState();
}

class _PlayerModernoScreenState extends State<PlayerModernoScreen> {
  InAppWebViewController? webExtratorController;
  
  // Dados do Item
  String sinopse = "Carregando informações...";
  List temporadas = [];
  List episodios = [];
  String? temporadaSelecionada;
  String epAtivo = "";
  
  // Estado do Player Front-end
  String urlVideoTocando = "";
  bool isPlaying = false;
  bool isMp4 = false;

  // Recomendações
  List recomendacoes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecomendacoes();
    if (widget.item['tipo'] == 'filmes') {
      sinopse = "Filme completo.";
    }
  }

  // Puxa algumas recomendações da mesma categoria
  Future<void> _fetchRecomendacoes() async {
    try {
      final res = await http.get(Uri.parse("$baseUrl/posts/${widget.item['tipo']}/1"), headers: {"User-Agent": "Mozilla/5.0"});
      List novos = [];
      RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
      for (var match in exp.allMatches(res.body)) {
        if (novos.length >= 6) break;
        if (match.group(3) != widget.item['id']) {
          novos.add({"imagem": match.group(1)!, "tipo": match.group(2)!, "id": match.group(3)!, "titulo": match.group(4)!.replaceAll(RegExp(r'<[^>]*>'), '').trim()});
        }
      }
      setState(() => recomendacoes = novos);
    } catch (e) {}
  }

  // WebView invisível que extrai temporadas e sinopse igual Playwright
  void _onExtratorLoaded() async {
    if (webExtratorController == null) return;
    try {
      // Tenta puxar a sinopse da página
      var sinopseHtml = await webExtratorController!.evaluateJavascript(source: "document.querySelector('.wp-content p') ? document.querySelector('.wp-content p').innerText : 'Sem descrição detalhada.'");
      if (sinopseHtml != null) setState(() => sinopse = sinopseHtml.toString());

      // Puxa Temporadas
      var seasonsRes = await webExtratorController!.evaluateJavascript(source: "window.CookieManager.get('seasons_${widget.item['id']}')");
      if (seasonsRes != null && seasonsRes.toString().isNotEmpty) {
        List sList = json.decode(seasonsRes.toString());
        List tempT = [];
        for (int i = 0; i < sList.length; i++) {
          var s = sList[i];
          String tId = s['ID']?.toString() ?? s['id']?.toString() ?? s['seasonId']?.toString() ?? s['tmdbId']?.toString() ?? "";
          String tName = s['nome']?.toString() ?? s['name']?.toString() ?? "Season ${i + 1}";
          if (tId.isNotEmpty) tempT.add({"id": tId, "nome": tName});
        }
        if (tempT.isNotEmpty) {
          setState(() { temporadas = tempT; temporadaSelecionada = tempT[0]['id']; });
          _carregarEpisodiosWebView(tempT[0]['id']);
          return;
        }
      }

      // Se não tem temporada, extrai direto
      _extrairEpisodiosDaPagina();

    } catch (e) {}
  }

  void _carregarEpisodiosWebView(String idTemp) {
    setState(() => episodios = []); // Limpa para carregar
    webExtratorController?.loadUrl(urlRequest: URLRequest(url: WebUri("$baseUrl/season/$idTemp/episodes")));
  }

  void _extrairEpisodiosDaPagina() async {
    try {
      var epsRes = await webExtratorController!.evaluateJavascript(source: """
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
          episodios = eList.map((e) {
            // Tenta pegar só o número do episódio para ficar igual a imagem (Blocos)
            String num = e['nome'].toString().replaceAll(RegExp(r'[^0-9]'), '');
            return {"id": e['id'].toString(), "nome": num.isNotEmpty ? num : "▶", "full_nome": e['nome'].toString()};
          }).toList();
        });
      }
    } catch (e) {}
  }

  // =====================================
  // SELEÇÃO DE SERVIDORES
  // =====================================
  Future<void> _abrirServidores(String idVideo, String nomeEpisodio) async {
    showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator(color: Colors.blue)));
    
    String tipo = widget.item['tipo'];
    String urlApi = tipo == 'filmes' ? "$baseUrl/player/movie" : "$baseUrl/player/episode";
    Map payload = tipo == 'filmes' ? {"movie_id": idVideo, "action_type": "PLAY"} : {"ep_id": idVideo, "action_type": "PLAY"};

    try {
      final res = await http.post(Uri.parse(urlApi), headers: {"User-Agent": "Mozilla/5.0", "Content-Type": "application/json", "Referer": baseUrl}, body: json.encode(payload));
      Navigator.pop(context);
      
      var data = json.decode(res.body);
      if (data['success'] == true && data['players'] != null) {
        List players = data['players'];
        if (players.isEmpty) return;
        
        List<Map> servers = players.map((p) {
          String url = p["file"].toString().replaceAll("&amp;", "&");
          String tipo = p["type"]?.toString() ?? "Video";
          String name = (p["title"] ?? p["name"] ?? "").toString();
          String idioma = (url.contains("/dub/") || name.toLowerCase().contains("dub")) ? "Dublado" : (url.contains("/leg/") || name.toLowerCase().contains("leg")) ? "Legendado" : name;
          return {"url": url, "tipo": tipo, "idioma": idioma};
        }).toList();

        _mostrarModalServidores(servers, nomeEpisodio);
      }
    } catch (e) { Navigator.pop(context); }
  }

  void _mostrarModalServidores(List<Map> servers, String tituloEpisodio) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Escolha um Servidor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              ...servers.map((s) {
                bool mp4 = s['tipo'].toString().toUpperCase().contains("MP4");
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(mp4 ? Icons.video_library : Icons.stream, color: mp4 ? Colors.green : Colors.blue),
                  title: Text(s['idioma'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(mp4 ? "Premium (Recomendado) - Suporta Download" : "Padrão (M3U8)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (mp4) IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(ctx);
                          DownloadManager.startDownload(s['url'], tituloEpisodio, true);
                        },
                      ),
                      const Icon(Icons.play_circle_fill, color: Colors.blue, size: 35),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() { urlVideoTocando = s['url']; isPlaying = true; isMp4 = mp4; epAtivo = tituloEpisodio; });
                  },
                );
              }).toList()
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ==========================================
          // 1. ÁREA DO PLAYER DE VÍDEO (TOPO)
          // ==========================================
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Colors.black,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (isPlaying)
                    InAppWebView(
                      initialSettings: InAppWebViewSettings(javaScriptEnabled: true, mediaPlaybackRequiresUserGesture: false, allowsInlineMediaPlayback: true),
                      initialData: InAppWebViewInitialData(data: """
                        <body style="margin:0;background:#000;display:flex;align-items:center;justify-content:center;overflow:hidden;">
                          <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
                          <video id="vid" controls autoplay playsinline style="width:100%;height:100%;outline:none;"></video>
                          <script>
                            var v=document.getElementById('vid'); var u="${urlVideoTocando}";
                            if(Hls.isSupported() && u.includes('.m3u8')){
                              var h=new Hls(); h.loadSource(u); h.attachMedia(v); h.on(Hls.Events.MANIFEST_PARSED,()=>v.play());
                            } else { v.src=u; v.play(); }
                          </script>
                        </body>
                      """),
                    )
                  else
                    Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(imageUrl: widget.item['imagem'], fit: BoxFit.cover, alignment: Alignment.topCenter),
                        Container(color: Colors.black.withOpacity(0.6)),
                        Center(
                          child: widget.item['tipo'] == 'filmes' 
                            ? IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 65), onPressed: () => _abrirServidores(widget.item['id'], widget.item['titulo']))
                            : const Text("Selecione um episódio abaixo", style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ),
                      ],
                    ),
                  
                  // Botão Voltar Transparente
                  Positioned(
                    top: 10, left: 10,
                    child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)]), onPressed: () => Navigator.pop(context)),
                  ),
                  
                  // Botão Download rápido no topo se MP4
                  if (isPlaying && isMp4)
                    Positioned(
                      top: 10, right: 10,
                      child: IconButton(icon: const Icon(Icons.download, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)]), onPressed: () => DownloadManager.startDownload(urlVideoTocando, epAtivo, true)),
                    )
                ],
              ),
            ),
          ),

          // WEBVIEW INVISÍVEL (Extrator)
          if (widget.item['tipo'] != 'filmes')
            SizedBox(
              width: 1, height: 1,
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
                initialUrlRequest: URLRequest(url: WebUri("$baseUrl/posts/${widget.item['tipo']}/post/${widget.item['id']}")),
                onWebViewCreated: (c) => webExtratorController = c,
                onLoadStop: (c, u) { _onExtratorLoaded(); _extrairEpisodiosDaPagina(); },
              ),
            ),

          // ==========================================
          // 2. INFORMAÇÕES E LISTAS (PARTE INFERIOR)
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO E INFOS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(widget.item['titulo'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                      const Icon(Icons.share, color: Colors.grey),
                      const SizedBox(width: 15),
                      const Icon(Icons.favorite_border, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("2024 | ${widget.item['tipo'].toString().toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 15),

                  // SELETOR DE TEMPORADA (Apenas Séries/Animes)
                  if (temporadas.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: const Color(0xFF1C1C24), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF1C1C24),
                          value: temporadaSelecionada,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['nome']))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => temporadaSelecionada = val);
                              _carregarEpisodiosWebView(val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // LISTA DE EPISÓDIOS (Blocos horizontais igual UniTV)
                  if (widget.item['tipo'] != 'filmes') ...[
                    if (episodios.isEmpty)
                      const Center(child: CircularProgressIndicator(color: Colors.blue))
                    else
                      SizedBox(
                        height: 55,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: episodios.length,
                          itemBuilder: (ctx, i) {
                            var ep = episodios[i];
                            bool isSelected = ep['full_nome'] == epAtivo;
                            return GestureDetector(
                              onTap: () => _abrirServidores(ep['id'], ep['full_nome']),
                              child: Container(
                                width: 55,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue : const Color(0xFF1C1C24),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(ep['nome'], style: TextStyle(color: isSelected ? Colors.white : Colors.grey[300], fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],

                  // SINOPSE
                  const Text("Sinopse", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(sinopse, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 30),

                  // RECOMENDAÇÕES (You may also like)
                  if (recomendacoes.isNotEmpty) ...[
                    const Text("Recomendações", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 170,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: recomendacoes.length,
                        itemBuilder: (ctx, i) {
                          var rec = recomendacoes[i];
                          return GestureDetector(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PlayerModernoScreen(item: rec))),
                            child: Container(
                              width: 110,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CachedNetworkImage(imageUrl: rec['imagem'], fit: BoxFit.cover, width: double.infinity))),
                                  const SizedBox(height: 5),
                                  Text(rec['titulo'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
