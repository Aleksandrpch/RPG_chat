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
        id TEXT PRIMARY KEY,
        CREATE TABLE chats(
        character_id TEXT,
        world_id TEXT,       
        last_played TEXT,
        name TEXT, 
        FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
        )
        ''')
        await db.execute('''
        CREATE TABLE messages(
        chat_id TEXT,
        content TEXT,
        is_user INTEGER,    
        timestamp TEXT, 
        tokens INTEGER, 
        cost REAL,
        FOREIGN KEY (chat_id) REFERENCES chats(id)  ON DELETE CASCADE
        )
        ''')
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
 

''' Возможно пригодится потом если в игре будет возможность удаления скилла или что то такое
  Future<void> deleteSkill(String characterId, String name) async {
  final db = await database;
  await db.delete(
    'character_skills',
    where: 'character_id = ? AND name = ?',
    whereArgs: [characterId, name],
  );
 }'''
 

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

'''Аналогично со способностями может пригодиться. (репутацию можно разрушить, а серию побед прервать)
Future<void> deleteAchievement(String characterId, String name) async {
  final db = await database;
  await db.delete(
    'character_achievements',
    where: 'character_id = ? AND name = ?',
    whereArgs: [characterId, name],
  );
 }'''


  // Метод сохранения сообщения в базу данных
  Future<void> saveMessage(ChatMessage message) async {
    try {
      final db = await database;
      final characterId = message.isUser 
        ? message.characterId           // сообщение игрока — свой ID
        : 'no_character';
      // Вставка данных в таблицу messages
      await db.insert(
        'messages',
        {
          'content': message.content, // Текст сообщения
          'is_user': message.isUser ? 1 : 0, // Преобразование bool в int
          'timestamp': message.timestamp.toIso8601String(), // Временная метка
          "chat_id" :message.chatId, //id чата
          'model_id': message.modelId, // Идентификатор модели
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

      // Преобразование данных в объекты ChatMessage
      return List.generate(maps.length, (i) {
        return ChatMessage(
          content: maps[i]['content'] as String, // Текст сообщения
          isUser: maps[i]['is_user'] == 1, // Преобразование int в bool
          timestamp:
              DateTime.parse(maps[i]['timestamp'] as String), // Временная метка
          chat_id=maps[i]['chat_id'] as string,
          modelId: maps[i]['model_id'] as String?, // Идентификатор модели
          tokens: maps[i]['tokens'] as int?, // Количество токенов
          cost: maps[i]['cost'] as double?, // Стоимость запроса
        );
      });
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
        'class_type': character.classType,
        'backstory': character.backstory,
        'avatar_url': character.avatarUrl,
        'created_at': character.createdAt.toIso8601String(),
        'last_played': character.lastPlayed?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    debugPrint('Error inserting character: $e');
  }
}

// Получить всех персонажей
Future<List<Character>> getCharacters() async {
  try {
    final db = await database;
    final maps = await db.query(
      'characters',
      orderBy: 'last_played DESC, created_at DESC',
    );
    return maps.map((map) => Character.fromJson(map)).toList();
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
Future<void> updateLastPlayed(String id) async {
  try {
    final db = await database;
    await db.update(
      'characters',
      {'last_played': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
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
  // Метод получения статистики по сообщениям
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final db = await database;

      // Получение общего количества сообщений
      final totalMessagesResult =
          await db.rawQuery('SELECT COUNT(*) as count FROM messages');
      final totalMessages = Sqflite.firstIntValue(totalMessagesResult) ?? 0;

      // Получение общего количества токенов
      final totalTokensResult = await db.rawQuery(
          'SELECT SUM(tokens) as total FROM messages WHERE tokens IS NOT NULL');
      final totalTokens = Sqflite.firstIntValue(totalTokensResult) ?? 0;

      // Получение статистики использования моделей
      final modelStats = await db.rawQuery('''
        SELECT 
          model_id,
          COUNT(*) as message_count,
          SUM(tokens) as total_tokens
        FROM messages 
        WHERE model_id IS NOT NULL 
        GROUP BY model_id
      ''');

      // Формирование данных по использованию моделей
      final modelUsage = <String, Map<String, int>>{};
      for (final stat in modelStats) {
        final modelId = stat['model_id'] as String;
        modelUsage[modelId] = {
          'count': stat['message_count'] as int, // Количество сообщений
          'tokens':
              stat['total_tokens'] as int? ?? 0, // Общее количество токенов
        };
      }

      return {
        'total_messages': totalMessages, // Общее количество сообщений
        'total_tokens': totalTokens, // Общее количество токенов
        'model_usage': modelUsage, // Статистика по моделям
      };
    } catch (e) {
      debugPrint('Error getting statistics: $e'); // Логирование ошибок
      return {
        'total_messages': 0,
        'total_tokens': 0,
        'model_usage': {},
      };
    }
  }

}
