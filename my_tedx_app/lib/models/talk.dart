// lib/models/talk.dart

class Talk {
  final String id;
  final String? slug;
  final String? speakers;
  final String? title;
  final String? url;
  final String? description;
  final String? duration;
  final String? presenter;
  final String? publishedAt;
  final String? imgUrl;       // <-- Il campo che mancava
  final List<String>? tags;
  final List<String>? relatedTalks;

  Talk({
    required this.id,
    this.slug,
    this.speakers,
    this.title,
    this.url,
    this.description,
    this.duration,
    this.presenter,
    this.publishedAt,
    this.imgUrl,             // <-- Aggiunto al costruttore
    this.tags,
    this.relatedTalks,
  });

  factory Talk.fromJson(Map<String, dynamic> json) {
    return Talk(
      id: json['_id'],
      slug: json['slug'],
      speakers: json['speakers'],
      title: json['title'],
      url: json['url'],
      description: json['description'],
      duration: json['duration'],
      presenter: json['presenter'],
      publishedAt: json['publishedAt'],
      imgUrl: json['img_url'], // <-- Mappato dal JSON
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      relatedTalks: json['related_talks'] != null ? List<String>.from(json['related_talks']) : null,
    );
  }
}