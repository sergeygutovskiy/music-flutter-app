import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// входная точка любого dart приложения
void main() {
  // функция флкттера, которая запускает приложение
  // в нее мы передаем создание главного виджета App
  runApp(const App());
}

// Главный виджет
// по сути, просто говорит, что будет использоваться MaterialApp виджет
// это виджет из библиотеки material, который позволяет делать всякие красвивые переходы,
// навигацию, табы и тп
class App extends StatelessWidget {
  const App({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // В конструктор передаем параметр home,
      // он гооврит какой виджет бюдет нлавной страницой в приложении
      // у нас это HomeScreen
      home: HomeScreen(),
    );
  }
}

// Виджет для отображения главной страницы приложения 
class HomeScreen extends StatelessWidget {
  const HomeScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ListView - это как Column, 
        // только с возможносью листать коннтент внутри          
        child: ListView(
          // отступы
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 48,
          ),
          // что внутри списка           
          children: [
            // этот виджет задает соотношение сторон контейнеру,
            // 1 / 1 - квадрат (то есть мы уверены, что картинка всегда будет квадратной, 
            // в независимости от ее исходных размеров)
            AspectRatio(
              aspectRatio: 1 / 1,
              // создаем картинку с помощью конструктора network (именнованые конструкторы https://www.freecodecamp.org/news/constructors-in-dart/#:~:text=Named%20constructors%20in%20Dart)
              // то есть загружаем по сети
              child: Image.network(
                'https://lastfm.freetls.fastly.net/i/u/ar0/883414fe1de7b41de4077bfbb3370cd8.jpg',
                fit: BoxFit.cover,
              ),
            ),
//          // виджеты внутри списка будут оборачиваться в Padding,
            // чтобы делать отступ между елементами
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'Скриптонит',
//              // с помощью style задаются стили для текста =
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
              // по сути это просто виджет кнопки, но уже не из material (android),
              // а из cupertino (iphone), выбрал ее просто потому что красиавя
              child: CupertinoButton(
                color: Colors.purple[300],
                child: const Text('Посмотреть альбомы'),
                // событие нажатия на кнопку
                // код внутри говорит, что нужно будет перейти на новую страницу, а именно AlbumsScreen()
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AlbumsScreen())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// страница альбомов
class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({ Key? key }) : super(key: key);

   // функция получения альбомов из апишки
   // возвращает список из альбомов
   // Future указывает, что это функция не вернет мгновенно результат
   // и будет выполняться параллельно основному коду
   Future<List<Album>> getAlbums() async {
    // отпраялем запрос
    // вообще http.get тоже возвращает Future<...>, но так как нам важен ответ внутри этой функции
    // то мы используем await, который блокирует поток, и ждет пока функция выполниться
    // то есть пока мы не получим ответ от апишки код дальше этой страки не пойдет
    // (чтобы использовать await, сама функция должная быть помечена async - то есть она внтури содержит какие-то операции, 
    // которые могут выполняться не сразу (http.get) )
    http.Response response = await http.get(Uri.parse('https://api.deezer.com/artist/5603958/albums'));
    // получаем данные в виде json формата
    var json = jsonDecode(response.body); 

    // создаем список полученных альбомов
    List<Album> albums = [];

    // проходимся по json массиву и из него
    // добавляем в наш список альбомы
    for (var album in json['data'] ) {
      albums.add(Album(
        id: album['id'], 
        name: album['title'], 
        imagePath: album['cover_xl']
      ));
    }

    // возвращаем найденные альбомы
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
            // FutureBuilder - виджет, который позволяет рендерить элементы
            // после того, как появилась информация для них
            
            // порядок такой
            // 1. Вызывается getAlbums()
            // 2. Пока функция выполняется, отображается [initialData], то есть ничего ([])
            // 3. Как только данные загрузились FutureBuilder вызывает функцию build, и показывает виджеты
            FutureBuilder<List<Album>>(
              // функция для получения данных 
              future: getAlbums(),
              // изначальные данные (ничего)
              initialData: const [],
              // функция, которая указывает как эти данные нужно отобразить (сделать из альбомов - карточки альбомов)
              // snapshot - это переменная, в которой храниться данные о работе функции getAlbums
              // нас интересует только свойство requireData, это как-раз те альбомы, которые вернет getAlbums
              builder: (context, snapshot) => Column(
                // возвращаем колонку
                // функция map создаем из старого списка новый (например из строк сделать числа) с помощью выражения внтури
                children: 
                  snapshot.requireData
                    // проходимся по нашему списку альбомов
                    // и возвращаем виджет AlbumCard(), в который передаем обьект альбома
                    .map((album) => AlbumCard(album: album))
                    // map возвращает тип Iterable, а нам нужен List
                    // поэтому делаем приведение
                    .toList()
              ),
            )
          ],
        ),
      ),
    );
  }
}

// виджет карточки альбома
// прнимает обьект альбома, тк ему нужно знать какую инфу выводить
class AlbumCard extends StatefulWidget {
  const AlbumCard({ Key? key, required this.album }) : super(key: key);

  final Album album;

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.only(top: 32)),
        AspectRatio(
          aspectRatio: 1 / 1,
          child: Image.network(
              // передаем адрес картинки
              widget.album.imagePath,
              fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            // выводим название альбома
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
