import 'dart:convert';
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
                onTap: () => Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (c) => PlayerScreen(id: m['id'], title: m['title']))
                ),
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

class PlayerScreen extends StatefulWidget {
  final int id;
  final String title;
  const PlayerScreen({super.key, required this.id, required this.title});
  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    
    // Configuração para evitar o bloqueio de "Visualização Externa"
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      // Simulando um navegador Chrome real no Android
      ..setUserAgent("Mozilla/5.0 (Linux; Android 13; SM-G991B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36")
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          if (req.url.contains('superflixapi.one')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent; // Bloqueia propagandas
        },
      ))
      // Enviando Referer para o servidor aceitar a conexão
      ..loadRequest(
        Uri.parse("https://superflixapi.one/filme/${widget.id}"),
        headers: {
          'Referer': 'https://superflixapi.one/',
          'Origin': 'https://superflixapi.one/',
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black, 
      body: WebViewWidget(controller: _controller)
    );
  }
}
