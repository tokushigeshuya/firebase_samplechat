import 'package:chat/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'post.dart';

Future<void> main() async {
  // main 関数でも async が使えます
  WidgetsFlutterBinding.ensureInitialized(); // runApp 前に何かを実行したいときはこれが必要です。
  await Firebase.initializeApp(
    // これが Firebase の初期化処理です。
    options: DefaultFirebaseOptions.android,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> signInWithGoogle() async {
    // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
    final googleUser = await GoogleSignIn(scopes: ['profile', 'email']).signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoogleSignIn'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('GoogleSignIn'),
          onPressed: () async {
            await signInWithGoogle();
            // ログインが成功すると FirebaseAuth.instance.currentUser にログイン中のユーザーの情報が入ります
            print(FirebaseAuth.instance.currentUser?.displayName);

            // ログイン成功でchatPageに遷移
            // 前のページに戻れないようにするにはpushAndRemoveUntilを使う
            if(mounted){
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context){
                  return const ChatPage();
                }), 
                (route) => false,
                );
            }
          },
        ),
      ),
    );
  }
}


// チャットページ
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チャット'),
      ),
      body: Center(
        child: TextFormField(
          onFieldSubmitted: (text){
            // user 変数にログイン中のデータを渡す
            final user = FirebaseAuth.instance.currentUser!;
            // ログイン中のユーザーのIDが取れる
            final posterId = user.uid;
            // googleアカウントの名前が取れる
            final posterName = user.displayName!;
            // googleのアイコン
            final posterImageUrl = user.photoURL!;

            // 先ほど作ったpostseference　からランダムなIDのドキュメントリファレンスを作成する
            // docの引数を空にするとランダムなIDが採用される
            final newDocumentReference = postsReference.doc();

            final newPost = Post(
              text: text,
              createdAt: Timestamp.now(),
              posterName: posterName,
              posterImageUrl: posterImageUrl,
              posterId: posterId,
              reference: newDocumentReference,
            );

            // 先ほど作ったnewDocumentReferenceのset関数を実行するとそのドキュメントデータが保存される
            // 引数としてPost インスタンスを渡します。
            // 通常はMapしか受け付けませんが、withConverter を使用したことによりPostインスタンスを受け取れるようになる
            newDocumentReference.set(newPost);
          },
        ),
      ),
    );
  }
}

// <Post>は変換したい型名を入れる
final postsReference = FirebaseFirestore.instance.collection('posts').withConverter<Post>(
  // 第二引数は使用しないので_で不使用であることをわかりやすくする
  fromFirestore: ((snapshot, _) {
    return Post.fromFirestore(snapshot);
  }), 
  toFirestore: ((value, _){
    return value.toMap();
  }),
  );