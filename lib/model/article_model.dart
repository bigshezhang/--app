class Article {
  final int? id;
  final String title;
  final String content;
  final String prompt;
  final String summarizedContent;
  final String timestamp;

  Article({
    this.id,
    required this.title,
    required this.content,
    required this.prompt,
    required this.summarizedContent,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'prompt': prompt,
      'summarizedContent': summarizedContent,
      'timestamp': timestamp,
    };
  }

  factory Article.fromMap(Map<String, dynamic> json) => Article(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    prompt: json['prompt'],
    summarizedContent: json['summarizedContent'],
    timestamp: json['timestamp'],
  );

  Article copy({
    int? id,
    String? title,
    String? content,
    String? prompt,
    String? summarizedContent,
    String? timestamp,
  }) =>
      Article(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        prompt: prompt ?? this.prompt,
        summarizedContent: summarizedContent ?? this.summarizedContent,
        timestamp: timestamp ?? this.timestamp,
      );

  @override
  String toString() {
    return 'Article{id: $id, title: $title, content: $content, prompt: $prompt, summarizedContent: $summarizedContent, timestamp: $timestamp}';
  }
}
