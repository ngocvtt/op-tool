import 'dart:convert';

TinyUrl tinyUrlFromJson(String str) => TinyUrl.fromJson(json.decode(str));

String tinyUrlToJson(TinyUrl data) => json.encode(data.toJson());

class TinyUrl {
  String domain;
  String alias;
  bool deleted;
  bool archived;
  Analytics analytics;
  List<dynamic> tags;
  DateTime createdAt;
  dynamic expiresAt;
  String tinyUrl;
  String url;

  TinyUrl({
    required this.domain,
    required this.alias,
    required this.deleted,
    required this.archived,
    required this.analytics,
    required this.tags,
    required this.createdAt,
    required this.expiresAt,
    required this.tinyUrl,
    required this.url,
  });

  factory TinyUrl.fromJson(Map<String, dynamic> json) => TinyUrl(
    domain: json["domain"],
    alias: json["alias"],
    deleted: json["deleted"],
    archived: json["archived"],
    analytics: Analytics.fromJson(json["analytics"]),
    tags: List<dynamic>.from(json["tags"].map((x) => x)),
    createdAt: DateTime.parse(json["created_at"]),
    expiresAt: json["expires_at"],
    tinyUrl: json["tiny_url"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "domain": domain,
    "alias": alias,
    "deleted": deleted,
    "archived": archived,
    "analytics": analytics.toJson(),
    "tags": List<dynamic>.from(tags.map((x) => x)),
    "created_at": createdAt.toIso8601String(),
    "expires_at": expiresAt,
    "tiny_url": tinyUrl,
    "url": url,
  };
}

class Analytics {
  bool enabled;
  bool public;

  Analytics({
    required this.enabled,
    required this.public,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) => Analytics(
    enabled: json["enabled"],
    public: json["public"],
  );

  Map<String, dynamic> toJson() => {
    "enabled": enabled,
    "public": public,
  };
}
