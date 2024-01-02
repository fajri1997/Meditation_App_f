class Tip {
  final int id;
  final String text;
  final String author;
  final String owner;
  final List<dynamic> upvotes;
  final List<dynamic> downvotes;
  bool userHasVoted;
  int netVotes;

  Tip({
    required this.id,
    required this.text,
    required this.author,
    required this.owner,
    required this.upvotes,
    required this.downvotes,
    required this.userHasVoted,
    required this.netVotes,
  });

  factory Tip.fromJson(Map<String, dynamic> json,
      [String? currentUserIdentifier]) {
    // Existing parsing logic, using currentUserIdentifier if provided
    bool hasVoted = false;
    if (currentUserIdentifier != null) {
      hasVoted = json['upvotes'].contains(currentUserIdentifier) ||
          json['downvotes'].contains(currentUserIdentifier);
    }

    int upvoteCount = json['upvotes'].length;
    int downvoteCount = json['downvotes'].length;

    return Tip(
      id: json['id'] ?? 0,
      text: json['text'] ?? 'Default text',
      author: json['author'] ?? 'Unknown author',
      owner: json['owner'] ?? 'Unknown owner',
      upvotes: json['upvotes'] ?? [],
      downvotes: json['downvotes'] ?? [],
      userHasVoted: hasVoted,
      netVotes: upvoteCount - downvoteCount,
    );
  }

  // ... toJson method ...

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'owner': owner,
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }
}
