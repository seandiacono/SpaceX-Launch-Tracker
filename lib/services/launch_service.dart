import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:spaceXLaunch/models/launch.dart';
import 'package:spaceXLaunch/models/launchList.dart';

class LaunchService {
  Future<LaunchList> fetchLaunch() async {
    var response =
        await http.get('https://api.spacexdata.com/v3/launches/upcoming');

    var json = convert.jsonDecode(response.body);

    var launch = LaunchList.fromJson(json);

    return launch;
  }
}
