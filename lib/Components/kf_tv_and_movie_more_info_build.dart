import 'package:flutter/material.dart';
import 'package:flix_pro/Components/kf_more_info_build.dart';

class KFTVAndMovieMoreInfoBuild extends StatelessWidget {
  const KFTVAndMovieMoreInfoBuild({Key? key, required this.isMovie})
      : super(key: key);
  final bool isMovie;

  @override
  Widget build(BuildContext context) {
    return KFMoreInfoBuild(isMovie: isMovie);
  }
}
