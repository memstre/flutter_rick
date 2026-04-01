import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(home: RickMortyScreen()));

class RickMortyScreen extends StatefulWidget {
  const RickMortyScreen({super.key});
  @override
  State<RickMortyScreen> createState() => _RickMortyState();
}

class Character {
  final String name;
  final String image;
  final String species;

  Character({required this.name, required this.image, required this.species});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      image: json['image'],
      species: json['species'],
    );
  }
}

class _RickMortyState extends State<RickMortyScreen> {
  List<Character> characters = [];

  Future<void> fetchAll() async {
    final url = Uri.parse('https://rickandmortyapi.com/api/character');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      setState(() {
        characters = results.map((json) => Character.fromJson(json)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rick and Morty animations')),
      body: ListView.builder(
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final person = characters[index];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(person.image)),
            title: Text(person.name),
            subtitle: Text(person.species),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    name: person.name,
                    image: person.image,
                    species: person.species,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final String name;
  final String image;
  final String species;

  DetailScreen({required this.name, required this.image, required this.species});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('This is details about ${name}')),
      body: Center(
        child: Column(
          children: [
            image.isEmpty ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), strokeWidth: 4.0,) :
            ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(image, height: 250)),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text('species: $species', style: TextStyle(fontSize: 18)),
          ],
        ),
      )
    );
  }
}