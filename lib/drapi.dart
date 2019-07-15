import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

abstract class DrMuApi {
  Future<List<Channel>> getAllActiveDrTvChannels();

  //Future<Manifest> getManifest(String uri);

  //Future<Schedule> getSchedule(String id, String date);

  //Future<MuNowNext> getScheduleNowNextById(String id);

  Future<List<MuNowNext>> getScheduleNowNext();

//Future<SearchResult> search(String query);

//Future<MostViewed> getMostViewed(String channel, String channelType, int limit)

//Future<Page> getPageTvPrograms(Genre genre);
}

const String API_VERSION = "1.4";
const String API_URL = "https://www.dr.dk/mu-online/api/$API_VERSION";

class DrMuRepository implements DrMuApi {
  @override
  Future<List<MuNowNext>> getScheduleNowNext() async {
    final response = await http
        .get("$API_URL/schedule/nownext-for-all-active-dr-tv-channels");

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return compute(parseNowNextList, response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load json');
    }
  }

  @override
  Future<List<Channel>> getAllActiveDrTvChannels() async {
    final response =
        await http.get("$API_URL/channel/all-active-dr-tv-channels");

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return compute(parseChannelList, response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load json');
    }
  }
}

class MuNowNext {
  final String channelSlug;
  final String channel;
  final MuScheduleBroadcast now;
  final List<MuScheduleBroadcast> next;

  MuNowNext({this.channelSlug, this.channel, this.now, this.next});

  factory MuNowNext.fromJson(Map<String, dynamic> json) {
    var nextList = (json['Next'] as List)
        .map((json) => MuScheduleBroadcast.fromJson(json))
        .toList();

    return MuNowNext(
      channelSlug: json['ChannelSlug'],
      channel: json['Channel'],
      now: MuScheduleBroadcast.fromJson(json['Now']),
      next: nextList,
    );
  }
}

class MuScheduleBroadcast {
  final String title;
  final String description;
  final String subtitle;
  final DateTime startTime;
  final DateTime endTime;
  final ProgramCard programCard;
  final String onlineGenreText;
  final String productionNumber;
  final bool programCardHasPrimaryAsset;
  final bool seriesHasProgramCardWithPrimaryAsset;
  final DateTime announcedStartTime;
  final DateTime announcedEndTime;
  final String productionCountry;
  final int productionYear;
  final bool videoWidescreen;
  final bool subtitlesTTV;
  final bool videoHD;
  final String whatsOnUri;
  final bool isRerun;

  MuScheduleBroadcast(
      {this.title,
      this.description,
      this.subtitle,
      this.startTime,
      this.endTime,
      this.programCard,
      this.onlineGenreText,
      this.productionNumber,
      this.programCardHasPrimaryAsset,
      this.seriesHasProgramCardWithPrimaryAsset,
      this.announcedStartTime,
      this.announcedEndTime,
      this.productionCountry,
      this.productionYear,
      this.videoWidescreen,
      this.subtitlesTTV,
      this.videoHD,
      this.whatsOnUri,
      this.isRerun});

  String getPrimaryAssetUri() {
    if (programCard.hasPublicPrimaryAsset) {
      return programCard.primaryAsset.uri;
    }
    return "";
  }

  factory MuScheduleBroadcast.fromJson(Map<String, dynamic> json) {
    return MuScheduleBroadcast(
        title: json['Title'],
        description: json['Description'],
        subtitle: json['Subtitle'],
        startTime: DateTime.parse(json['StartTime']),
        endTime: DateTime.parse(json['EndTime']),
        programCard: ProgramCard.fromJson(json['ProgramCard']));
  }
}

class ProgramCard {
  final String type;
  final String seriesTitle;
  final String episodeTitle;
  final String seriesSlug;
  final String seriesUrn;
  final String hostName;
  final String seriesHostName;
  final String primaryChannel;
  final String primaryChannelSlug;
  final bool seasonEpisodeNumberingValid;
  final String seasonTitle;
  final String seasonSlug;
  final String seasonUrn;
  final int seasonNumber;
  final bool prePremiere;
  final bool expiresSoon;
  final String onlineGenreText;
  final PrimaryAsset primaryAsset;
  final bool hasPublicPrimaryAsset;
  final String assetTargetTypes;
  final DateTime primaryBroadcastStartTime;
  final DateTime sortDateTime;
  final Info onDemandInfo;
  final String slug;
  final String urn;
  final String primaryImageUri;
  final String presentationUri;
  final String presentationUriAutoplay;
  final String title;
  final String subtitle;
  final bool isNewSeries;
  final String originalTitle;
  final String rectificationStatus;
  final bool rectificationAuto;
  final String rectificationText;

  ProgramCard(
      {this.type,
      this.seriesTitle,
      this.episodeTitle,
      this.seriesSlug,
      this.seriesUrn,
      this.hostName,
      this.seriesHostName,
      this.primaryChannel,
      this.primaryChannelSlug,
      this.seasonEpisodeNumberingValid,
      this.seasonTitle,
      this.seasonSlug,
      this.seasonUrn,
      this.seasonNumber,
      this.prePremiere,
      this.expiresSoon,
      this.onlineGenreText,
      this.primaryAsset,
      this.hasPublicPrimaryAsset,
      this.assetTargetTypes,
      this.primaryBroadcastStartTime,
      this.sortDateTime,
      this.onDemandInfo,
      this.slug,
      this.urn,
      this.primaryImageUri,
      this.presentationUri,
      this.presentationUriAutoplay,
      this.title,
      this.subtitle,
      this.isNewSeries,
      this.originalTitle,
      this.rectificationStatus,
      this.rectificationAuto,
      this.rectificationText});

  factory ProgramCard.fromJson(Map<String, dynamic> json) {
    return ProgramCard(
      type: json['Type'],
      seriesTitle: json['SeriesTitle'],
      episodeTitle: json['EpisodeTitle'],
      seriesSlug: json['SeriesSlug'],
      seriesUrn: json['SeriesUrn'],
      hostName: json['HostName'],
      seriesHostName: json['SeriesHostName'],
      primaryChannel: json['PrimaryChannel'],
      primaryChannelSlug: json['PrimaryChannelSlug'],
      seasonEpisodeNumberingValid: json['SeasonEpisodeNumberingValid'],
      seasonTitle: json['SeasonTitle'],
      seasonSlug: json['SeasonSlug'],
      seasonUrn: json['SeasonUrn'],
      seasonNumber: json['SeasonNumber'],
      prePremiere: json['PrePremiere'],
      expiresSoon: json['ExpiresSoon'],
      onlineGenreText: json['OnlineGenreText'],
      primaryAsset: PrimaryAsset.fromJson(json['PrimaryAsset']),
      hasPublicPrimaryAsset: json['HasPublicPrimaryAsset'] ?? false,
      assetTargetTypes: json['AssetTargetTypes'],
      primaryBroadcastStartTime:
          DateTime.parse(json['PrimaryBroadcastStartTime']),
      sortDateTime: DateTime.parse(json['SortDateTime']),
      onDemandInfo: Info.fromJson(json['OnDemandInfo']),
      slug: json['Slug'],
      urn: json['Urn'],
      primaryImageUri: json['PrimaryImageUri'],
      presentationUri: json['PresentationUri'],
      presentationUriAutoplay: json['PresentationUriAutoplay'],
      title: json['Title'],
      subtitle: json['Subtitle'],
      isNewSeries: json['IsNewSeries'],
      originalTitle: json['OriginalTitle'],
      rectificationStatus: json['RectificationStatus'],
      rectificationAuto: json['RectificationAuto'],
      rectificationText: json['RectificationText'],
    );
  }
}

class PrimaryAsset {
  final String kind;
  final String uri;
  final int durationInMilliseconds;
  final bool downloadable;
  final bool restrictedToDenmark;
  final DateTime startPublish;
  final DateTime endPublish;
  final String target;
  final bool encrypted;
  final bool isLiveStream;

  PrimaryAsset(
      {this.kind,
      this.uri,
      this.durationInMilliseconds,
      this.downloadable,
      this.restrictedToDenmark,
      this.startPublish,
      this.endPublish,
      this.target,
      this.encrypted,
      this.isLiveStream});

  factory PrimaryAsset.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return PrimaryAsset(
      kind: json['Kind'],
      uri: json['Uri'],
      durationInMilliseconds: json['DurationInMilliseconds'],
      downloadable: json['Downloadable'],
      restrictedToDenmark: json['RestrictedToDenmark'],
      startPublish: DateTime.parse(json['StartPublish']),
      endPublish: DateTime.parse(json['EndPublish']),
      target: json['Target'],
      encrypted: json['Encrypted'],
      isLiveStream: json['IsLiveStream'],
    );
  }
}

class Info {
  final DateTime startPublish;
  final DateTime endPublish;

  Info({this.startPublish, this.endPublish});

  factory Info.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Info(
      startPublish: DateTime.parse(json['StartPublish']),
      endPublish: DateTime.parse(json['EndPublish']),
    );
  }
}

class Channel {
  final String type;
  final List<MuStreamingServer> streamingServers;
  final String url;
  final String sourceUrl;
  final bool webChannel;
  final String slug;
  final String urn;
  final String primaryImageUri;
  final String presentationUri;
  final String presentationUriAutoplay;
  final String title;
  final String itemLabel;
  final String subtitle;

  Channel(
      {this.type,
      this.streamingServers,
      this.url,
      this.sourceUrl,
      this.webChannel,
      this.slug,
      this.urn,
      this.primaryImageUri,
      this.presentationUri,
      this.presentationUriAutoplay,
      this.title,
      this.itemLabel,
      this.subtitle});

  factory Channel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Channel(
      type: json['Type'],
      streamingServers: (json['StreamingServers'] as List)
          .map((json) => MuStreamingServer.fromJson(json))
          .toList(),
      url: json['Url'],
      sourceUrl: json['SourceUrl'],
      webChannel: json['WebChannel'],
      slug: json['Slug'],
      urn: json['Urn'],
      primaryImageUri: json['PrimaryImageUri'],
      presentationUri: json['PresentationUri'],
      presentationUriAutoplay: json['PresentationUriAutoplay'],
      title: json['Title'],
      itemLabel: json['ItemLabel'],
      subtitle: json['Subtitle'],
    );
  }

  MuStreamingServer hlsServer() {
    return streamingServers.firstWhere((it) => it.linkType == "HLS",
        orElse: null);
  }

  MuStreamingServer hdsServer() {
    return streamingServers.firstWhere((it) => it.linkType == "HDS",
        orElse: null);
  }

  MuStreamingServer server() {
    return hlsServer() ?? hdsServer();
  }
}

class MuStreamingServer {
  final String server;
  final String linkType;
  final List<MuStreamQuality> qualities;
  final bool dynamicUserQualityChange;
  final String encryptedServer;

  MuStreamingServer(
      {this.server,
      this.linkType,
      this.qualities,
      this.dynamicUserQualityChange,
      this.encryptedServer});

  factory MuStreamingServer.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MuStreamingServer(
      server: json['Server'],
      linkType: json['LinkType'],
      qualities: (json['Qualities'] as List)
          .map((json) => MuStreamQuality.fromJson(json))
          .toList(),
      dynamicUserQualityChange: json['DynamicUserQualityChange'],
      encryptedServer: json['EncryptedServer'],
    );
  }
}

class MuStreamQuality {
  final int kbps;
  final List<MuStream> streams;

  MuStreamQuality({this.kbps, this.streams});

  factory MuStreamQuality.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MuStreamQuality(
      kbps: json['Kbps'],
      streams: (json['Streams'] as List)
          .map((json) => MuStream.fromJson(json))
          .toList(),
    );
  }
}

class MuStream {
  final String stream;
  final String encryptedStream;

  MuStream({this.stream, this.encryptedStream});

  factory MuStream.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MuStream(
      stream: json['Stream'],
      encryptedStream: json['EncryptedStream'],
    );
  }
}

List<MuNowNext> parseNowNextList(String responseBody) {
  var list = jsonDecode(responseBody) as List;
  return list.map((json) => MuNowNext.fromJson(json)).toList();
}

List<Channel> parseChannelList(String responseBody) {
  var list = jsonDecode(responseBody) as List;
  return list.map((json) => Channel.fromJson(json)).toList();
}
