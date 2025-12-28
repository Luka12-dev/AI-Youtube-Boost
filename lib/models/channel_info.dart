class ChannelInfo {
  final String channelName;
  final String channelId;
  final String channelLogo;
  final int subscriberCount;
  final int videoCount;
  final int viewCount;

  ChannelInfo({
    required this.channelName,
    required this.channelId,
    required this.channelLogo,
    required this.subscriberCount,
    required this.videoCount,
    required this.viewCount,
  });

  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    final statistics = json['statistics'] ?? {};
    final snippet = json['snippet'] ?? {};
    
    return ChannelInfo(
      channelName: snippet['title'] ?? '',
      channelId: json['id'] ?? '',
      channelLogo: snippet['thumbnails']?['high']?['url'] ?? 
                   snippet['thumbnails']?['medium']?['url'] ?? 
                   snippet['thumbnails']?['default']?['url'] ?? '',
      subscriberCount: int.tryParse(statistics['subscriberCount']?.toString() ?? '0') ?? 0,
      videoCount: int.tryParse(statistics['videoCount']?.toString() ?? '0') ?? 0,
      viewCount: int.tryParse(statistics['viewCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channelName': channelName,
      'channelId': channelId,
      'channelLogo': channelLogo,
      'subscriberCount': subscriberCount,
      'videoCount': videoCount,
      'viewCount': viewCount,
    };
  }

  String get formattedSubscribers {
    if (subscriberCount >= 1000000) {
      return '${(subscriberCount / 1000000).toStringAsFixed(1)}M';
    } else if (subscriberCount >= 1000) {
      return '${(subscriberCount / 1000).toStringAsFixed(1)}K';
    }
    return subscriberCount.toString();
  }

  String get formattedViews {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    }
    return viewCount.toString();
  }
}
