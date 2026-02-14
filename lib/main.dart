import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

// --- O ENTREGADOR (ELE BUSCA O LINK LIMPO) ---
class Entregador {
  // Essa função vai na página bloqueada e rouba o link certo
  static Future<String> buscarLinkLimpo(int id, String tipo) async {
    String urlInicial = "https://superflixapi.one/$tipo/$id";
    
    try {
      // 1. O Entregador bate na porta (baixa o HTML da página)
      final response = await http.get(Uri.parse(urlInicial));
      
      if (response.statusCode == 200) {
        String html = response.body;

        // 2. O Entregador procura onde está escrito "src=" no HTML
        // Isso pega o link que estava dentro da caixinha do seu print
        RegExp exp = RegExp(r'src="([^"]+)"'); 
        Match? match = exp.firstMatch(html);

        if (match != null) {
          String linkAchado = match.group(1)!;
          // Limpa barras invertidas se houver
          linkAchado = linkAchado.replaceAll('\\', '');
          debugPrint("Entregador achou: $linkAchado");
          return linkAchado;
        }
      }
    } catch (e) {
      debugPrint("Entregador falhou: $e");
    }
    
    // Se não achar nada, retorna o link original mesmo
    return urlInicial;
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
    } catch (e) {
      debugPrint("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("CDCINE", 
          style: GoogleFonts.bebasNeue(color: Colors.red, fontSize: 35, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: loading 
        ? const Center(child: CircularProgressIndicator(color: Colors.red))
        : GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, 
              childAspectRatio: 0.7, 
              mainAxisSpacing: 10, 
              crossAxisSpacing: 10
            ),
            itemCount: movies.length,
            itemBuilder: (context, i) {
              final m = movies[i];
              final poster = "https://image.tmdb.org/t/p/w342${m['poster_path']}";
              
              return GestureDetector(
                onTap: () {
                  // Manda o entregador trabalhar antes de abrir a tela
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (c) => LoadingScreen(id: m['id'], title: m['title']))
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    poster,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[900], child: const Icon(Icons.movie)),
                  ),
                ),
              );
            },
          ),
    );
  }
}

// --- TELA DE CARREGAMENTO (ENQUANTO O ENTREGADOR TRABALHA) ---
class LoadingScreen extends StatefulWidget {
  final int id;
  final String title;
  const LoadingScreen({super.key, required this.id, required this.title});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    prepararEntrega();
  }

  void prepararEntrega() async {
    // Chama o entregador
    String urlFinal = await Entregador.buscarLinkLimpo(widget.id, 'filme');
    
    if (mounted) {
      // Quando o entregador voltar com o link, abre o Player
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerScreen(url: urlFinal, title: widget.title),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.red),
            SizedBox(height: 20),
            Text("O Entregador está buscando seu filme...", style: TextStyle(color: Colors.white)),
          ],
        ),
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
      ..setUserAgent("Mozilla/5.0 (Linux; Android 10; Mobile; rv:109.0) Gecko/109.0 Firefox/109.0")
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          // Permite carregar o vídeo
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 14)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.black, 
      body: WebViewWidget(controller: _controller)
    );
  }
}
