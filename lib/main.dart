import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.greenAccent,
      brightness: Brightness.dark,
    ),
  ),
  home: const WelcomeScreen(),
));

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 100, color: Colors.greenAccent),
            const SizedBox(height: 30),
            const Text(
              "Wubba Lubba Dub Dub!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text("Explore the world of Rick and Morty", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RickMortyScreen())),
              child: const Text("Get Schwifty", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('Characters', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          final person = characters[index];
          return Card(
            color: const Color(0xFF1E1E1E),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: Hero(
                tag: person.image,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(person.image),
                ),
              ),
              title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: person.status == 'Alive' ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(person.status, style: const TextStyle(color: Colors.grey)),
                ],
              ),
              trailing: Icon(person.isLiked ? Icons.favorite : Icons.favorite_border, color: Colors.redAccent),
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
            ),
          );
        },
      ),
    );
  }
}

class FloatingHeart extends StatefulWidget {
  final Offset position;
  final VoidCallback onAnimationComplete;

  const FloatingHeart({
    super.key,
    required this.position,
    required this.onAnimationComplete,
  });

  @override
  State<FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<FloatingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _travelAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _travelAnimation = Tween<double>(begin: 0.0, end: -100.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double heartSize = 80.0;

    return Positioned(
      left: widget.position.dx - (heartSize / 2),
      top: widget.position.dy - (heartSize / 2),
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _travelAnimation.value),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: heartSize,
            shadows: [Shadow(blurRadius: 15, color: Colors.black54)],
          ),
        ),
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
  List<MapEntry<UniqueKey, Offset>> _heartData = [];

  void _handleDoubleTap(TapDownDetails details) {
    final key = UniqueKey();

    setState(() {
      localIsLiked = true;
      _heartData.add(MapEntry(key, details.localPosition));
    });

    widget.onLikeToggle(true);
  }

  @override
  void initState() {
    super.initState();
    localIsLiked = widget.isLiked;
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
                  ..._heartData.map((entry) => FloatingHeart(
                    key: entry.key,
                    position: entry.value,
                    onAnimationComplete: () {
                      if (mounted) {
                        setState(() {
                          _heartData.removeWhere((item) => item.key == entry.key);
                        });
                      }
                    },
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