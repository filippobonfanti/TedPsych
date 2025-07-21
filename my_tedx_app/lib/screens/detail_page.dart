import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/talk.dart';
import '../services/api_service.dart';
import 'tag_results_page.dart';

class DetailPage extends StatefulWidget {
  final Talk talk;

  const DetailPage({super.key, required this.talk});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late final WebViewController _controller;
  late Future<List<Talk>> relatedTalksFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.talk.url ?? 'https://www.ted.com'));

    relatedTalksFuture = apiService.getWatchNext(widget.talk.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar trasparente per dare risalto all'immagine
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. IMMAGINE DI COPERTINA ---
            if (widget.talk.imgUrl != null && widget.talk.imgUrl!.isNotEmpty)
              Image.network(
                widget.talk.imgUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 250,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              )
            else
              // Placeholder se non c'è l'immagine
              Container(
                height: 250,
                color: Colors.grey[850],
                child: const Center(
                  child: Icon(Icons.image_not_supported, size: 50),
                ),
              ),

            // --- 2. DETTAGLI, DESCRIZIONE E TAG ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.talk.title ?? 'Titolo non disponibile',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'di ${widget.talk.speakers ?? 'Speaker non disponibile'}',
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.talk.description ?? 'Nessuna descrizione.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (widget.talk.tags != null && widget.talk.tags!.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: widget.talk.tags!.map((tag) => ActionChip(
                        label: Text(tag),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TagResultsPage(tag: tag),
                            ),
                          );
                        },
                      )).toList(),
                    ),
                ],
              ),
            ),

            const Divider(thickness: 1, indent: 16, endIndent: 16),

            // --- 3. VIDEO PLAYER (WEBVIEW) ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Guarda il Talk',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: WebViewWidget(controller: _controller),
            ),
            
            const SizedBox(height: 16),
            const Divider(thickness: 1, indent: 16, endIndent: 16),

            // --- 4. VIDEO CORRELATI (WATCH NEXT) ---
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Potrebbe interessarti anche',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 220,
              child: FutureBuilder<List<Talk>>(
                future: relatedTalksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Impossibile caricare i video.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Nessun video correlato trovato.'));
                  }

                  final relatedTalks = snapshot.data!;
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: relatedTalks.length,
                    itemBuilder: (context, index) {
                      final relatedTalk = relatedTalks[index];
                      return SizedBox(
                        width: 160,
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => DetailPage(talk: relatedTalk)),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (relatedTalk.imgUrl != null && relatedTalk.imgUrl!.isNotEmpty)
                                  Image.network(
                                    relatedTalk.imgUrl!,
                                    height: 90,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, st) => Container(
                                      height: 90, color: Colors.grey[800],
                                      child: const Icon(Icons.videocam_off, color: Colors.white54),
                                    ),
                                  )
                                else
                                  Container(
                                    height: 90, color: Colors.grey[800],
                                    child: const Icon(Icons.videocam, color: Colors.white54),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    relatedTalk.title ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24), // Spazio extra in fondo
          ],
        ),
      ),
    );
  }
}