import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/database_service.dart';

class CharacterProvider extends ChangeNotifier {
  List<Character> _characters = [];
  Character? _currentCharacter;

  List<Character> get characters => _characters;
  Character? get currentCharacter => _currentCharacter;

  final DatabaseService _db = DatabaseService();

  CharacterProvider() {
    _db.insertDefaultCharacter();
    loadCharacters();
  }

  Future<void> loadCharacters() async {
    _characters = await _db.getCharacters();
    notifyListeners();
  }

  void setCurrentCharacter(Character character) {
    _currentCharacter = character;
    _updateLastPlayed(character.id);
    notifyListeners();
  }

  Future<void> _updateLastPlayed(String id) async {
    await _db.updateLastPlayed(id);
    await loadCharacters(); // обновляем список
  }

  Future<void> addCharacter(Character character) async {
    await _db.insertCharacter(character);
    await loadCharacters();
  }

  Future<void> deleteCharacter(String id) async {
    await _db.deleteCharacter(id);
    if (_currentCharacter?.id == id) {
      _currentCharacter = null;
    }
    await loadCharacters();
  }
}