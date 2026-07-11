// Импорт платформо-зависимых функций
import 'dart:io' show Platform;
// Импорт утилит для работы с путями
import 'package:path/path.dart';
// Импорт основного пакета для работы с SQLite
import 'package:sqflite/sqflite.dart';
// Импорт основных классов Flutter
import 'package:flutter/foundation.dart';
// Импорт FFI реализации для desktop платформ
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.html) '';
// Импорт модели сообщения
import '../models/message.dart';
// Импорт модели персонажа
import '../models/character.dart';
// Импорт модели чата
import '../models/chat.dart';
// Класс сервиса для работы с базой данных
class DatabaseService {
  // Единственный экземпляр класса (Singleton)
  static final DatabaseService _instance = DatabaseService._internal();
  // Экземпляр базы данных
  static Database? _database;

  // Фабричный метод для получения экземпляра
  factory DatabaseService() {
    return _instance;
  }

  // Приватный конструктор для реализации Singleton
  DatabaseService._internal();

  // Геттер для получения экземпляра базы данных
  Future<Database> get database async {
    if (_database != null) return _database!; // Возврат существующей БД
    _database = await _initDatabase(); // Инициализация новой БД
    return _database!;
  }
  
  
  Future<void> insertDefaultCharacter() async {
    try {
      final db = await database;
      
      // Проверяем, есть ли уже персонажи
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM characters'),
      ) ?? 0;
      
      if (count > 0) return; // если есть — пропускаем
      
      // Создаём базового персонажа
      final defaultCharacter = {
        'id': 'default_${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Странник',
        'backstory': 'Таинственный путник, пришедший из далёких земель...',
        'avatar_url': null,
        'visual_style': 'Dark Fantasy',
        'visual_description': 'Тёмный плащ, острый взгляд, старый меч за спиной.',
      };
      
      await db.insert('characters', defaultCharacter);
      print('✅ Базовый персонаж создан');
    } 
      catch (e) {
        debugPrint('Error inserting default character: $e');
      }
  }


  // Метод инициализации базы данных
  Future<Database> _initDatabase() async {
    // Инициализация FFI для desktop платформ
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Получение пути к базе данных
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'databases.db'); // Имя файла базы данных




    // Открытие/создание базы данных
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Создание таблиц при первом запуске
       
        // Таблица characters
        await db.execute('''
          CREATE TABLE characters (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            backstory TEXT,
            avatar_url TEXT,
            visual_style TEXT,
            visual_description TEXT
          )
        ''');

        // Таблица character_skills
        await db.execute('''
          CREATE TABLE character_skills (
            character_id TEXT,
            name TEXT,
            description TEXT,
            PRIMARY KEY (character_id, name),
            FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
          )
        ''');

        // Таблица character_achievements
        await db.execute('''
          CREATE TABLE character_achievements (
            character_id TEXT,
            name TEXT,
            description TEXT,
            earned_at TEXT,
            PRIMARY KEY (character_id, name),
            FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
          )
        ''');
         
        // Таблица chats
        await db.execute('''
       
        CREATE TABLE chats(
        id TEXT PRIMARY KEY,
        character_id TEXT,
        world_id TEXT,       
        last_played TEXT,
        name TEXT, 
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
        )
        ''');
        await db.execute('''
        CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id TEXT,
        sender_name TEXT,
        sender_avatar_url TEXT,
        chat_id TEXT,
        content TEXT,    
        timestamp TEXT, 
        tokens INTEGER, 
        cost REAL,
        FOREIGN KEY (chat_id) REFERENCES chats(id)  ON DELETE CASCADE
        )
        ''');
      
      },
    );
  }


 // ========== SKILLS ==========
 Future<void> insertSkill(String characterId, String name, String description) async {
  final db = await database;
  await db.insert(
    'character_skills',
    {
      'character_id': characterId,
      'name': name,
      'description': description,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
 }
 

 Future<List<Map<String, String>>> getSkills(String characterId) async {
  final db = await database;
  final result = await db.query(
    'character_skills',
    where: 'character_id = ?',
    whereArgs: [characterId],
  );
  return result.map((row) => {
    'name': row['name'] as String,
    'description': row['description'] as String,
  }).toList();
 }
 

/* Возможно пригодится потом если в игре будет возможность удаления скилла или что то такое
  Future<void> deleteSkill(String characterId, String name) async {
  final db = await database;
  await db.delete(
    'character_skills',
    where: 'character_id = ? AND name = ?',
    whereArgs: [characterId, name],
  );
 }*/
 

 // ========== ACHIEVEMENTS ==========
 Future<void> insertAchievement(String characterId, String name, String description) async {
  final db = await database;
  await db.insert(
    'character_achievements',
    {
      'character_id': characterId,
      'name': name,
      'description': description,
      'earned_at': DateTime.now().toIso8601String(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
 }

Future<List<Map<String, String>>> getAchievements(String characterId) async {
  final db = await database;
  final result = await db.query(
    'character_achievements',
    where: 'character_id = ?',
    whereArgs: [characterId],
  );
  return result.map((row) => {
    'name': row['name'] as String,
    'description': row['description'] as String,
  }).toList();
 }

/*Аналогично со способностями может пригодиться. (репутацию можно разрушить, а серию побед прервать)
Future<void> deleteAchievement(String characterId, String name) async {
  final db = await database;
  await db.delete(
    'character_achievements',
    where: 'character_id = ? AND name = ?',
    whereArgs: [characterId, name],
  );
 }*/


  // Метод сохранения сообщения в базу данных
  Future<void> saveMessage(ChatMessage message) async {
    try {
      final db = await database;
      // Вставка данных в таблицу messages
      await db.insert(
        'messages',
        {
          'content': message.content, // Текст сообщения
          'sender_id': message.senderId,
          'sender_name': message.senderName,
          'sender_avatar_url': message.senderAvatarUrl,
          'timestamp': message.timestamp.toIso8601String(), // Временная метка
          'chat_id' :message.chatId, //id чата
          'tokens': message.tokens, // Количество токенов
          'cost': message.cost, // Стоимость запроса
        },
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Стратегия при конфликтах
      );
    } catch (e) {
      debugPrint('Error saving message: $e'); // Логирование ошибок
    }
  }

  // Метод получения сообщений из базы данных
  Future<List<ChatMessage>> getMessages({int limit = 50}) async {
    try {
      final db = await database;
      // Запрос данных из таблицы messages
      final List<Map<String, dynamic>> maps = await db.query(
        'messages',
        orderBy: 'timestamp ASC', // Сортировка по времени
        limit: limit, // Ограничение количества записей
      );
      return maps.map((row) => ChatMessage.fromJson(row)).toList();
    } catch (e) {
      debugPrint('Error getting messages: $e'); // Логирование ошибок
      return []; // Возврат пустого списка в случае ошибки
    }
  }

  // Метод очистки истории сообщений
  Future<void> clearHistory() async {
    try {
      final db = await database;
      await db.delete('messages'); // Удаление всех записей из таблицы
    } catch (e) {
      debugPrint('Error clearing history: $e'); // Логирование ошибок
    }
  }
  Future<void> insertCharacter(Character character) async {
  try {
    final db = await database;
    await db.insert(
      'characters',
      {
        'id': character.id,
        'name': character.name,
        'backstory': character.backstory,
        'avatar_url':character.avatarUrl,
        'visual_style': character.visualStyle,
        'visual_description': character.visualDescription,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    debugPrint('Error inserting character: $e');
  }
}

// Получить все чаты
Future<List<Chat>> getChats() async {
  try {
    final db = await database;
    final maps = await db.query(
      'chats',
      orderBy: 'last_played DESC',
    );
    return maps.map((map) => Chat.fromJson(map)).toList();
  } catch (e) {
    debugPrint('Error getting characters: $e');
    return [];
  }
}

// Получить одного персонажа по ID
Future<Character?> getCharacter(String id) async {
  try {
    final db = await database;
    final maps = await db.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Character.fromJson(maps.first);
  } catch (e) {
    debugPrint('Error getting character: $e');
    return null;
  }
}

// Обновить время последней игры
Future<void> updateLastPlayed(String chat_id,) async {
  try {
    final db = await database;
    await db.update(
      'chats',
      {'last_played': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [chat_id],
    );
  } catch (e) {
    debugPrint('Error updating last played: $e');
  }
}

  // Удалить персонажа
  Future<void> deleteCharacter(String id) async {
    try {
      final db = await database;
      await db.delete('characters', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      debugPrint('Error deleting character: $e');
    }
    } 


  Future<List<Character>> getCharacters() async {
  try {
    final db = await database;
    final maps = await db.query('characters');
    return maps.map((map) => Character.fromJson(map)).toList();
    } catch (e) {
    debugPrint('Error getting characters: $e');
    return [];
    } 
  }
}
