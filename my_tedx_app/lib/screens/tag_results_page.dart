import 'package:flutter/material.dart';
import '../models/talk.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class TagResultsPage extends StatefulWidget {
  final String tag;

  const TagResultsPage({super.key, required this.tag});

  @override
  State<TagResultsPage> createState() => _TagResultsPageState();
}

class _TagResultsPageState extends State<TagResultsPage> {
  late Future<List<Talk>> talksByTagFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    talksByTagFuture = apiService.getTalksByTag(widget.tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Talk sul tema: "${widget.tag}"'),
      ),
      body: FutureBuilder<List<Talk>>(
        future: talksByTagFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final talks = snapshot.data!;
            return ListView.builder(
              itemCount: talks.length,
              itemBuilder: (context, index) {
                final talk = talks[index];
                return ListTile(
                  title: Text(talk.title ?? 'Titolo non disponibile'),
                  subtitle: Text(talk.speakers ?? 'Speaker non disponibile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(talk: talk),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('Nessun talk trovato per questo tag.'));
          }
        },
      ),
    );
  }
}