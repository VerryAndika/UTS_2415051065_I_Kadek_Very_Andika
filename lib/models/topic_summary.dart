// Ringkasan topik dari Wikipedia REST API (/page/summary/{judul}).
class TopicSummary {
  const TopicSummary({
    required this.title,
    required this.extract,
    this.thumbnailUrl,
    this.pageUrl,
  });

  final String title;
  final String extract;
  final String? thumbnailUrl;
  final String? pageUrl;

  factory TopicSummary.fromJson(Map<String, dynamic> json) => TopicSummary(
    title: json['title'] as String? ?? '',
    extract: json['extract'] as String? ?? '',
    thumbnailUrl: (json['thumbnail'] as Map?)?['source'] as String?,
    pageUrl:
        ((json['content_urls'] as Map?)?['desktop'] as Map?)?['page']
            as String?,
  );
}
