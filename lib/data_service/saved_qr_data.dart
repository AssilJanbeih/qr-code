// database table
final String tableQR = 'qr';

//database column fields naming
class QRFields {
  static final List<String> values = [id, title, link];

  static final String id = '_id';
  static final String title = 'title';
  static final String link = 'link';
}

// data model class
class SavedQRData {
  final int? id;
  final String title;
  final String link;

  const SavedQRData({this.id, required this.title, required this.link});

  SavedQRData copy({
    int? id,
    String? title,
    String? link,
  }) =>
      SavedQRData(
          id: id ?? this.id,
          title: title ?? this.title,
          link: link ?? this.link);

  static SavedQRData fromJson(Map<String, Object?> json) => SavedQRData(
        id: json[QRFields.id] as int?,
        title: json[QRFields.title] as String,
        link: json[QRFields.link] as String,
      );

  Map<String, Object?> toJson() => {
        QRFields.id: id,
        QRFields.title: title,
        QRFields.link: link,
      };
}
