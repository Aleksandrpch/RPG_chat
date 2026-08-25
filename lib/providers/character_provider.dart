import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/database_service.dart';

class CharacterProvider extends ChangeNotifier {
  List<Character> _characters = [];
  Character? _currentCharacter;
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;

  List<Character> get characters => _characters;
  Character? get currentCharacter => _currentCharacter;
  bool get isLoading => _isLoading;

  CharacterProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Вставляем default character ТОЛЬКО если БД пустая
      final existingCharacters = await _db.getCharacters();
      if (existingCharacters.isEmpty) {
        await _db.insertDefaultCharacter();
      }
      await loadCharacters();
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCharacters() async {
    try {
      _isLoading = true;
      _characters = await _db.getCharacters();
      notifyListeners();
    } catch (e) {
      print('Error loading characters: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCharacter(Character character) async {
    try {
      await _db.insertCharacter(character);
      await loadCharacters();
    } catch (e) {
      print('Error adding character: $e');
      rethrow;
    }
  }

  Future<void> deleteCharacter(String id) async {
    try {
      await _db.deleteCharacter(id);
      if (_currentCharacter?.id == id) {
        _currentCharacter = null;
        notifyListeners();
      }
      await loadCharacters();
    } catch (e) {
      print('Error deleting character: $e');
      rethrow;
    }
  }

  /// ← НОВЫЙ МЕТОД! Установить текущего персонажа
  void setCurrentCharacter(Character character) {
    _currentCharacter = character;
    notifyListeners();
  }

  /// ← НОВЫЙ МЕТОД! Очистить текущего персонажа
  void clearCurrentCharacter() {
    _currentCharacter = null;
    notifyListeners();
  }
}