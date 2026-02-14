import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

// SUA CHAVE
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
        scaffoldBackgroundColor: const Color(0xFF000000),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List movies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&language=pt-BR&page=1'));
      if (response.statusCode == 200) {
        setState(() {
          movies = json.decode(response.body)['results'];
          loading = false;
        });
      }
    } catch (e) { debugPrint("Erro: $e"); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDCINE", style: GoogleFonts.bebasNeue(color: Colors.red, fontSize: 35)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.red))
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.7, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: movies.length,
            itemBuilder: (context, i) {
              final m = movies[i];
              final poster = "https://image.tmdb.org/t/p/w342${m['poster_path']}";
              return GestureDetector(
                onTap: () {
                  // Abre o Player Direto (Sem "Entregador" intermediário)
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => SuperPlayer(id: m['id'], title: m['title'])
                  ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: poster,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => Container(color: Colors.grey[900]),
                    errorWidget: (c, u, e) => const Icon(Icons.error),
                  ),
                ),
              );
            },
          ),
    );
  }
}

// --- O PLAYER BLINDADO (INAPPWEBVIEW) ---
class SuperPlayer extends StatefulWidget {
  final int id;
  final String title;
  const SuperPlayer({super.key, required this.id, required this.title});

  @override
  State<SuperPlayer> createState() => _SuperPlayerState();
}

class _SuperPlayerState extends State<SuperPlayer> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  // Configurações para FINGIR ser um navegador Chrome e passar no bloqueio
  InAppWebViewSettings settings = InAppWebViewSettings(
      isInspectable: true,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      iframeAllow: "camera; microphone; fullscreen",
      userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile; rv:109.0) Gecko/109.0 Firefox/109.0",
      javaScriptEnabled: true,
      useShouldOverrideUrlLoading: true, // Importante para bloquear popups
  );

  @override
  Widget build(BuildContext context) {
    // Monta a URL direta
    String url = "https://superflixapi.one/filme/${widget.id}";

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                url: WebUri(url),
                // AQUI ESTÁ A MÁGICA: O Referer diz "Eu sou o site SuperFlix"
                headers: {
                  'Referer': 'https://superflixapi.one/',
                  'Origin': 'https://superflixapi.one/',
                }
              ),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              
              // BLOQUEADOR DE ANÚNCIOS (POP-UPS)
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                
                // Se o link for do próprio video ou superflix, deixa abrir
                if (uri.toString().contains('superflixapi.one') || 
                    uri.toString().contains('cdn') || 
                    uri.toString().endsWith('.mp4')) {
                  return NavigationActionPolicy.ALLOW;
                }
                
                // Bloqueia todo o resto (Bet, Virus, Popups)
                debugPrint("Pop-up bloqueado: $uri");
                return NavigationActionPolicy.CANCEL;
              },

              // INJEÇÃO DE CSS (Para sumir com botões chatos se aparecerem)
              onLoadStop: (controller, url) async {
                await controller.evaluateJavascript(source: """
                  // Remove cabeçalhos, rodapés ou botões de fechar propaganda se existirem
                  var css = 'header, footer, .ads, .popup { display: none !important; }';
                  var style = document.createElement('style');
                  style.type = 'text/css';
                  style.appendChild(document.createTextNode(css));
                  document.head.appendChild(style);
                """);
              },
            ),

            // Botão de Voltar
            Positioned(
              top: 10, left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
