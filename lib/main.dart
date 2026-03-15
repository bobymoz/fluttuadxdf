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
import 'package:open_filex/open_filex.dart';

const String smartPlayUrl = "https://smartplaylite.xn--n8ja5190f.mba";
const String telegramUrl = "https://t.me/hackermol";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String _c1 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script>atOptions = {'key' : 'ea3ab4f496752035d9aba623fd8faad5','format' : 'iframe','height' : 50,'width' : 320,'params' : {}};</script><script src="https://www.highperformanceformat.com/ea3ab4f496752035d9aba623fd8faad5/invoke.js"></script></body></html>""";
const String _c2 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script>atOptions = {'key' : '408e7bfeab9af6c469fca0766541b341','format' : 'iframe','height' : 250,'width' : 300,'params' : {}};</script><script src="https://www.highperformanceformat.com/408e7bfeab9af6c469fca0766541b341/invoke.js"></script></body></html>""";

const String vastAdHtml = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <link rel="stylesheet" href="https://cdn.fluidplayer.com/v3/current/fluidplayer.min.css" type="text/css"/>
    <script src="https://cdn.fluidplayer.com/v3/current/fluidplayer.min.js"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body, html { width: 100%; height: 100%; background: black; overflow: hidden; }
        #fp-video { width: 100%; height: 100%; display: block; }
    </style>
</head>
<body>
    <video id="fp-video" playsinline>
        <source src="data:video/mp4;base64,AAAAHGZ0eXBtcDQyAAAAAG1wNDJpc29tAAAADmZyZWUAAAAIbWRhdA==" type="video/mp4"/>
    </video>
    <script>
        var player = fluidPlayer('fp-video', {
            layoutControls: {
                autoPlay: true,
                fillToContainer: true,
                allowTheatre: false,
                allowDownload: false,
                playButtonShowing: false,
                playPauseAnimation: false,
                mute: false
            },
            vastOptions: {
                adList: [{
                    roll: 'preRoll',
                    vastTag: 'https://vast.yomeno.xyz/vast?spot_id=1484231'
                }],
                allowVPAID: true,
                showProgressbarMarkers: false
            }
        });

        var isDone = false;
        function finishAd() {
            if (!isDone) {
                isDone = true;
                try { window.flutter_inappwebview.callHandler('adFinished'); } catch(e) {}
            }
        }

        player.on('vast.adEnd',   finishAd);
        player.on('vast.adSkip',  finishAd);
        player.on('vast.adError', finishAd);
        player.on('vast.noAd',    finishAd);

        // Segurança: se em 15s nada aconteceu, avanca
        setTimeout(finishAd, 15000);
    </script>
</body>
</html>
""";

const List<Map<String, String>> officialGenres = [
  {"nome": "Ação", "slug": "4", "img": "https://image.tmdb.org/t/p/w500/7WsyChQLEftFiDOVTGkv3hFpyyt.jpg"},
  {"nome": "Action & Adventure", "slug": "53", "img": "https://image.tmdb.org/t/p/w500/2rmK7mnchw9Xr3XdiTFSxTTLXqv.jpg"},
  {"nome": "Animação", "slug": "6", "img": "https://image.tmdb.org/t/p/w500/kwsE6M5H2ZOUdK1e102Lof9XbEv.jpg"},
  {"nome": "Aventura", "slug": "5", "img": "https://image.tmdb.org/t/p/w500/vI3aUGFluXROUfnigYw3yFesS2y.jpg"},
  {"nome": "Comédia", "slug": "8", "img": "https://image.tmdb.org/t/p/w500/8ZTVqvKDQ8emSGUEMjsS4yHAwrp.jpg"},
  {"nome": "Crime", "slug": "7", "img": "https://image.tmdb.org/t/p/w500/vVpEOvdxVBP2aV166j5Xlvb5Cdc.jpg"},
  {"nome": "Documentário", "slug": "50", "img": "https://image.tmdb.org/t/p/w500/nTvM4mhqNlHIvUkI1gVnW6XP7GG.jpg"},
  {"nome": "Dorama", "slug": "58", "img": "https://image.tmdb.org/t/p/w500/1RydiOa2H1jVvK2nQ95XfA4Y0bA.jpg"},
  {"nome": "Drama", "slug": "51", "img": "https://image.tmdb.org/t/p/w500/xXHZeb1ywGllIlks1c20jbuy8ql.jpg"},
  {"nome": "Faroeste", "slug": "52", "img": "https://image.tmdb.org/t/p/w500/xAUYWjKEXG8y22Q7tD2sB2k9M8h.jpg"},
  {"nome": "Ficção Científica", "slug": "12", "img": "https://image.tmdb.org/t/p/w500/zEqyD0SBt6HL7W9JQoWcbWCPv30.jpg"},
  {"nome": "Terror", "slug": "9", "img": "https://image.tmdb.org/t/p/w500/5kIGw1hLq8d5k0s5dGAKyP7f1E6.jpg"},
  {"nome": "Romance", "slug": "11", "img": "https://image.tmdb.org/t/p/w500/6mJrgL7Mi13XjJeGYJFlD6UEVQ7.jpg"}
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CDcineApp());
}

String cleanTitle(String input) {
  try {
    String text = Uri.decodeFull(input);
    Map<String, String> ents = {
      '&amp;':'&', '&#039;':"'", '&quot;':'"', '&#8211;':'-', '&#8217;':"'", 
      '&lt;':'<', '&gt;':'>', '&aacute;':'á', '&Aacute;':'Á', '&atilde;':'ã', 
      '&Atilde;':'Ã', '&acirc;':'â', '&Acirc;':'Â', '&agrave;':'à', '&Agrave;':'À', 
      '&eacute;':'é', '&Eacute;':'É', '&ecirc;':'ê', '&Ecirc;':'Ê', '&iacute;':'í', 
      '&Iacute;':'Í', '&oacute;':'ó', '&Oacute;':'Ó', '&otilde;':'õ', '&Otilde;':'Õ', 
      '&ocirc;':'ô', '&Ocirc;':'Ô', '&uacute;':'ú', '&Uacute;':'Ú', '&ccedil;':'ç', 
      '&Ccedil;':'Ç', '&ntilde;':'ñ', '&Ntilde;':'Ñ', '&iexcl;':'í'
    };
    ents.forEach((k, v) => text = text.replaceAll(k, v));
    return text.trim();
  } catch (e) {
    return input;
  }
}

Widget _buildCategoryHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(height: 1, width: 40, color: Colors.grey[800]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(title.toUpperCase(), style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.white, letterSpacing: 1)),
        ),
        Container(height: 1, width: 40, color: Colors.grey[800]),
      ],
    ),
  );
}

Widget _buildGridSkeleton() {
  return GridView.builder(
    padding: const EdgeInsets.all(10), 
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
    itemCount: 12, 
    itemBuilder: (c, i) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[900]!, 
        highlightColor: Colors.grey[800]!, 
        child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)))
      );
    }
  );
}

Widget _buildHorizontalSkeleton() {
  return SizedBox(
    height: 160,
    child: ListView.builder(
      scrollDirection: Axis.horizontal, 
      padding: const EdgeInsets.symmetric(horizontal: 10), 
      itemCount: 5,
      itemBuilder: (c, i) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[900]!, 
          highlightColor: Colors.grey[800]!, 
          child: Container(width: 105, margin: const EdgeInsets.only(right: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)))
        );
      }
    ),
  );
}

Widget _buildCarouselSkeleton() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!,
    child: Container(height: 250, margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12))),
  );
}

class DownloadManager {
  static ValueNotifier<double> progress = ValueNotifier(-1.0);
  static ValueNotifier<int> activeDownloadsCount = ValueNotifier(0);
  static ValueNotifier<bool> showFloatingOverlay = ValueNotifier(false);
  
  static String currentTitle = "";
  static CancelToken? cancelToken;

  static Future<void> startDownload(String url, String title, bool isMp4) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) await Permission.videos.request();

    currentTitle = cleanTitle(title);
    progress.value = 0.0;
    activeDownloadsCount.value = 1;
    showFloatingOverlay.value = true;
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
      activeDownloadsCount.value = 0;
      _salvarHistorico(savePath);
      Future.delayed(const Duration(seconds: 4), () { progress.value = -1.0; showFloatingOverlay.value = false; });
    } catch (e) {
      activeDownloadsCount.value = 0;
      if (e is DioException && CancelToken.isCancel(e)) { 
        progress.value = -1.0; 
        showFloatingOverlay.value = false; 
      } else { 
        progress.value = -3.0; 
        Future.delayed(const Duration(seconds: 4), () { progress.value = -1.0; showFloatingOverlay.value = false; }); 
      }
    }
  }

  static void hideOverlay() {
    showFloatingOverlay.value = false;
  }

  static void confirmCancelDownload(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text("Cancelar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text("Deseja cancelar a transferência?", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () { 
              cancelToken?.cancel(); 
              progress.value = -1.0; 
              activeDownloadsCount.value = 0;
              showFloatingOverlay.value = false;
              Navigator.pop(ctx); 
            },
            child: const Text("Sim", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void _salvarHistorico(String path) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> files = prefs.getStringList('downloads') ?? [];
    if (!files.contains(path)) { 
      files.add(path); 
      prefs.setStringList('downloads', files); 
    }
  }
}

class CDcineApp extends StatelessWidget {
  const CDcineApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'CDCINE PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0B0F),
        primaryColor: const Color(0xFFE50914),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0B0B0F), elevation: 0),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: { TargetPlatform.android: ZoomPageTransitionsBuilder(), TargetPlatform.iOS: CupertinoPageTransitionsBuilder() },
        ),
      ),
      builder: (context, child) => Stack(children: [child!, const DraggableDownloadOverlay()]),
      home: const MainScreen(),
    );
  }
}

class DraggableDownloadOverlay extends StatefulWidget {
  const DraggableDownloadOverlay({super.key});
  @override State<DraggableDownloadOverlay> createState() => _DraggableDownloadOverlayState();
}
class _DraggableDownloadOverlayState extends State<DraggableDownloadOverlay> {
  double bottomOffset = 80; 
  double leftOffset = 20;
  
  @override Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DownloadManager.showFloatingOverlay,
      builder: (context, show, child) {
        if (!show) return const SizedBox.shrink();
        
        return ValueListenableBuilder<double>(
          valueListenable: DownloadManager.progress,
          builder: (context, val, _) {
            if (val == -1.0) return const SizedBox.shrink();
            Color bgColor = Colors.grey[900]!; 
            String text = "A transferir: ${DownloadManager.currentTitle} ${(val * 100).toStringAsFixed(0)}%";
            Widget icon = SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: val, color: const Color(0xFFE50914), strokeWidth: 3));
            
            if (val == -2.0) { 
              bgColor = Colors.green[800]!; 
              text = "Transferência Concluída"; 
              icon = const Icon(Icons.check_circle, color: Colors.white); 
            } else if (val == -3.0) { 
              bgColor = Colors.red[800]!; 
              text = "Erro na Transferência"; 
              icon = const Icon(Icons.error, color: Colors.white); 
            }
            
            return Positioned(
              bottom: bottomOffset, left: leftOffset,
              child: GestureDetector(
                onPanUpdate: (details) { setState(() { bottomOffset -= details.delta.dy; leftOffset += details.delta.dx; }); },
                onTap: () { if (navigatorKey.currentState != null) navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const DownloadsScreen())); },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85, padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12), boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)]),
                    child: Row(
                      children: [
                        icon, const SizedBox(width: 15), 
                        Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey), 
                          onPressed: () {
                            if (val >= 0.0 && val <= 1.0) {
                              DownloadManager.hideOverlay();
                            } else {
                              DownloadManager.progress.value = -1.0;
                              DownloadManager.showFloatingOverlay.value = false;
                            }
                          }
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}

final Map<String, List<Map<String, String>>> _apiCache = {};

Future<List<Map<String, String>>> fetchScraperData(String url, {String? filterType}) async {
  if (_apiCache.containsKey(url)) {
    var list = _apiCache[url]!;
    if (filterType != null) return list.where((e) => e['tipo'] == filterType).toList();
    return list;
  }
  try {
    final res = await http.get(Uri.parse(url), headers: {"User-Agent": "Mozilla/5.0"});
    List<Map<String, String>> list = []; Set<String> vistos = {};
    RegExp exp = RegExp(r'''<article class="item[^>]*>.*?<img[^>]*src=["\']([^"\']+)["\'].*?<a href="/posts/([^/]+)/post/(\d+)">([^<]+)</a>''', dotAll: true);
    for (var match in exp.allMatches(res.body)) {
      String id = match.group(3)!; String tipo = match.group(2)!;
      if (!vistos.contains(id)) {
        vistos.add(id); 
        list.add({"imagem": match.group(1)!, "tipo": tipo, "id": id, "titulo": cleanTitle(match.group(4)!)});
      }
    }
    _apiCache[url] = list;
    if (filterType != null) return list.where((e) => e['tipo'] == filterType).toList();
    return list;
  } catch (e) { 
    return []; 
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  bool isSearching = false; 
  String searchQuery = "";

  void _onSearchSubmit(String val) { 
    setState(() { 
      searchQuery = val; 
      isSearching = val.isNotEmpty; 
    }); 
  }
  
  void _clearSearch() { 
    FocusScope.of(context).unfocus();
    setState(() { 
      _searchCtrl.clear(); 
      searchQuery = ""; 
      isSearching = false; 
    }); 
  }

  void _changeTab(int index) {
    setState(() { 
      _currentIndex = index; 
      isSearching = false; 
      _searchCtrl.clear(); 
      searchQuery = ""; 
    });
  }

  @override Widget build(BuildContext context) {
    final List<Widget> views = [
      InicioTab(key: const ValueKey("inicio"), onNavigate: _changeTab),
      const PaginatedCategoryView(key: ValueKey("filmes"), urlPattern: "$smartPlayUrl/posts/filmes/[PAGE]", filterType: "filmes", title: "Filmes"),
      const PaginatedCategoryView(key: ValueKey("series"), urlPattern: "$smartPlayUrl/posts/series/[PAGE]", filterType: "series", title: "Séries"),
      const PaginatedCategoryView(key: ValueKey("animes"), urlPattern: "$smartPlayUrl/posts/animes/[PAGE]", filterType: "animes", title: "Animes"),
      const GenerosView(key: ValueKey("generos")),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (isSearching) { 
          _clearSearch(); 
        } else if (_currentIndex != 0) { 
          _changeTab(0); 
        } else { 
          SystemNavigator.pop(); 
        }
      },
      child: Scaffold(
        drawer: Drawer(
          width: 250, backgroundColor: const Color(0xFF121212),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xFFE50914)), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        mainAxisAlignment: MainAxisAlignment.end, 
                        children: [
                          Text("CDCINE", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)), 
                          Text("O melhor conteúdo.", style: TextStyle(color: Colors.white70, fontSize: 12))
                        ]
                      )
                    ),
                    ListTile(
                      leading: const Icon(Icons.send, color: Colors.blueAccent), 
                      title: const Text('Nosso Telegram', style: TextStyle(color: Colors.white)), 
                      onTap: () { launchUrl(Uri.parse(telegramUrl), mode: LaunchMode.externalApplication); }
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16), width: double.infinity, color: Colors.black,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [Icon(Icons.shield, color: Colors.grey, size: 16), SizedBox(width: 8), Text("DMCA / Direitos de Autor", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12))]),
                    SizedBox(height: 8),
                    Text("Nós não hospedamos ficheiros. O conteúdo é acedido através de motores de busca públicos em servidores de terceiros. Para denúncias, contacte-nos no Telegram: @hackermol", style: TextStyle(color: Colors.white54, fontSize: 10, height: 1.5)),
                  ],
                ),
              )
            ],
          ),
        ),
        appBar: AppBar(
          leadingWidth: 100, 
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Builder(builder: (c) => IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => Scaffold.of(c).openDrawer())),
              IconButton(icon: const Icon(Icons.history, color: Colors.white), tooltip: "Histórico", onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HistoryScreen()))),
            ],
          ),
          title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 32, letterSpacing: 2)),
          centerTitle: true,
          actions: [
            ValueListenableBuilder<int>(
              valueListenable: DownloadManager.activeDownloadsCount,
              builder: (context, count, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white), 
                      tooltip: "Downloads", 
                      onPressed: () { 
                        DownloadManager.showFloatingOverlay.value = true; 
                        Navigator.push(context, MaterialPageRoute(builder: (c) => const DownloadsScreen())); 
                      }
                    ),
                    if (count > 0)
                      Positioned(
                        right: 8, top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4), 
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      )
                  ],
                );
              }
            ),
            const SizedBox(width: 5),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                height: 42,
                child: TextField(
                  controller: _searchCtrl, 
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Procurar conteúdo...", 
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true, fillColor: Colors.grey[900],
                    prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    suffixIcon: isSearching ? IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: _clearSearch) : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onSubmitted: _onSearchSubmit,
                ),
              ),
            ),
          ),
        ),
        body: isSearching ? SearchResults(query: searchQuery) : IndexedStack(index: _currentIndex, children: views),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black, type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white, unselectedItemColor: Colors.grey[600],
          selectedFontSize: 10, unselectedFontSize: 10,
          currentIndex: _currentIndex,
          onTap: _changeTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Início"),
            BottomNavigationBarItem(icon: Icon(Icons.movie_creation_outlined), label: "Filmes"),
            BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: "Séries"),
            BottomNavigationBarItem(icon: Icon(Icons.animation), label: "Animes"),
            BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: "Gêneros"),
          ],
        ),
      ),
    );
  }
}

class InicioTab extends StatefulWidget {
  final Function(int) onNavigate;
  const InicioTab({super.key, required this.onNavigate});
  @override State<InicioTab> createState() => _InicioTabState();
}
class _InicioTabState extends State<InicioTab> with AutomaticKeepAliveClientMixin {
  List carouselItems = []; bool loading = true; int _currentCarouselIndex = 0; 
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _loadInitialData(); }
  void _loadInitialData() async {
    carouselItems = await fetchScraperData("$smartPlayUrl/posts/filmes/1"); 
    if (mounted) setState(() => loading = false);
  }

  @override Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loading) _buildCarouselSkeleton()
          else if (carouselItems.isNotEmpty)
            Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 220, autoPlay: true, enlargeCenterPage: true, viewportFraction: 0.45, 
                    onPageChanged: (index, reason) => setState(() => _currentCarouselIndex = index)
                  ),
                  items: carouselItems.map((item) {
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => PlayerScreen(item: item))),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(item['imagem']), fit: BoxFit.cover, alignment: Alignment.topCenter)),
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: const LinearGradient(colors: [Colors.transparent, Colors.black87], begin: Alignment.center, end: Alignment.bottomCenter)),
                          alignment: Alignment.bottomCenter, padding: const EdgeInsets.all(10),
                          child: Text(item['titulo'], textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: carouselItems.asMap().entries.map((entry) { 
                    return Container(width: 6.0, height: 6.0, margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(_currentCarouselIndex == entry.key ? 0.9 : 0.3))); 
                  }).toList()
                ),
              ],
            ),
          
          SectionWidget(title: "Lançamentos", urlPattern: "$smartPlayUrl/genre/1/[PAGE]"),
          SectionWidget(title: "Em Alta", urlPattern: "$smartPlayUrl/genre/3/[PAGE]"),
          
          SectionWidget(title: "Filmes", urlPattern: "$smartPlayUrl/posts/filmes/[PAGE]", filterType: "filmes", onSeeAll: () => widget.onNavigate(1)),
          SectionWidget(title: "Séries", urlPattern: "$smartPlayUrl/posts/series/[PAGE]", filterType: "series", onSeeAll: () => widget.onNavigate(2)),
          SectionWidget(title: "Animes", urlPattern: "$smartPlayUrl/posts/animes/[PAGE]", filterType: "animes", onSeeAll: () => widget.onNavigate(3)),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class PaginatedCategoryView extends StatefulWidget {
  final String urlPattern; final String filterType; final String title;
  const PaginatedCategoryView({super.key, required this.urlPattern, required this.filterType, required this.title});
  @override State<PaginatedCategoryView> createState() => _PaginatedCategoryViewState();
}

class _PaginatedCategoryViewState extends State<PaginatedCategoryView> with AutomaticKeepAliveClientMixin {
  List items = []; bool loading = true; int page = 1;
  @override bool get wantKeepAlive => true;

  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async {
    setState(() => loading = true);
    var newItems = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", page.toString()), filterType: widget.filterType);
    if(mounted) setState(() { items = newItems; loading = false; });
  }
  void _changePage(int direction) { if (page + direction > 0) { setState(() { page += direction; items.clear(); }); _fetch(); } }

  @override Widget build(BuildContext context) {
    super.build(context);
    if (loading && items.isEmpty) return _buildGridSkeleton();
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildCategoryHeader(widget.title)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10),
            delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: items[i]), childCount: items.length),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]), 
                  onPressed: page > 1 ? () => _changePage(-1) : null, 
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14), 
                  label: const Text("Anterior", style: TextStyle(color: Colors.white))
                ),
                Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), 
                  onPressed: items.length >= 10 ? () => _changePage(1) : null, 
                  icon: const Text("Próxima", style: TextStyle(color: Colors.white)), 
                  label: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14)
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class GenerosView extends StatelessWidget {
  const GenerosView({super.key});
  @override Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader("Gêneros"),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: officialGenres.length,
            itemBuilder: (context, index) {
              var genero = officialGenres[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => GridScreen(title: genero['nome']!, urlPattern: "$smartPlayUrl/genre/${genero['slug']}/[PAGE]"))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(imageUrl: genero['img']!, fit: BoxFit.cover),
                      Container(color: Colors.black.withOpacity(0.5)),
                      Center(child: Text(genero['nome']!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SectionWidget extends StatefulWidget {
  final String title; final String urlPattern; final String? filterType; final VoidCallback? onSeeAll;
  const SectionWidget({super.key, required this.title, required this.urlPattern, this.filterType, this.onSeeAll});
  @override State<SectionWidget> createState() => _SectionWidgetState();
}
class _SectionWidgetState extends State<SectionWidget> {
  List items = []; bool loading = true;
  @override void initState() { super.initState(); _fetchData(); }
  void _fetchData() async { 
    List res = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", "1"), filterType: widget.filterType); 
    if (mounted) setState(() { items = res; loading = false; }); 
  }
  @override Widget build(BuildContext context) {
    if (loading) { 
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
            child: Shimmer.fromColors(
              baseColor: Colors.grey[900]!, 
              highlightColor: Colors.grey[800]!, 
              child: Container(height: 20, width: 100, color: Colors.black)
            )
          ), 
          _buildHorizontalSkeleton()
        ]
      ); 
    }
    
    if (items.isEmpty) return const SizedBox.shrink();
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), 
                  Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                ]
              ),
              GestureDetector(
                onTap: widget.onSeeAll ?? () => Navigator.push(context, MaterialPageRoute(builder: (c) => GridScreen(title: widget.title, urlPattern: widget.urlPattern, filterType: widget.filterType))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                  decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(4)), 
                  child: const Text("VER MAIS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, 
            padding: const EdgeInsets.symmetric(horizontal: 10), 
            itemCount: items.length, 
            itemBuilder: (c, i) => Container(width: 105, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: items[i]))
          ),
        ),
      ],
    );
  }
}

class GridScreen extends StatefulWidget {
  final String title; final String urlPattern; final String? filterType;
  const GridScreen({super.key, required this.title, required this.urlPattern, this.filterType});
  @override State<GridScreen> createState() => _GridScreenState();
}
class _GridScreenState extends State<GridScreen> {
  List items = []; bool loading = true; int page = 1;
  @override void initState() { super.initState(); _fetch(); }
  void _fetch() async {
    setState(() => loading = true);
    var newItems = await fetchScraperData(widget.urlPattern.replaceAll("[PAGE]", page.toString()), filterType: widget.filterType);
    if(mounted) setState(() { items = newItems; loading = false; });
  }
  void _changePage(int direction) { if (page + direction > 0) { setState(() { page += direction; items.clear(); }); _fetch(); } }
  
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 28, letterSpacing: 1)), centerTitle: true),
      body: loading && items.isEmpty ? _buildGridSkeleton() : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildCategoryHeader(widget.title)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
              delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: items[i]), childCount: items.length)
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.black, padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900]), 
                    onPressed: page > 1 ? () => _changePage(-1) : null, 
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 14), 
                    label: const Text("Anterior", style: TextStyle(color: Colors.white))
                  ),
                  Text("Página $page", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE50914)), 
                    onPressed: items.length >= 10 ? () => _changePage(1) : null, 
                    icon: const Text("Próxima", style: TextStyle(color: Colors.white)), 
                    label: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14)
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SearchResults extends StatelessWidget {
  final String query;
  const SearchResults({super.key, required this.query});
  
  Future<List> _smartSearch() async {
    String safeQuery = Uri.encodeComponent(query);
    var res = await fetchScraperData("$smartPlayUrl/search/1?search=$safeQuery");
    if (res.isEmpty && query.contains(RegExp(r'[^\w\s]'))) {
      String fallback1 = query.replaceAll(RegExp(r'[^\w\s]'), '').trim();
      if (fallback1.isNotEmpty) res = await fetchScraperData("$smartPlayUrl/search/1?search=${Uri.encodeComponent(fallback1)}");
    }
    if (res.isEmpty && query.contains(" ")) {
      List<String> words = query.replaceAll(RegExp(r'[^\w\s]'), '').split(" ");
      words.removeWhere((w) => w.length <= 2); 
      if (words.isNotEmpty) {
        words.sort((a, b) => b.length.compareTo(a.length)); 
        String fallback2 = Uri.encodeComponent(words.first);
        res = await fetchScraperData("$smartPlayUrl/search/1?search=$fallback2");
      }
    }
    return res;
  }

  @override Widget build(BuildContext context) {
    return FutureBuilder(
      future: _smartSearch(),
      builder: (c, AsyncSnapshot<List> snapshot) {
        if (!snapshot.hasData) return _buildGridSkeleton();
        if (snapshot.data!.isEmpty) return const Center(child: Text("Nenhum resultado encontrado.", style: TextStyle(color: Colors.white)));
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildCategoryHeader("Resultados")),
            SliverPadding(
              padding: const EdgeInsets.all(10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.55, crossAxisSpacing: 10, mainAxisSpacing: 10), 
                delegate: SliverChildBuilderDelegate((c, i) => PosterCard(item: snapshot.data![i]), childCount: snapshot.data!.length)
              ),
            )
          ],
        );
      },
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
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: item['imagem'], fit: BoxFit.cover, width: double.infinity,
                placeholder: (c, u) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[800]!, child: Container(color: Colors.black)),
                errorWidget: (c, u, e) => Container(color: Colors.grey[900], child: const Icon(Icons.error)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(item['titulo'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text("${item['tipo'].toString().toUpperCase()}", style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ==========================================
// TELA DO PLAYER
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

  bool isDataLoaded = false;
  String sinopse = "";
  String backdrop = "";
  List temporadas = []; List episodios = [];
  String? tempSelecionada; String epAtivoNome = "";
  List recomendacoes = [];
  
  bool isPlaying = false;
  bool isServerLoading = false;
  bool isSynopsisExpanded = false;
  int _extracaoStatus = 0; 

  int savedPositionSeconds = 0;
  String? savedEpId;
  String? savedEpNome;
  bool _autoPlayDisparado = false;
  
  bool isShowingVastAd = false;
  Timer? _midRollTimer;
  bool _midRollDisparado = false;

  @override void initState() { 
    super.initState(); 
    _salvarHistoricoGeral(); 
    _fetchRecomendacoes(); 
    _checkResumeData(); 
  }

  @override void dispose() {
    _saveTimer?.cancel();
    _midRollTimer?.cancel();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

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
    var res = await fetchScraperData("$smartPlayUrl/posts/${widget.item['tipo']}/1", filterType: widget.item['tipo']);
    if(mounted) setState(() { recomendacoes = res.where((e) => e['id'] != widget.item['id']).take(6).toList(); });
  }

  void _onExtratorLoaded() async {
    if (webExtrator == null) return;
    try {
      if (_extracaoStatus == 0) {
        var dadosJs = await webExtrator!.evaluateJavascript(source: """
          (function() {
            var data = {sinopse: "Sinopse não disponível", backdrop: ""};
            var syn = document.querySelector('.synopsis'); if(syn) data.sinopse = syn.innerText;
            var bg = document.querySelector('.backdrop img'); if(bg) data.backdrop = bg.src;
            return JSON.stringify(data);
          })();
        """);
        if (dadosJs != null && mounted) {
          var d = json.decode(dadosJs.toString());
          sinopse = cleanTitle(d['sinopse']); backdrop = d['backdrop'] ?? widget.item['imagem'];
        }

        if (widget.item['tipo'] == 'filmes') {
           setState(() { isDataLoaded = true; }); 
           return;
        }

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
    } catch (e) { setState(() => isDataLoaded = true); } 
  }

  void _carregarEpisodiosUrl(String seasonId) {
    _extracaoStatus = 1;
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

        setState(() { isDataLoaded = true; }); 

        if (!_autoPlayDisparado && savedEpId != null && savedEpId!.isNotEmpty) {
          _autoPlayDisparado = true;
          _abrirServidores(savedEpId!, savedEpNome ?? "Episódio", false);
        }
      }
    } catch (e) { setState(() => isDataLoaded = true); }
  }

  Future<void> _abrirServidores(String idVideo, String nomeVideo, bool isParaDownload) async {
    if (savedEpId != null && savedEpId != idVideo) {
      savedPositionSeconds = 0;
    }

    if (!isParaDownload) {
      setState(() { isPlaying = true; isServerLoading = true; epAtivoNome = nomeVideo; savedEpId = idVideo; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A preparar a transferência...", style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue));
    }

    String urlApi = widget.item['tipo'] == 'filmes' ? "$smartPlayUrl/player/movie" : "$smartPlayUrl/player/episode";
    Map payload = widget.item['tipo'] == 'filmes' ? {"movie_id": idVideo, "action_type": "PLAY"} : {"ep_id": idVideo, "action_type": "PLAY"};

    try {
      final res = await http.post(Uri.parse(urlApi), headers: {"User-Agent": "Mozilla/5.0", "Content-Type": "application/json", "Referer": smartPlayUrl}, body: json.encode(payload));
      var data = json.decode(res.body);
      
      if (data['success'] == true && data['players'] != null) {
        List players = data['players'];
        if (players.isEmpty) { 
          if (!isParaDownload) setState(() { isServerLoading = false; isPlaying = false; }); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Servidores indisponíveis."))); 
          return; 
        }
        
        List<Map> servers = players.map((p) {
          String url = p["file"].toString().replaceAll("&amp;", "&");
          String tipo = p["type"]?.toString() ?? "Video";
          String name = cleanTitle((p["title"] ?? "").toString());
          String idioma = name;
          if (idioma.isEmpty || idioma.toLowerCase() == "video") {
            if (url.toLowerCase().contains("/dub/")) idioma = "Dublado";
            else if (url.toLowerCase().contains("/leg/")) idioma = "Legendado";
            else idioma = "Opção";
          }
          return {"url": url, "tipo": tipo, "idioma": idioma, "isMp4": tipo.toUpperCase().contains("MP4")};
        }).toList();

        Map? serverEscolhido = servers.cast<Map?>().firstWhere((s) => s!['isMp4'] == true && s['idioma'].toString().toLowerCase().contains('dublado'), orElse: () => null);
        serverEscolhido ??= servers.cast<Map?>().firstWhere((s) => s!['isMp4'] == true, orElse: () => null);
        serverEscolhido ??= servers.cast<Map?>().firstWhere((s) => s!['idioma'].toString().toLowerCase().contains('dublado'), orElse: () => null);
        serverEscolhido ??= servers.first;

        if (serverEscolhido == null) return; // segurança extra

        if (isParaDownload) {
          DownloadManager.startDownload(serverEscolhido['url'], nomeVideo, serverEscolhido['isMp4']);
        } else {
          // Inicia o vídeo direto — anúncio midRoll será exibido após 30s de reprodução
          _iniciarExoPlayer(serverEscolhido!['url'], nomeVideo);
        }
      }
    } catch (e) { 
      if (!isParaDownload) setState(() { isServerLoading = false; isPlaying = false; });
    }
  }

  void _iniciarExoPlayer(String url, String tituloEpisodio) async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url), httpHeaders: {"Referer": smartPlayUrl, "User-Agent": "Mozilla/5.0"});
    
    await _videoPlayerController!.initialize();

    if (savedPositionSeconds > 0) {
      await _videoPlayerController!.seekTo(Duration(seconds: savedPositionSeconds));
    }

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true, looping: false, aspectRatio: 16 / 9, 
      allowPlaybackSpeedChanging: true, showControlsOnInitialize: false,
      hideControlsTimer: const Duration(seconds: 2), 
      materialProgressColors: ChewieProgressColors(playedColor: const Color(0xFFE50914), handleColor: const Color(0xFFE50914), backgroundColor: Colors.grey[900]!, bufferedColor: Colors.white38),
    );
    
    setState(() => isServerLoading = false);
    _iniciarSalvamentoContinuo();

    // MidRoll: exibe anúncio após 30s de reprodução, uma única vez por vídeo
    if (!_midRollDisparado) {
      _midRollTimer?.cancel();
      _midRollTimer = Timer(const Duration(seconds: 30), () {
        if (mounted && _videoPlayerController != null && _videoPlayerController!.value.isPlaying) {
          _midRollDisparado = true;
          _videoPlayerController!.pause();
          setState(() => isShowingVastAd = true);
        }
      });
    }
  }

  void _salvarHistoricoGeral() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hist = prefs.getStringList('history') ?? [];
    Map<String, dynamic> it = {'id': widget.item['id'], 'title': widget.item['titulo'], 'type': widget.item['tipo'], 'poster_path': widget.item['imagem']};
    hist.removeWhere((e) => json.decode(e)['id'] == widget.item['id']);
    hist.insert(0, json.encode(it));
    await prefs.setStringList('history', hist);
  }

  Widget _buildPlayerSkeleton() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 24, width: 250, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 16),
                Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 8),
                Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 8),
                Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 12, width: 150, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 30),
                Row(children: List.generate(4, (index) => Padding(padding: const EdgeInsets.only(right: 10), child: Shimmer.fromColors(baseColor: Colors.grey[900]!, highlightColor: Colors.grey[800]!, child: Container(height: 45, width: 45, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6))))))),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Column(
        children: [
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
                  
                  // Camadas do player (sempre visíveis por baixo)
                  if (!isPlaying && widget.item['tipo'] == 'filmes')
                    Center(
                      child: IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Colors.white, size: 70), 
                        onPressed: () {
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
                    const Center(child: Text("Selecione um episodio abaixo", style: TextStyle(color: Colors.white, fontSize: 16))),
                  
                  if (isPlaying && isServerLoading)
                    Container(color: Colors.black.withOpacity(0.8), child: const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))),

                  if (isPlaying && !isServerLoading && _chewieController != null)
                    Chewie(controller: _chewieController!),

                  if (!isPlaying)
                    Positioned(top: 10, left: 10, child: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context))),

                  // Overlay do anuncio midRoll — aparece POR CIMA do Chewie, pausa o vídeo
                  if (isShowingVastAd)
                    InAppWebView(
                      initialData: InAppWebViewInitialData(data: vastAdHtml),
                      initialSettings: InAppWebViewSettings(
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                        transparentBackground: false,
                      ),
                      onWebViewCreated: (controller) {
                        controller.addJavaScriptHandler(handlerName: 'adFinished', callback: (args) {
                          setState(() => isShowingVastAd = false);
                          _videoPlayerController?.play();
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 1, width: 1, child: InAppWebView(initialSettings: InAppWebViewSettings(javaScriptEnabled: true), initialUrlRequest: URLRequest(url: WebUri("$smartPlayUrl/posts/${widget.item['tipo']}/post/${widget.item['id']}")), onWebViewCreated: (c) => webExtrator = c, onLoadStop: (c, u) { _onExtratorLoaded(); })),

          Expanded(
            child: !isDataLoaded 
              ? _buildPlayerSkeleton()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(cleanTitle(widget.item['titulo']), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
                          if (widget.item['tipo'] == 'filmes')
                            GestureDetector(
                              onTap: () => _abrirServidores(widget.item['id'], widget.item['titulo'], true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white12)),
                                child: const Row(children: [Icon(Icons.download, color: Colors.white, size: 16), SizedBox(width: 5), Text("BAIXAR", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))]),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 10),

                      Text("${widget.item['tipo'].toString().toUpperCase()}", style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 15),

                      GestureDetector(
                        onTap: () => setState(() => isSynopsisExpanded = !isSynopsisExpanded),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sinopse, maxLines: isSynopsisExpanded ? null : 3, overflow: isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                            if (sinopse.length > 150)
                              Padding(padding: const EdgeInsets.only(top: 5), child: Text(isSynopsisExpanded ? "Mostrar menos" : "Ver mais...", style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 12)))
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (widget.item['tipo'] != 'filmes' && temporadas.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              dropdownColor: Colors.grey[900], value: tempSelecionada,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              items: temporadas.map((t) => DropdownMenuItem<String>(value: t['id'], child: Text(t['nome']))).toList(),
                              onChanged: (val) { if (val != null) { setState(() { tempSelecionada = val; episodios.clear(); _extracaoStatus = 1; isDataLoaded = false; }); _carregarEpisodiosUrl(val); } },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      if (widget.item['tipo'] != 'filmes') ...[
                        if (episodios.isEmpty)
                          SizedBox(height: 45, child: ListView.builder(itemCount: 5, scrollDirection: Axis.horizontal, itemBuilder: (c,i) => Shimmer.fromColors(baseColor: Colors.grey[850]!, highlightColor: Colors.grey[700]!, child: Container(width: 45, margin: const EdgeInsets.only(right:10), decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6))))))
                        else
                          SizedBox(
                            height: 45,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal, itemCount: episodios.length,
                              itemBuilder: (ctx, i) {
                                var ep = episodios[i]; bool isAtivo = epAtivoNome == "${widget.item['titulo']} - ${ep['full_nome']}";
                                return GestureDetector(
                                  onTap: () => _abrirServidores(ep['id'], "${widget.item['titulo']} - ${ep['full_nome']}", false),
                                  onLongPress: () => _abrirServidores(ep['id'], "${widget.item['titulo']} - ${ep['full_nome']}", true), 
                                  child: Container(
                                    width: 45, margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(color: isAtivo ? const Color(0xFFE50914) : const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(6), border: Border.all(color: isAtivo ? Colors.transparent : Colors.white12)),
                                    child: Center(
                                      child: isAtivo 
                                        ? const Icon(Icons.play_arrow, color: Colors.white, size: 20) 
                                        : Text(ep['num'], style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.bold))
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.blue.withOpacity(0.3))),
                          child: const Row(children: [Icon(Icons.info_outline, color: Colors.blue, size: 16), SizedBox(width: 8), Expanded(child: Text("Dica: Segure num episódio longo para transferir.", style: TextStyle(color: Colors.blue, fontSize: 11)))]),
                        ),
                      ],

                      if (recomendacoes.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Row(children: [Container(width: 4, height: 18, color: const Color(0xFFE50914), margin: const EdgeInsets.only(right: 8)), const Text("Recomendações", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 160,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal, itemCount: recomendacoes.length,
                            itemBuilder: (ctx, i) {
                              var rec = recomendacoes[i];
                              return GestureDetector(
                                onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PlayerScreen(item: rec))),
                                child: Container(width: 105, margin: const EdgeInsets.only(right: 10), child: PosterCard(item: rec)),
                              );
                            },
                          ),
                        )
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
          title: Text(cleanTitle(item['title']), style: const TextStyle(color: Colors.white)), subtitle: Text(item['type'].toString().toUpperCase(), style: const TextStyle(color: Colors.grey)), trailing: const Icon(Icons.play_arrow, color: Colors.red),
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
                    trailing: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), tooltip: "Cancelar", onPressed: () => DownloadManager.confirmCancelDownload(context)),
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
                  return ListTile(
                    leading: const Icon(Icons.video_file, color: Colors.greenAccent, size: 40), 
                    title: Text(name, style: const TextStyle(color: Colors.white)), 
                    subtitle: const Text("Guardado na Galeria - Clique para ver"), 
                    trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async { final prefs = await SharedPreferences.getInstance(); files.removeAt(i); prefs.setStringList('downloads', files); setState(() {}); }),
                    onTap: () { OpenFilex.open(files[i]); },
                  );
                }),
          ),
        ],
      )
    );
  }
}
