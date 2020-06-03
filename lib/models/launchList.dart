import 'package:spaceXLaunch/models/launch.dart';

class LaunchList {
  final List<Launch> launches;

  LaunchList({
    this.launches,
  });

  factory LaunchList.fromJson(List<dynamic> parsedJson) {
    List<Launch> launches = new List<Launch>();
    launches = parsedJson.map((i) => Launch.fromJson(i)).toList();

    return new LaunchList(launches: launches);
  }
}
