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
  final String status;
  bool isLiked = false;

  Character({required this.name, required this.image, required this.status});

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      image: json['image'],
      status: json['status'],
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
            leading: Hero(
              tag: person.image,
              child: CircleAvatar(backgroundImage: NetworkImage(person.image)),
            ),
            title: Text(person.name),
            subtitle: Text(person.status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    name: person.name,
                    image: person.image,
                    status: person.status,
                    isLiked: person.isLiked,
                    onLikeToggle: (newliked) {
                      setState(() {
                        person.isLiked = newliked;
                      });
                    },
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

class DetailScreen extends StatefulWidget {
  final String name;
  final String image;
  final String status;
  final bool isLiked;
  final Function(bool) onLikeToggle;

  const DetailScreen({super.key, required this.name, required this.image, required this.status, required this.isLiked, required this.onLikeToggle,});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool localIsLiked;
  List<Offset> _tapPositions = [];

  @override
  void initState() {
    super.initState();
    localIsLiked = widget.isLiked;
  }

  void _handleDoubleTap(TapDownDetails details) {
    setState(() {
      localIsLiked = true;
      _tapPositions.add(details.localPosition);
    });
    widget.onLikeToggle(true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _tapPositions.removeAt(0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('This is details about ${widget.name}')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onDoubleTapDown: _handleDoubleTap,
              child: Stack(
                alignment: Alignment.center,
                children: [Hero(
                    tag: widget.image,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(widget.image))),
                  ..._tapPositions.map((pos) => Positioned(
                    left: pos.dx - 40,
                    top: pos.dy - 40,
                    child: const Icon(Icons.favorite, color: Colors.white, size: 80),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            Text('status: ${widget.status}', style: TextStyle(fontSize: 18, color: widget.status == 'Alive' ? Colors.green : Colors.red)),
            IconButton(
              iconSize: !localIsLiked ? 50 : 50 * 1.5,
              icon: Icon(localIsLiked ? Icons.favorite : Icons.favorite_border),
              color: Colors.red,
              onPressed: () {
                setState(() {
                  localIsLiked = !localIsLiked;
                });
                widget.onLikeToggle(localIsLiked);
              },
            ),
          ],
        ),
      )
    );
  }
}