import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/talk.dart';

class ApiService {
  // URL unici per ogni funzione Lambda
  final String _latestTalksUrl = "https://1uavuicf1c.execute-api.us-east-1.amazonaws.com/default/Get_Latest_Talk";
  final String _searchUrl = "https://2n0by7joih.execute-api.us-east-1.amazonaws.com/default/Search_Talks";
  final String _watchNextUrl = "https://nxvks5hpsi.execute-api.us-east-1.amazonaws.com/default/Get_Watch_Next_by_Idx";
  final String _talksByTagUrl = "https://9ho5j34rsg.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_Tag";
  final String _randomTalkUrl = "https://9lnzhipdd7.execute-api.us-east-1.amazonaws.com/default/Get_Random_Talk";

  Future<List<Talk>> fetchLatestTalks() async {
    final response = await http.get(Uri.parse(_latestTalksUrl));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((talk) => Talk.fromJson(talk)).toList();
    } else {
      throw Exception('Failed to load latest talks');
    }
  }

  Future<List<Talk>> searchTalks(String searchTerm) async {
    final response = await http.post(
      Uri.parse(_searchUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'searchTerm': searchTerm}),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((talk) => Talk.fromJson(talk)).toList();
    } else {
      throw Exception('Failed to search talks');
    }
  }

  Future<List<Talk>> getWatchNext(String talkId) async {
    final response = await http.post(
      Uri.parse(_watchNextUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': talkId}),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((talk) => Talk.fromJson(talk)).toList();
    } else {
      throw Exception('Failed to get watch next');
    }
  }

  Future<List<Talk>> getTalksByTag(String tag) async {
    final response = await http.post(
      Uri.parse(_talksByTagUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'tag': tag}),
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((talk) => Talk.fromJson(talk)).toList();
    } else {
      throw Exception('Failed to load talks by tag');
    }
  }

  Future<Talk> getRandomTalk() async {
    final response = await http.get(Uri.parse(_randomTalkUrl));
    if (response.statusCode == 200) {
      return Talk.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load random talk');
    }
  }
}