import 'dart:developer';

import 'package:countup/countup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:goojara_pro/Commons/kf_colors.dart';
import 'package:goojara_pro/Commons/kf_extensions.dart';
import 'package:goojara_pro/Commons/kf_functions.dart';
import 'package:goojara_pro/Commons/kf_strings.dart';
import 'package:goojara_pro/Commons/kf_themes.dart';
import 'package:goojara_pro/Components/kf_web_component.dart';
import 'package:goojara_pro/Provider/kf_provider.dart';
import 'package:nb_utils/nb_utils.dart' hide log;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../Commons/kf_keys.dart';

class KFVideoLoadingComponent extends StatefulWidget {
  KFVideoLoadingComponent(
      {required this.homeUrl,
      required this.isMovie,
      this.currentSeason = "1",
      this.episodeIndex = 0,
      this.numberOfSeasons = 1,
      this.isDownloading = false})
      : super(key: UniqueKey());
  final String homeUrl;
  final bool isMovie;
  final String? currentSeason;
  final int? episodeIndex;
  final int? numberOfSeasons;
  final bool isDownloading;

  @override
  State<KFVideoLoadingComponent> createState() =>
      _KFVideoLoadingComponentState();
}

class _KFVideoLoadingComponentState extends State<KFVideoLoadingComponent> {
  // late AnimationController controller;

  String get homeUrl => widget.homeUrl;
  bool get isMovie => widget.isMovie;
  String? get currentSeason => widget.currentSeason;
  int? get numberOfSeasons => widget.numberOfSeasons;
  int? get episodeIndex => widget.episodeIndex;
  bool get isDownloading => widget.isDownloading;

  Future<String> _fetchEpisodeUrl() async {
    log("HOME URL START: $homeUrl");
    final startPage = (await fetchDataFromInternet(homeUrl)).body;

    final startDoc = startPage.document;
    // int numberOfSeasons = 2;
    // if (mounted) {
    //   numberOfSeasons = context
    //           .read<KFProvider>()
    //           .kfTMDBSearchTVResultsById
    //           ?.numberOfSeasons ??
    //       2;
    // }

    String seasonsUrl = "";
    var element = startDoc.getElementById('sesh');

    String? checkUrl;

    if (element != null) {
      checkUrl = element.getElementsByTagName('a')[0].attributes['href'];
    }

    if (checkUrl != null) {
      seasonsUrl = checkUrl;
    }

    String url = seasonsUrl == ""
        ? "$homeUrl?s=$currentSeason"
        : seasonsUrl.startsWith('/')
            ? "$kfMoviesDetailBaseUrl${seasonsUrl.substring(0, seasonsUrl.indexOf("?"))}?s=$currentSeason"
            : "${seasonsUrl.substring(0, seasonsUrl.indexOf("?"))}?s=$currentSeason";
    log("SEASON URL: $url");

    final episodesPage = (await fetchDataFromInternet(url)).body;
    // log(episodesPage);
    final document = episodesPage.document;
    final episodesList = document.getElementsByClassName("seho");

    log("EPISODES lIST: $episodesList");

    String episodeUrl = "";

    if (episodesList.isNotEmpty) {
      String url = episodesList.reversed
              .toList()[episodeIndex ?? 0]
              .getElementsByTagName('a')
              .first
              .attributes['href'] ??
          "";
      url = "$kfMoviesDetailBaseUrl$url";

      log("episode url: $url");

      episodeUrl = url;
    }

    return episodeUrl;
  }

  late Future<String>? fetchEpisodeUrl;
  @override
  void initState() {
    super.initState();
    final isMovie =
        context.read<KFProvider>().kfTMDBSearchMovieResultsById != null;
    fetchEpisodeUrl = isMovie ? null : _fetchEpisodeUrl();
  }

  bool _delayedLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool get webAccessed => getBoolAsync(keyWebAccessed);

  @override
  Widget build(BuildContext context) {
    log("WEB ACCESSED: $webAccessed");

    final provider = Provider.of<KFProvider>(context);
    String? title;

    final String rootImagePath =
        provider.kfTMDBSearchResults?.results?[0].backdropPath ??
            provider.kfTMDBSearchResults?.results?[0].posterPath ??
            "";

    bool isTv = provider.kfTMDBSearchTVResultsById != null;
    if (isTv) {
      title = provider.kfTMDBSearchTVResultsById?.name ??
          provider.kfTMDBSearchTVResultsById?.originalName ??
          "";
      title =
          "$title Season $currentSeason Episode ${episodeIndex!.toInt() + 1}";
    } else {
      title = provider.kfTMDBSearchMovieResultsById?.title ??
          provider.kfTMDBSearchMovieResultsById?.originalTitle ??
          "";
    }
    if (!webAccessed) {
      return _configureWeb(title, rootImagePath);
    }
    return Scaffold(
      key: _scaffoldKey,
      body: _buildBody(title, rootImagePath),
    );
  }

  void setWebAccessed() async => await setValue(keyWebAccessed, true);

  Widget _configureWeb(String title, String rootImagePath) => FutureBuilder(
      future: 40.seconds.delay,
      builder: (_, snap) {
        if (snap.ready) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setWebAccessed();
            finish(context);
            KFVideoLoadingComponent(
              homeUrl: homeUrl,
              isMovie: isMovie,
              isDownloading: isDownloading,
              currentSeason: currentSeason,
              episodeIndex: episodeIndex,
              numberOfSeasons: numberOfSeasons,
            ).launch(context);
          });
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(
                Icons.clear,
                color: white,
              ),
              onPressed: () => finish(context),
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SpinKitDualRing(
                              color: white,
                            ),
                            20.width,
                            Countup(
                              begin: 0,
                              end: 100,
                              duration: 40.seconds,
                              style: primaryTextStyle(color: white, size: 21),
                              suffix: '%',
                              curve: Curves.easeIn,
                            )
                          ]),
                      22.height,
                      Text(
                        'Just a moment',
                        style: boldTextStyle(color: white),
                      ),
                      12.height,
                      Text(
                        'Please wait while we configure your movie browser.',
                        style: primaryTextStyle(color: white),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
              _web(
                  rootImagePath: rootImagePath,
                  title: title,
                  webAccessed: false)
            ],
          ),
        );
      });

  Widget _buildBody(String title, String rootImagePath) =>
      Builder(builder: (context) {
        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                color: Colors.black,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: boldTextStyle(color: Colors.white, size: 21),
                      textAlign: TextAlign.center,
                    ),
                    32.height,
                    Visibility(
                      visible: !_delayedLoading,
                      child: Text(
                        isDownloading
                            ? 'Preparing download ...'
                            : 'Loading video...',
                      ),
                    ),
                    10.height,
                    CircularPercentIndicator(
                      animateFromLastPercent: true,
                      radius: 80,
                      animationDuration: 35000,
                      onAnimationEnd: () =>
                          setState(() => _delayedLoading = true),
                      animation: true,
                      percent: 0.97,
                      center: Countup(
                        precision: 0,
                        curve: Curves.fastOutSlowIn,
                        begin: 0,
                        end: 97,
                        duration: 35000.milliseconds,
                        style: boldTextStyle(size: 16, color: Colors.white),
                        suffix: '%',
                      ),
                      progressColor: kfPrimaryTextColor,
                    ),
                    if (_delayedLoading)
                      Column(
                        children: [
                          10.height,
                          Text(
                            "Loading this video is taking longer than expected. Please try to connect to fast internet connection or restart the app and try again",
                            style: boldTextStyle(color: kfPrimaryTextColor),
                            textAlign: TextAlign.center,
                          ),
                          10.height,
                          ElevatedButton(
                              style: kfButtonStyle(context),
                              onPressed: () {
                                finish(context);
                                KFVideoLoadingComponent(
                                  homeUrl: homeUrl,
                                  isMovie: isMovie,
                                  isDownloading: isDownloading,
                                  currentSeason: currentSeason,
                                  episodeIndex: episodeIndex,
                                  numberOfSeasons: numberOfSeasons,
                                ).launch(context);
                              },
                              child: Text(
                                "Try Again",
                                style: boldTextStyle(color: Colors.black),
                              ))
                        ],
                      ),
                  ],
                ),
              ),
            ),
            fetchEpisodeUrl == null
                ? _web(rootImagePath: rootImagePath, title: title)
                : FutureBuilder<String>(
                    future: fetchEpisodeUrl,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.ready) {
                        final url = snapshot.data ?? "";
                        return _web(
                            url: url,
                            rootImagePath: rootImagePath,
                            title: title);
                      }
                      return Container();
                    }),
          ],
        );
      });

  Widget _web(
          {String? url,
          required String rootImagePath,
          required String title,
          bool? webAccessed}) =>
      Offstage(
        // offstage: false,
        offstage: true,
        child: WebComponent(
            url: url ??
                (homeUrl.startsWith('/')
                    ? '$kfMoviesDetailBaseUrl$homeUrl'
                    : homeUrl),
            rootImageUrl: rootImagePath,
            title: title,
            isDownloading: isDownloading,
            supportMultipleWindows: webAccessed ?? true,
            type: isMovie ? 'movie' : 'tv'),
      );
}
