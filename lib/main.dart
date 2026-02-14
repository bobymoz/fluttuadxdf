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
                  // Abre o Player com a lógica do Iframe
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

// --- O PLAYER QUE USA O TRUQUE DO EMBED ---
class SuperPlayer extends StatefulWidget {
  final int id;
  final String title;
  const SuperPlayer({super.key, required this.id, required this.title});

  @override
  State<SuperPlayer> createState() => _SuperPlayerState();
}

class _SuperPlayerState extends State<SuperPlayer> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    // 1. Construímos o link do vídeo
    String videoSrc = "https://superflixapi.one/filme/${widget.id}";
    
    // 2. Criamos o HTML localmente (O Site Falso)
    // Usamos CSS para garantir que o iframe ocupe a tela toda sem bordas
    String htmlContent = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body, html { margin: 0; padding: 0; height: 100%; background-color: #000; overflow: hidden; }
          iframe { width: 100%; height: 100%; border: none; }
        </style>
      </head>
      <body>
        <iframe 
          src="$videoSrc" 
          allow="autoplay; encrypted-media; picture-in-picture; fullscreen" 
          allowfullscreen>
        </iframe>
      </body>
      </html>
    """;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                useShouldOverrideUrlLoading: true, // Para bloquear popups
                userAgent: "Mozilla/5.0 (Linux; Android 10; Mobile; rv:109.0) Gecko/109.0 Firefox/109.0", // Finge ser Firefox
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
                
                // AQUI ESTÁ O SEGREDO MÁXIMO:
                // Carregamos o HTML criado acima, mas dizemos que a "Base URL" é o site deles.
                // Isso engana o servidor fazendo ele achar que o código está hospedado lá.
                controller.loadData(
                  data: htmlContent, 
                  mimeType: "text/html", 
                  encoding: "utf-8",
                  baseUrl: WebUri("https://superflixapi.one/") // O Pulo do Gato
                );
              },
              
              // Bloqueador de Anúncios
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                // Permite o vídeo e o domínio principal
                if (uri.toString().contains('superflixapi.one') || uri.toString().contains('cdn')) {
                  return NavigationActionPolicy.ALLOW;
                }
                debugPrint("Pop-up bloqueado: $uri");
                return NavigationActionPolicy.CANCEL;
              },
            ),

            // Botão Voltar
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
