import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
//tatelessWidget을 상속받은 클래스
  const MyApp({super.key});
  //상태를 가지지 않으며 오직 ui만을 구성합니다
//const생성자를 사용하여 불변성확보 및 성능을 최적화
  @override
  Widget build(BuildContext context) {
    //플루터에서 ui를 그릴때 호출되는 핵심 매서드
//리턴값은 위젯트리이고 ChangeNotifierProvider로 시작합니다
    return ChangeNotifierProvider(
      //프로바이더 패키지를 사용한 상태관리 방식입니다
      create: (context) => MyAppState(),
      //MyAppState()객체를 생성하고 앱 전체에 공급합니다
      //이객체는 ChangeNotifier를 상속해야 하며 배분변화시 UI를 갱신할수 있다
      child: MaterialApp(
        title: '타이틀',
        theme: ThemeData(
          //앱의 전체적인 디자인 테마를 설정
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

//고급스럽게 만들려면..아래를 수정
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

//end add
  var history = <WordPair>[];
//히스토리는 워드페어 타입리스트로 이전에 생성된 단어쌍들을 저장하는 히스토리 역활을 합니다
  GlobalKey? historyListKey;
//historyListKey는 GlobalKey타입의 변수이며 플루터에서 특정위젯(주로 상태를 가진 위젯)의
//상태에 접근하기 위해서 사용합니다 이럴경우는 animatedlist상태에 접근하기 위해 사용될 가능성이 큽니다
//?는 null이 될수도 있음을 의미합니다

  //add this
  void getNext() {
    //이매서드는..임의의 새 WordPair를 큐런트에 재할당
    //또한 MyAppState를 보고있는 사람에게 알림을 보내는 notifyListeners()
    //체인지 노티파이어 메서드를 호출
//end add
    history.insert(0, current); //최근 단어쌍이 가장 앞에 쌓이도록 함
    var animatedList = historyListKey?.currentState as AnimatedListState?;
//historyListKey가 null이 아니면 해당 키가 참조하는 위젯상태를 가져옵니다
    animatedList?.insertItem(0);
//null이 아니면 즉 상테가 존재한다면 색인 첫번째에 아이템이 추가됨을 알리고 애니메이션 효과를 실행
    current = WordPair.random();
//새로운 무작위 단어쌍을 생성하여 current에 할당
    notifyListeners(); //함수호출
  }
//겟넥스트는 현재 단어쌍을 히스토리 맨앞에 추가하고 애니메이티드리스트 위젯에 아이템 추가 내이메이션을 트리거하며
//새로운 랜덤 단어쌍으로 current를 갱신하고 ui에 변경사항을 알린다

  //새로운 비즈니스 로직추가
  var favorites = <WordPair>[];
  //이속성이 비워져 있는 목록으로 초기화
  void toggleFavorite([WordPair? pair]) {
//end add
    pair = pair ?? current;

//즐겨찾기 목록에서 현재단어쌍(이미있는 경우)을 삭제하거나 아직없는 경우에는 목록에 추가
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  //삭제하는 함수추가
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

/*

 */
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//add
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page; //이코드는 위젯 유형의 새변수 page를 선언
    switch (selectedIndex) {
      //selectedIndex의 현재값에 따라 switch문이 화면을 page에 할당합니다
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

//end add 변수추가
    var mainArea = ColoredBox(
      //자식 위젯에 배경에 색을 칠하는 위젯
      color: Theme.of(context).colorScheme.surfaceContainer,
      //이영역의 배경색을 ColorScheme.surfaceVariant로 지정
      //ColorScheme => Theme.of(context).colorScheme로부터 얻은 앱 테마 색상값
      child: AnimatedSwitcher(
        //이전자식을 사라지게 하고 새로운 자식을 나타나게 하는 전환애니메이션
        duration: Duration(milliseconds: 200), //200ms로 설정
        child: page,
      ),
    );

//레이아웃빌더의 빌더 콜백은 제약조건이 변경될때마다 호출됩니다
//(앱의 창의 크기를 조절할때, 사용자가 휴대전화를 새로모드 가로모드 또는 그반대로 회전)
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          //
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                //end add
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite),
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex: selectedIndex,
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    //extended: false,
                    extended: constraints.maxWidth >= 600, //600 보다 작거나 같거나
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite),
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (value) {
                      //print('selected: $value');
                      setState(() {
                        selectedIndex = value;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
//add this
    var pair = appState.current;

//add this
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        //정렬
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Text('A random AWESOME idea:'),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
//add this
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),

              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                  //print('button pressed!');
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
//add this
    final theme = Theme.of(context);
//add
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
/*
theme.textTheme 앱의 글꼴 테마에 엑세스..
bodyMedium(중간크기의 표준텍스트),caption(이미지 설명),headlineLarge(큰 헤드라인용)
 */

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ' '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}




//앱을 대화식으로 진행하는것이 플루터를 알아가는 가장 좋은 방법입니다