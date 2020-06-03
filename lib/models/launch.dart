import 'package:spaceXLaunch/models/rocket.dart';
import 'package:intl/intl.dart';

class Launch {
  final DateTime launchUTC;
  final String formattedDate;
  final String missionName;
  final String missionPatch;
  final String missionPatchSm;
  final String videoUrl;
  final String redditUrl;
  final Rocket rocket;

  Launch(
      {this.launchUTC,
      this.rocket,
      this.missionName,
      this.formattedDate,
      this.missionPatch,
      this.missionPatchSm,
      this.videoUrl,
      this.redditUrl});

  factory Launch.fromJson(Map<dynamic, dynamic> parsedJson) {
    DateTime date = DateTime.parse(parsedJson['launch_date_utc']);
    String formattedDate = DateFormat('MM-dd-yyyy').format(date);

    return new Launch(
      launchUTC: date,
      formattedDate: formattedDate,
      rocket: Rocket.fromJson(parsedJson['rocket']),
      missionName: parsedJson['mission_name'],
      missionPatch: parsedJson['links']['mission_patch'],
      missionPatchSm: parsedJson['links']['mission_patch_small'],
      videoUrl: parsedJson['links']['video_link'],
      redditUrl: parsedJson['links']['reddit_campaign'],
    );
  }
}
