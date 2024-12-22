// lib/models/presentation.dart

class Presentation {
  final int id;
  final String title;
  final String category;
  final int views;
  final String uploadDate;
  final String imageUrl; // Actually the direct file link

  Presentation({
    required this.id,
    required this.title,
    required this.category,
    required this.views,
    required this.uploadDate,
    required this.imageUrl,
  });

  factory Presentation.fromJson(Map<String, dynamic> json) {
    return Presentation(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      views: json['views'] as int,
      uploadDate: DateTime.parse(json['upload_date'] as String)
          .toLocal()
          .toString()
          .split(' ')[0],
      imageUrl: json['image_url'] as String,
    );
  }
}
