import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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
              return GestureDetector(
                onTap: () {
                  // Abre a tela que tem o "Navegador Fantasma"
                  Navigator.push(context, MaterialPageRoute(
                    builder: (c) => ScraperScreen(id: m['id'], title: m['title'], type: 'filme')
                  ));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network("https://image.tmdb.org/t/p/w342${m['poster_path']}", fit: BoxFit.cover),
                ),
              );
            },
          ),
    );
  }
}

// --- TELA DE RASPAGEM (O NAVEGADOR FANTASMA) ---
class ScraperScreen extends StatefulWidget {
  final int id;
  final String title;
  final String type; // 'filme' ou 'serie'
  
  const ScraperScreen({super.key, required this.id, required this.title, required this.type});

  @override
  State<ScraperScreen> createState() => _ScraperScreenState();
}

class _ScraperScreenState extends State<ScraperScreen> {
  late final WebViewController _hiddenController;
  String status = "Desbloqueando conteúdo...";
  bool linkFound = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    iniciarNavegadorFantasma();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  void iniciarNavegadorFantasma() {
    // URL que vamos acessar "escondido"
    String targetUrl = "https://superflixapi.one/${widget.type}/${widget.id}";

    _hiddenController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile; rv:109.0) Gecko/109.0 Firefox/109.0")
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          // Quando a página termina de carregar, começamos a procurar o link
          iniciarBusca();
        },
      ))
      ..loadRequest(Uri.parse(targetUrl));
  }

  void iniciarBusca() {
    // A cada 1 segundo, perguntamos ao navegador invisível se ele já achou o iframe
    _checkTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (linkFound) {
        timer.cancel();
        return;
      }

      try {
        // INJEÇÃO DE JAVASCRIPT: Procura o link dentro da página carregada
        final result = await _hiddenController.runJavaScriptReturningResult(
          "(function() { var ifr = document.querySelector('iframe'); return ifr ? ifr.src : ''; })();"
        );
        
        String linkLimpo = result.toString().replaceAll('"', '');

        // Verifica se achou um link válido (que não seja vazio ou a própria página)
        if (linkLimpo.isNotEmpty && linkLimpo.startsWith('http') && !linkLimpo.contains('superflixapi')) {
          timer.cancel();
          setState(() { linkFound = true; status = "Filme encontrado!"; });
          
          // Sucesso! Vai para o Player Real
          if (mounted) {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (c) => PlayerScreen(url: linkLimpo, title: widget.title)
            ));
          }
        }
      } catch (e) {
        // A página ainda pode estar carregando ou redirecionando
        print("Ainda procurando...");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. O CONTEÚDO VISÍVEL (LOADING)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.red),
                const SizedBox(height: 20),
                Text(status, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                const Text("Bypassing protection...", style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
          ),
          
          // 2. O NAVEGADOR INVISÍVEL (OFFSTAGE)
          // Ele existe, carrega o site, passa pelo Javascript, mas o usuário não vê.
          Offstage(
            offstage: true, // TRUE = Escondido
            child: SizedBox(
              width: 100, height: 100, // Tamanho qualquer, não importa
              child: WebViewWidget(controller: _hiddenController),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PLAYER FINAL ---
class PlayerScreen extends StatefulWidget {
  final String url;
  final String title;
  const PlayerScreen({super.key, required this.url, required this.title});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) => NavigationDecision.navigate,
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            Positioned(top:10, left:10, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)))
          ],
        )
      )
    );
  }
}
