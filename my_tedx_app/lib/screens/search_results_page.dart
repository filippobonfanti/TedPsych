import 'package:flutter/material.dart';
import '../models/talk.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchTerm;
  final List<Talk>? searchResults;

  const SearchResultsPage({
    super.key,
    required this.searchTerm,
    this.searchResults,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late Future<List<Talk>> _dataFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // La tua logica qui è eccellente: usa i dati passati se disponibili,
    // altrimenti li carica. È un'ottima pratica.
    if (widget.searchResults != null) {
      _dataFuture = Future.value(widget.searchResults!);
    } else {
      _dataFuture = apiService.searchTalks(widget.searchTerm);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Risultati per: "${widget.searchTerm}"'),
      ),
      body: FutureBuilder<List<Talk>>(
        future: _dataFuture,
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
            return const Center(child: Text('Nessun talk trovato.'));
          }
        },
      ),
    );
  }
}