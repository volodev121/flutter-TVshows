import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/models/episode.dart';
import '/ui/shared/actors_horizontal_list.dart';
import '/ui/shared/heading1.dart';
import '/ui/screens/horizental_genre_list.dart';
import '/ui/screens/horizontal_movies_list.dart';
import '/ui/screens/horizontal_tvseries_list.dart';
import '/ui/screens/top_video_list.dart';

class HomeScreenShimmer extends StatefulWidget {
  HomeScreenShimmer({Key? key, this.loading}) : super(key: key);
  final loading;

  @override
  _HomeScreenShimmerState createState() => _HomeScreenShimmerState();
}

class _HomeScreenShimmerState extends State<HomeScreenShimmer>
    with TickerProviderStateMixin {
  late AnimationController animation;
  late Animation<double> _fadeInFadeOut;

  ScrollController controller = ScrollController(initialScrollOffset: 0.0);

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _fadeInFadeOut = Tween<double>(begin: 0.2, end: 0.8).animate(animation);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animation.forward();
      }
    });
    animation.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20.0,
            ),
            FadeTransition(
              opacity: _fadeInFadeOut,
              child: HorizontalGenreList(
                loading: widget.loading,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Heading1(translate("Artist_"), "Actor", widget.loading),
            SizedBox(
              height: 15.0,
            ),
            FadeTransition(
              opacity: _fadeInFadeOut,
              child: ActorsHorizontalList(loading: widget.loading),
            ),
            SizedBox(
              height: 15.0,
            ),
            Heading1(
                translate("Top_Movies___TV_Series"), "Top", widget.loading),
            SizedBox(
              height: 15.0,
            ),
            FadeTransition(
              opacity: _fadeInFadeOut,
              child: Container(
                height: 350,
                child: TopVideoList(
                  loading: widget.loading,
                ),
              ),
            ),
            Heading1(translate("TV_Series"), "TV", widget.loading),
            FadeTransition(
              opacity: _fadeInFadeOut,
              child: TvSeriesList(
                type: DatumType.T,
                loading: widget.loading,
                data: [],
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Heading1(translate("Movies_"), "Mov", widget.loading),
            FadeTransition(
              opacity: _fadeInFadeOut,
              child: MoviesList(
                type: DatumType.M,
                loading: widget.loading,
                data: [],
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    animation.dispose();
    super.dispose();
  }
}
