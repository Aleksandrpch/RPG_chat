import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/character_select_screen.dart';
import 'providers/character_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterProvider(),
      child: MaterialApp(
        title: 'RPG Tower',
        theme: ThemeData.dark().copyWith(
          primaryColor: const Color(0xFFFBBF24),
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          cardColor: const Color(0xFF161B22),
          
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFBBF24),
            secondary: Color(0xFFF97316),
            surface: Color(0xFF161B22),
            background: Color(0xFF0D1117),
            error: Color(0xFFF97316),
            onPrimary: Color(0xFF0D1117),
            onSurface: Color(0xFFE6EDF3),
          ),
          
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Color(0xFFE6EDF3), fontSize: 16),   
            bodyMedium: TextStyle(color: Color(0xFFE6EDF3), fontSize: 14),
            titleLarge: TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 20),
          ),
          
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D1117),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFFFBBF24),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Color(0xFFFBBF24)),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFBBF24),
              foregroundColor: const Color(0xFF0D1117),
            ),
          ),
          
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF161B22),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF3D444D)),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF3D444D)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFFFBBF24)),
              borderRadius: BorderRadius.circular(12),
            ),
            hintStyle: const TextStyle(color: Color(0xFF8B949E)),
          ),
        ),
        home:  CharacterSelectScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}