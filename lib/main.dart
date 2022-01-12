import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 48,
          ),
          children: [
            AspectRatio(
              aspectRatio: 1 / 1,
              child: Image.network(
                'https://lastfm.freetls.fastly.net/i/u/ar0/883414fe1de7b41de4077bfbb3370cd8.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'Скриптонит',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'Скриптонит (Адиль Жалелов) – казахстанский рэпер и музыкальный продюсер,'
                'резидент российского музыкального лейбла «Gazgolder», создатель лейбла «Musica36».' 
                'В 2009 году с Ануаром Баймуратовым создал группу JILLZ, но настоящую популярность обрёл'
                'в 2013 году, когда с Niman-ом выпустил видеоклип к песне «VBVVCTND».',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: CupertinoButton(
                color: Colors.purple[300],
                child: const Text('Посмотреть альбомы'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AlbumsScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({ Key? key }) : super(key: key);

   Future<List<Album>> getAlbums() async {
    http.Response response = await http.get(Uri.parse('https://api.deezer.com/artist/5603958/albums'));
    var json = jsonDecode(response.body); 

    List<Album> albums = [];

    for (var album in json['data'] ) {
      albums.add(Album(
        id: album['id'], 
        name: album['title'], 
        imagePath: album['cover_xl']
      ));
    }

    return albums;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 48,
          ),
          children: [
            const Text( 
              'Альбомы',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold
              ),
            ),
            FutureBuilder<List<Album>>(
              future: getAlbums(),
              initialData: const [],
              builder: (context, snapshot) => Column(
                children: snapshot.requireData.map((album) => AlbumCard(album: album)).toList()
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AlbumCard extends StatefulWidget {
  const AlbumCard({ Key? key, required this.album }) : super(key: key);

  final Album album;

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  
  bool liked = false;
  
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((storage) {
      List<String> list = storage.getStringList('albums') ?? [];

      if (list.contains(widget.album.id.toString())) {
        setState(() {
          liked = true;
        });
      }
    });
  }

  void onPressed() async {
    SharedPreferences storage = await SharedPreferences.getInstance();

    if (!liked) {
      List<String> list = storage.getStringList('albums') ?? [];
      list.add(widget.album.id.toString());
      storage.setStringList('albums', list);
    } else {
      List<String> list = storage.getStringList('albums') ?? [];
      list.removeWhere((element) => element == widget.album.id.toString());
      storage.setStringList('albums', list);
    }
  
    setState(() {
      liked = !liked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 32)),
        AspectRatio(
          aspectRatio: 1 / 1,
          child: Stack(children: [
            Image.network(
              widget.album.imagePath,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                child: liked 
                  ? const Icon(Icons.favorite, size: 48, color: Colors.white) 
                  : const Icon(Icons.favorite_border, size: 48, color: Colors.white),
                onTap: () => onPressed(),
              )
            )
          ])
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            widget.album.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }
}

class Album {
  final int id;
  final String name;
  final String imagePath;

  Album({ required this.id, required this.name, required this.imagePath });
}