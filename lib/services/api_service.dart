Future<List<Character>> fetchCharacters(String worldId) async {
  final response = await http.get(Uri.parse('$baseUrl/world/$worldId/characters'));
  final List data = jsonDecode(response.body)['characters'];
  return data.map((json) => Character.fromJson(json)).toList();
}