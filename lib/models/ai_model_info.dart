enum ModelStatus {
  notDownloaded,
  downloading,
  downloaded,
  extracting,
  ready,
  error,
}

class AIModelInfo {
  final String id;
  final String name;
  final String description;
  final String version;
  final int sizeInMB;
  final String type;
  final List<String> capabilities;
  final String downloadUrl;
  ModelStatus status;
  double downloadProgress;
  String? errorMessage;
  DateTime? lastUpdated;

  AIModelInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.version,
    required this.sizeInMB,
    required this.type,
    required this.capabilities,
    required this.downloadUrl,
    this.status = ModelStatus.notDownloaded,
    this.downloadProgress = 0.0,
    this.errorMessage,
    this.lastUpdated,
  });

  factory AIModelInfo.fromJson(Map<String, dynamic> json) {
    return AIModelInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      version: json['version'] ?? '1.0.0',
      sizeInMB: json['sizeInMB'] ?? 0,
      type: json['type'] ?? 'General',
      capabilities: List<String>.from(json['capabilities'] ?? []),
      downloadUrl: json['downloadUrl'] ?? '',
      status: ModelStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] ?? 'notDownloaded'),
        orElse: () => ModelStatus.notDownloaded,
      ),
      downloadProgress: (json['downloadProgress'] ?? 0.0).toDouble(),
      errorMessage: json['errorMessage'],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.tryParse(json['lastUpdated']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'version': version,
      'sizeInMB': sizeInMB,
      'type': type,
      'capabilities': capabilities,
      'downloadUrl': downloadUrl,
      'status': status.toString().split('.').last,
      'downloadProgress': downloadProgress,
      'errorMessage': errorMessage,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  String get formattedSize {
    if (sizeInMB >= 1024) {
      return '${(sizeInMB / 1024).toStringAsFixed(2)} GB';
    }
    return '$sizeInMB MB';
  }

  bool get isDownloaded => status == ModelStatus.downloaded || status == ModelStatus.ready;
  bool get isDownloading => status == ModelStatus.downloading;
  bool get isReady => status == ModelStatus.ready;

  AIModelInfo copyWith({
    ModelStatus? status,
    double? downloadProgress,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return AIModelInfo(
      id: id,
      name: name,
      description: description,
      version: version,
      sizeInMB: sizeInMB,
      type: type,
      capabilities: capabilities,
      downloadUrl: downloadUrl,
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Still demo, maybe in next versions i would made real AI.

  static List<AIModelInfo> getDefaultModels() {
    return [
      AIModelInfo(
        id: 'trend-analyzer-v1',
        name: 'Trend Analyzer',
        description: 'Advanced model for analyzing trending content and predicting viral potential',
        version: '1.2.0',
        sizeInMB: 450,
        type: 'Trend Analysis',
        capabilities: ['Trend Detection', 'Virality Prediction', 'Content Scoring'],
        downloadUrl: 'https://models.ai-youtube-boost.com/trend-analyzer-v1.2.0',
      ),
      AIModelInfo(
        id: 'niche-detector-v2',
        name: 'Niche Detector',
        description: 'Specialized model for identifying profitable niches and audience preferences',
        version: '2.0.1',
        sizeInMB: 320,
        type: 'Niche Analysis',
        capabilities: ['Niche Identification', 'Audience Analysis', 'Competition Scoring'],
        downloadUrl: 'https://models.ai-youtube-boost.com/niche-detector-v2.0.1',
      ),
      AIModelInfo(
        id: 'engagement-predictor-v1',
        name: 'Engagement Predictor',
        description: 'Predicts engagement rates and optimal posting times',
        version: '1.5.3',
        sizeInMB: 280,
        type: 'Engagement Analysis',
        capabilities: ['Engagement Prediction', 'Time Optimization', 'Audience Behavior'],
        downloadUrl: 'https://models.ai-youtube-boost.com/engagement-predictor-v1.5.3',
      ),
      AIModelInfo(
        id: 'keyword-optimizer-v1',
        name: 'Keyword Optimizer',
        description: 'Optimizes keywords and tags for maximum discoverability',
        version: '1.1.0',
        sizeInMB: 180,
        type: 'SEO Optimization',
        capabilities: ['Keyword Research', 'Tag Optimization', 'Search Ranking'],
        downloadUrl: 'https://models.ai-youtube-boost.com/keyword-optimizer-v1.1.0',
      ),
      AIModelInfo(
        id: 'content-analyzer-v3',
        name: 'Content Analyzer',
        description: 'Comprehensive content analysis for quality and appeal scoring',
        version: '3.0.0',
        sizeInMB: 520,
        type: 'Content Analysis',
        capabilities: ['Content Quality', 'Appeal Scoring', 'Improvement Suggestions'],
        downloadUrl: 'https://models.ai-youtube-boost.com/content-analyzer-v3.0.0',
      ),
    ];
  }
}
