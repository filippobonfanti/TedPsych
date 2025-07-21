import 'package:flutter/material.dart';
import 'models/talk.dart';
import 'services/api_service.dart';
import 'screens/detail_page.dart';
import 'screens/search_results_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TedPsych',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Talk>> latestTalksFuture;
  final ApiService apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> moods = [
    {'label': 'Triste', 'tag': 'depression'},
    {'label': 'Ansioso', 'tag': 'mental health'},
    {'label': 'Stressato', 'tag': 'stress'},
    {'label': 'Demotivato', 'tag': 'motivation'},
    {'label': 'Curioso', 'tag': 'curiosity'},
    {'label': 'Felice', 'tag': 'happiness'},
    {'label': 'Sorpreso', 'tag': 'discovery'},
    {'label': 'Rilassato', 'tag': 'mindfulness'},
    {'label': 'Confuso', 'tag': 'cognitive science'},
    {'label': 'Ispirato', 'tag': 'creativity'},
    {'label': 'Sconvolto', 'tag': 'PTSD'},
    {'label': 'Riflessivo', 'tag': 'philosophy'},
  ];

  bool _isRandomLoading = false;

  @override
  void initState() {
    super.initState();
    latestTalksFuture = apiService.fetchLatestTalks();
  }

  void _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final results = await apiService.searchTalks(_searchController.text);
      Navigator.pop(context); // Chiude dialogo

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            searchTerm: _searchController.text,
            searchResults: results,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Chiude dialogo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore durante la ricerca: ${e.toString()}')),
      );
    }
  }

  // --- ✨ FUNZIONE "SORPRENDIMI" COMPLETATA ---
  void _findRandomTalk() async {
    setState(() {
      _isRandomLoading = true;
    });

    try {
      final talk = await apiService.getRandomTalk();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailPage(talk: talk),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isRandomLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Imposta il titolo al centro
        centerTitle: true, 
        // Usa RichText per avere colori diversi nella stessa scritta.
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            children: <TextSpan>[
              TextSpan(text: 'Ted', style: TextStyle(color: Colors.red)),
              TextSpan(text: 'Psych', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: ElevatedButton.icon(
                icon: _isRandomLoading
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Icon(Icons.shuffle),
                label: const Text('Sorprendimi'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isRandomLoading ? null : _findRandomTalk,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cerca un talk...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _performSearch,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onSubmitted: (value) => _performSearch(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
              child: Text(
                'Esplora per Stato d\'Animo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moods.map((mood) {
                  return ElevatedButton(
                    onPressed: () async {
                      final results = await apiService.getTalksByTag(mood['tag']!);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchResultsPage(
                            searchTerm: mood['label']!,
                            searchResults: results,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(mood['label']!),
                  );
                }).toList(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Ultimi Talk',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 300,
              child: FutureBuilder<List<Talk>>(
                future: latestTalksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Errore: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final talks = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(8.0),
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
            ),
          ],
        ),
      ),
    );
  }
}