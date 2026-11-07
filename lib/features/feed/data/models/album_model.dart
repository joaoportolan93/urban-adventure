import 'package:flutter/foundation.dart';

@immutable
class Track {
  final int number;
  final String title;
  final String duration; // Ex: "4:20"

  const Track({
    required this.number,
    required this.title,
    required this.duration,
  });

  Map<String, dynamic> toMap() => {
        'number': number,
        'title': title,
        'duration': duration,
      };

  factory Track.fromMap(Map<dynamic, dynamic> map) => Track(
        number: (map['number'] as num?)?.toInt() ?? 1,
        title: map['title'] as String? ?? '',
        duration: map['duration'] as String? ?? '3:30',
      );
}

@immutable
class Album {
  final String id;
  final String title;
  final String artist;
  final List<String> genres;

  /// FICTÍCIO: Estimativa mockada de ouvintes mensais por artista até a integração de APIs reais na Fase 2
  final int artistMonthlyListeners;

  /// Capa opcional. Se for nula, o app renderiza a arte determinística offline
  final String? coverUrl;

  /// Padrão 1.0 (quadrada) para preservar a integridade da arte sem recortes
  final double aspectRatio;

  /// Duração total do álbum (ex: "45 min 20 s")
  final String totalDuration;

  /// Lista de faixas com duração individual
  final List<Track> tracks;

  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.genres,
    required this.artistMonthlyListeners,
    this.coverUrl,
    this.aspectRatio = 1.0,
    this.totalDuration = '42 min',
    this.tracks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'genres': genres,
      'artistMonthlyListeners': artistMonthlyListeners,
      'coverUrl': coverUrl,
      'aspectRatio': aspectRatio,
      'totalDuration': totalDuration,
      'tracks': tracks.map((t) => t.toMap()).toList(),
    };
  }

  factory Album.fromMap(Map<dynamic, dynamic> map) {
    return Album(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      genres: (map['genres'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          const [],
      artistMonthlyListeners: (map['artistMonthlyListeners'] as num?)?.toInt() ?? 0,
      coverUrl: map['coverUrl'] as String?,
      aspectRatio: (map['aspectRatio'] as num?)?.toDouble() ?? 1.0,
      totalDuration: map['totalDuration'] as String? ?? '42 min',
      tracks: (map['tracks'] as List<dynamic>?)
              ?.map((t) => Track.fromMap(Map<dynamic, dynamic>.from(t as Map)))
              .toList() ??
          const [],
    );
  }

  Album copyWith({
    String? id,
    String? title,
    String? artist,
    List<String>? genres,
    int? artistMonthlyListeners,
    String? coverUrl,
    double? aspectRatio,
    String? totalDuration,
    List<Track>? tracks,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      genres: genres ?? this.genres,
      artistMonthlyListeners:
          artistMonthlyListeners ?? this.artistMonthlyListeners,
      coverUrl: coverUrl ?? this.coverUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      totalDuration: totalDuration ?? this.totalDuration,
      tracks: tracks ?? this.tracks,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
