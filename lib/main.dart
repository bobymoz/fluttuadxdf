import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

const String smartPlayUrl = "https://smartplaylite.xn--n8ja5190f.mba";
const String telegramUrl = "https://t.me/cdcine";
// Unity Ads
const String _unityGameId = "6077055"; // Android
const String _unityInterstitialId = "Cd";
const String _unityRewardedId = "Rewarded_Android";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const String _c1 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script>atOptions = {'key' : 'ea3ab4f496752035d9aba623fd8faad5','format' : 'iframe','height' : 50,'width' : 320,'params' : {}};</script><script src="https://www.highperformanceformat.com/ea3ab4f496752035d9aba623fd8faad5/invoke.js"></script></body></html>""";
const String _c2 = """<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1.0"><style>body { margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; background-color: transparent; overflow: hidden; }</style></head><body><script>atOptions = {'key' : '408e7bfeab9af6c469fca0766541b341','format' : 'iframe','height' : 250,'width' : 300,'params' : {}};</script><script src="https://www.highperformanceformat.com/408e7bfeab9af6c469fca0766541b341/invoke.js"></script></body></html>""";

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
  await UnityAds.init(
    gameId: _unityGameId,
    testMode: false,
    onComplete: () => debugPrint('Unity Ads inicializado'),
    onFailed: (error, msg) => debugPrint('Unity Ads erro: $msg'),
  );
  runApp(const CDcineApp());
}

// ==========================================
// SPLASH SCREEN
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.9, curve: Curves.easeIn)));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => const VersionGateScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
    });
  }

  @override void dispose() { _ctrl.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: const Color(0xFFE50914).withOpacity(0.4), blurRadius: 40, spreadRadius: 5)],
                    ),
                    child: ClipOval(child: Image.asset('assets/icon.png', fit: BoxFit.cover)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text("CDCINE", style: GoogleFonts.bebasNeue(color: const Color(0xFFE50914), fontSize: 52, letterSpacing: 6)),
                      const SizedBox(height: 6),
                      const Text("O melhor streaming gratuito", style: TextStyle(color: Colors.white38, fontSize: 13, letterSpacing: 1)),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(color: const Color(0xFFE50914).withOpacity(0.6), strokeWidth: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

// ... (todas as classes DownloadManager, CDcineApp, _ConnectivityGate, VersionGateScreen, DraggableDownloadOverlay, etc. permanecem iguais até a classe TransmitirTvScreen)

// MANTIVE APENAS ESTA VERSÃO da TransmitirTvScreen (a mais recente e completa)
class TransmitirTvScreen extends StatelessWidget {
  const TransmitirTvScreen({super.key});

  static const String _appUrl = 'https://play.google.com/store/apps/details?id=screen.mirroring.screenmirroring';

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B0F),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Transmitir para TV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header visual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1a0a0a), Color(0xFF0B0B0F)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4), width: 2),
                    ),
                    child: const Icon(Icons.cast, color: const Color(0xFFE50914), size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text("Vê o CDCINE na tua TV!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Usa o Miracast / Wi-Fi Direct para espelhar o teu ecrã na TV sem cabos.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Como fazer:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _passo(1, "Instala o app", "Descarrega o app gratuito 'Espelhar Celular na TV - Cast' na Play Store.", Icons.download_rounded),
                  _passo(2, "Liga à mesma rede", "Certifica-te que o teu telemóvel e a TV estão ligados ao mesmo Wi-Fi.", Icons.wifi),
                  _passo(3, "Abre o app", "Abre o 'Espelhar Celular na TV' e seleciona a tua TV na lista de dispositivos.", Icons.tv),
                  _passo(4, "Inicia o espelhamento", "Carrega em 'Iniciar Espelhamento' e aceita a ligação na TV.", Icons.screen_share),
                  _passo(5, "Reproduz no CDCINE", "Volta ao CDCINE, abre o vídeo e ele aparecerá automaticamente na TV!", Icons.play_circle_filled),

                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withOpacity(0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 18),
                        SizedBox(width: 10),
                        Expanded(child: Text("Funciona com qualquer SmartTV ou TV com Miracast/DLNA. Também compatível com Fire Stick e Chromecast.", style: TextStyle(color: Colors.blue, fontSize: 12, height: 1.5))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => launchUrl(Uri.parse(_appUrl), mode: LaunchMode.externalApplication),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFE50914), Color(0xFFb00610)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded, color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text("Baixar app gratuito", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(child: Text("Gratuito • Sem publicidade excessiva • Funciona offline", style: TextStyle(color: Colors.white30, fontSize: 11))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passo(int num, String titulo, String desc, IconData icone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFE50914).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4))),
            child: Center(child: Text('$num', style: const TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.bold, fontSize: 15))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(icone, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ]),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// As restantes classes (DmcaScreen, etc.) permanecem iguais ao final do teu ficheiro original
class DmcaScreen extends StatelessWidget {
  const DmcaScreen({super.key});

  Widget _dmcaItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: const Color(0xFFE50914).withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFE50914), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        title: const Text("DMCA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0B0B0F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.shield, color: Color(0xFFE50914), size: 28),
              const SizedBox(width: 10),
              Text("Notificação de violação de\ndireitos autorais",
                style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 22, letterSpacing: 1),
              ),
            ]),
            const SizedBox(height: 24),
            const Text(
              "Para enviar uma notificação de violação de direitos autorais ao ChauThanh.INFO, você precisará realizar os seguintes passos: (consulte seu advogado ou a Seção 512(c)(3) da Lei de Direitos Autorais para confirmar esses requisitos)",
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 20),
            _dmcaItem(Icons.person_outline, "Informações sobre a pessoa/empresa que reivindica os direitos autorais."),
            _dmcaItem(Icons.link, "Envio da identificação do material protegido por direitos autorais, fornecendo os URLs correspondentes."),
            _dmcaItem(Icons.contact_mail_outlined, "Informações que nos permitam entrar em contato com a empresa/empresa em questão, como e-mail, número de telefone ou endereço físico."),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE50914).withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Todas as informações acima devem ser enviadas para:",
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => launchUrl(Uri.parse("mailto:cdcine@horsefucker.org?subject=DMCA%20Notice"), mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.email_outlined, color: Colors.white),
                      label: const Text("Enviar notificação DMCA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Quaisquer outros meios de envio não serão aceitos e não receberão resposta.",
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Text(
                "O conteúdo protegido por direitos autorais será analisado em até 24 horas e removido em até 48 horas.",
                style: TextStyle(color: Colors.blue, fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Text(
                "Observe também que, de acordo com a Seção 512(f), qualquer pessoa que, conscientemente, declare falsamente que um material ou atividade infringe direitos autorais poderá ser responsabilizada.",
                style: TextStyle(color: Colors.orange, fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
