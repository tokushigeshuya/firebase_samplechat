import 'package:cloud_firestore/cloud_firestore.dart';

class post {
  post({
    required this.text,
    required this.createdAt,
    required this.posterName,
    required this.posterImageUrl,
    required this.posterId,
    required this.reference,
  });
  // 投稿文
  final String text;

  // 投稿日時
  final Timestamp createdAt;

  // 投稿者の名前
  final String posterName;

  // 投稿者のアイコン画像URL
  final String posterImageUrl;

  // 投稿者のユーザーID
  final String posterId;

  // firestoreのどこにデータが存在するかを表すpath情報
  final DocumentReference reference;
}