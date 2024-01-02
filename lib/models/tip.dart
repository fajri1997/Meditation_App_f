//tip.dart
import 'package:flutter/foundation.dart';

class Tip {
  final int id;
  final String text;
  final String author;
  final String owner;
  // late final int upvotes;
  // late final int downvotes;
  // late final bool userUpvoted;
  // late final bool userDownvoted;

  Tip({
    required this.id,
    required this.text,
    required this.author,
    required this.owner,
    // required this.upvotes,
    // required this.downvotes,
    // required this.userUpvoted,
    // required this.userDownvoted,
  });

  // Add a factory constructor to create a Tip instance from JSON
  factory Tip.fromJson(Map<String, dynamic> json) {
    return Tip(
      id: json['id'] ?? 0,
      text: json['text'] ?? 'Default text',
      author: json['author'] ?? 'Unknown author',
      owner: json['owner'] ?? 'Unknown owner',
      // upvotes: json['upvotes'] ?? 0,
      // downvotes: json['downvotes'] ?? 0,
      // userUpvoted: json['userUpvoted'] ?? false, // Add this line
      // userDownvoted: json['userDownvoted'] ?? false, // Add this line
    );
  }

  // Add a method to convert Tip instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'owner': owner,
      // 'upvotes': upvotes,
      // 'downvotes': downvotes,
      // 'userUpvoted': userUpvoted, // Add this line
      // 'userDownvoted': userDownvoted, // Add this line
    };
  }
}
