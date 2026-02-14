import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

// SUA CHAVE JÁ INSERIDA AQUI
const String tmdbApiKey = '9c31b3aeb2e59aa2caf74c745ce15887'; 

void main() {
  runApp(const JinocaApp());
}

class JinocaApp extends StatelessWidget {
  const JinocaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JINOCA',
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
      // Busca filmes populares em português usando sua chave
      final response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&language=pt-BR&page=1'));
      
      if (response.statusCode == 200) {
        setState(() {
          movies = json.decode(response.body)['results'];
          loading = false;
        });
      } else {
        print("Erro na API: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro de conexão: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JINOCA", 
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
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/loading.gif', // se não tiver, use um Container preto
                    image: poster,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (c, e, s) => Container(color: Colors.grey[900], child: const Icon(Icons.movie)),
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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (req) {
          // Bloqueador de Pop-ups
          if (req.url.contains('superflixapi.one')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse("https://superflixapi.one/filme/${widget.id}"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title, style: const TextStyle(fontSize: 16))),
      backgroundColor: Colors.black, 
      body: WebViewWidget(controller: _controller)
    );
  }
}
