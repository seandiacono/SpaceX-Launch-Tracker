import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:spaceXLaunch/models/launchList.dart';
import 'package:spaceXLaunch/services/launch_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:transparent_image/transparent_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var launchService = LaunchService();
    return FutureProvider(
      create: (context) => launchService.fetchLaunch(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SpaceX Mission Control',
        theme: ThemeData(
          brightness: Brightness.light,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: GoogleFonts.workSansTextTheme(
            Theme.of(context)
                .textTheme
                .apply(bodyColor: Colors.black, displayColor: Colors.black),
          ),
        ),
        home: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer timer;
  LaunchList launches;
  String countdown;

  @override
  void initState() {
    countdown = '';
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (launches != null) {
        bool negative = true;
        var diff;
        int i = 1;
        while (negative) {
          diff =
              launches.launches[0].launchUTC.difference(DateTime.now().toUtc());
          if (diff.inSeconds < 0) {
            var tempLaunch = launches.launches[0];
            launches.launches[0] = launches.launches[i];
            launches.launches[i] = tempLaunch;
            i++;
            negative = true;
          } else {
            negative = false;
          }
        }

        setState(() {
          countdown = durationToString(diff);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    launches = Provider.of<LaunchList>(context);

    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (launches != null)
                    ? Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                        height: 150,
                        child: (launches.launches[0].missionPatchSm != null)
                            ? FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image: launches.launches[0].missionPatchSm)
                            : FadeInImage.memoryNetwork(
                                placeholder: kTransparentImage,
                                image:
                                    'https://upload.wikimedia.org/wikipedia/commons/2/28/Falcon_9_logo_by_SpaceX.png'))
                    : JumpingDotsProgressIndicator(
                        fontSize: 50,
                      ),
                Text(
                  'Next Launch',
                  style: GoogleFonts.workSans(fontSize: 40.0),
                ),
                (launches != null)
                    ? Text(
                        countdown,
                        style: GoogleFonts.spaceMono(
                            fontSize: 50.0, fontWeight: FontWeight.w600),
                      )
                    : JumpingDotsProgressIndicator(
                        fontSize: 50,
                      ),
                (launches != null)
                    ? Text(
                        'Mission: ' + launches.launches[0].missionName,
                        style: GoogleFonts.workSans(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      )
                    : Container(),
                (launches != null)
                    ? Text(
                        'Rocket: ' + launches.launches[0].rocket.rocketName,
                        style: GoogleFonts.workSans(fontSize: 20.0),
                        textAlign: TextAlign.center,
                      )
                    : Container(),
                (launches != null)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          (launches.launches[0].redditUrl != null)
                              ? IconButton(
                                  padding: EdgeInsets.fromLTRB(0, 5, 20, 0),
                                  icon: FaIcon(
                                    FontAwesomeIcons.reddit,
                                    size: 50.0,
                                    color: Color.fromRGBO(255, 67, 1, 1),
                                  ),
                                  onPressed: () {
                                    _launchUrl(launches.launches[0].redditUrl);
                                  })
                              : Container(),
                          (launches.launches[0].videoUrl != null)
                              ? IconButton(
                                  padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
                                  icon: FaIcon(
                                    FontAwesomeIcons.youtube,
                                    size: 40.0,
                                    color: Color.fromRGBO(255, 67, 1, 1),
                                  ),
                                  onPressed: () {
                                    _launchUrl(launches.launches[0].videoUrl);
                                  })
                              : Container(),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Column(
              children: <Widget>[
                Text('Upcoming Launches',
                    style: GoogleFonts.workSans(fontSize: 30.0)),
                (launches != null)
                    ? Expanded(
                        child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(8),
                            itemCount: launches.launches.length - 1,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: (launches.launches[index + 1]
                                                    .missionPatchSm !=
                                                null)
                                            ? FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image: launches
                                                    .launches[index + 1]
                                                    .missionPatchSm)
                                            : FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image:
                                                    'https://upload.wikimedia.org/wikipedia/commons/2/28/Falcon_9_logo_by_SpaceX.png'),
                                        title: Text(
                                            '${launches.launches[index + 1].missionName}'),
                                        subtitle: Text(
                                            '${launches.launches[index + 1].rocket.rocketName}'),
                                        trailing: Text(
                                            '${launches.launches[index + 1].formattedDate}'),
                                      ),
                                    ]),
                              );
                            }),
                      )
                    : Center(
                        child: JumpingDotsProgressIndicator(
                        fontSize: 50,
                      )),
              ],
            ),
          )
        ],
      ),
    ));
  }

  String durationToString(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitHours = twoDigits(duration.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inDays)}:$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch';
    }
  }
}
