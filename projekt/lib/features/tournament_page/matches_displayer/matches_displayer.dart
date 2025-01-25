import 'package:flutter/material.dart';
import 'package:projekt/features/tournament_page/matches_displayer/schedule_page/schedule_page.dart';
import 'package:projekt/features/tournament_page/models/sport_match.dart';

class MatchesDisplayer extends StatefulWidget {
  const MatchesDisplayer(
      {super.key, required this.matches, required this.width});

  final double width;

  final List<List<SportMatch>>? matches;
  @override
  MatchesDisplayerState createState() => MatchesDisplayerState();
}

class MatchesDisplayerState extends State<MatchesDisplayer>
    with TickerProviderStateMixin {
  int _currentPageIndex = 0;
  late CustomPageController _pageViewController;

  @override
  void initState() {
    super.initState();
    _pageViewController =
        CustomPageController(maxScroll: widget.matches!.length - 1);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
  }

  void scroll(int index, bool next) {
    _pageViewController.animateToPage(
      index + (next ? 1 : -1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int currentPageIndex) {
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches == null) {
      return const Placeholder();
    }
    double height = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: height,
            width: widget.width,
            child: PageView.builder(
              itemCount: widget.matches!.length,
              controller: _pageViewController,
              onPageChanged: onPageChanged,
              itemBuilder: (item, builder) {
                return SchedulePage(
                    currentRound: _currentPageIndex + 1,
                    height: height,
                    width: widget.width,
                    matches: widget.matches![_currentPageIndex]);
              },
            ),
          ),
          PageIndicator(currentIndex: _currentPageIndex, scroll: scroll),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.scroll,
  });

  final int currentIndex;
  final void Function(int, bool) scroll;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () => scroll(currentIndex, false),
              icon: const Icon(
                Icons.arrow_left_rounded,
                size: 32,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            IconButton(
              onPressed: () => scroll(currentIndex, true),
              icon: const Icon(
                Icons.arrow_right_rounded,
                size: 32,
              ),
            ),
          ],
        ));
  }
}

class CustomPageController extends PageController {
  CustomPageController({required this.maxScroll});

  final int maxScroll;

  @override
  Future<void> animateToPage(int page,
      {required Duration duration, required Curve curve}) async {
    if (page >= 0 && page <= maxScroll) {
      await super.animateToPage(page, duration: duration, curve: curve);
    }
  }
}
