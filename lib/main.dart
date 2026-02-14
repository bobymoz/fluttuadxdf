import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- CONFIGURAÇÃO ---
// COLE SUA CHAVE DO TMDB AQUI DENTRO DAS ASPAS
const String tmdbApiKey = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5YzMxYjNhZWIyZTU5YWEyY2FmNzRjNzQ1Y2UxNTg4NyIsIm5iZiI6MTc2NjA3MTQ0MC40MDMsInN1YiI6IjY5NDQxYzkwNjRhOWQ4N2RiYzcwNTZlNiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.Pa2-x5hvsHeepw5f70ffBGX9L-4AaU7NBYtp8qSTQDA'; 

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
        scaffoldBackgroundColor: const Color(0xFF141414), // Preto Netflix
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const HomeScreen(),
    );
  }
}

// --- TELA PRINCIPAL (LISTA DE FILMES) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    // Busca os filmes populares em PT-BR
    final url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$tmdbApiKey&language=pt-BR&page=1');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          movies = data['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erro: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("JINOCA",
            style: GoogleFonts.bebasNeue(color: Colors.red, fontSize: 30, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 Colunas
                childAspectRatio: 0.65, // Formato Cartaz
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return MovieCard(movie: movies[index]);
              },
            ),
    );
  }
}

// --- CARD DO FILME ---
class MovieCard extends StatelessWidget {
  final dynamic movie;
  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final posterPath = movie['poster_path'];
    final imageUrl = "https://image.tmdb.org/t/p/w500$posterPath";
    final title = movie['title'];
    final id = movie['id'];

    return GestureDetector(
      onTap: () {
        // Manda para o Player com a URL da SuperFlix montada
        // A SuperFlix usa o ID do TMDB, então casa perfeitamente!
        final superFlixUrl = "https://superflixapi.one/filme/$id";
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(url: superFlixUrl),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[900]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            // Sombra no título
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: const EdgeInsets.all(4),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- PLAYER DE VÍDEO (COM BLOQUEADOR DE ANÚNCIOS) ---
class PlayerScreen extends StatefulWidget {
  final String url;
  const PlayerScreen({super.key, required this.url});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // A REGRA DE OURO:
            // Se o link for do player (superflix), deixa passar.
            if (request.url.contains('superflixapi.one')) {
              return NavigationDecision.navigate;
            }
            // Se for qualquer outra coisa (popup, ads, bet), BLOQUEIA.
            print("Pop-up bloqueado: ${request.url}");
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            Positioned(
              top: 10, left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
