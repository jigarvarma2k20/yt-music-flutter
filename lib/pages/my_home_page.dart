import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yt_music/components/custom_list_item.dart';
import 'package:yt_music/components/my_drawer.dart';
import 'package:yt_music/components/utils/human_format.dart';
import 'package:yt_music/pages/play_page.dart';
import 'package:yt_music/providers/youtube_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  bool _isSearching = false;
  bool _isLoading = false;

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(5),
                  hintText: 'Search...',
                  //   focusedBorder: OutlineInputBorder(
                  //       gapPadding: 2,
                  //       borderRadius: const BorderRadius.all(Radius.circular(10)),
                  //       borderSide: BorderSide(
                  //           color: Theme.of(context).colorScheme.onPrimary,
                  //           width: 1.0)
                  //           ),
                ),
                onSubmitted: (value) {
                  context.read<YouTubeProvider>().searchVideos(value);
                  toggleSearch();
                },
              )
            : const Text("YT Music"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                toggleSearch();
              },
            ),
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Consumer<YouTubeProvider>(
        builder: (context, value, child) {
          return Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!_isLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      setState(() {
                        _isLoading = true;
                      });
                      value.searchMoreVideos().then((value) {
                        setState(() {
                          _isLoading = false;
                        });
                      });
                    }
                    return true;
                  },
                  child: ListView.builder(
                    itemCount: value.songs.length,
                    itemBuilder: (context, index) {
                      return CustomListItem(
                          song: value.songs[index],
                          index: index,
                          goToSong: () {
                            value.currentSongIndex = index;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SongPage()),
                            );
                          });
                    },
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SongPage()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))),
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          ClipRRect(
                              clipBehavior: Clip.antiAlias,
                              borderRadius: BorderRadius.circular(100),
                              child: Transform.scale(
                                scale:
                                    1.2, // Adjust this value to zoom in or out
                                child: Image.network(
                                  value.current.mediumThumbnail,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit
                                      .cover, // Ensures the image covers the circle
                                ),
                              )),
                          // const SizedBox(width: 3),
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  value.current.title,
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 12),
                                ),
                              ),
                              Row(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                        thumbShape: const RoundSliderThumbShape(
                                            enabledThumbRadius: 0)),
                                    child: value.isLoading
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: SizedBox(
                                              height: 4,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                              child: LinearProgressIndicator(
                                                color: Colors.green,
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 124, 110, 110),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          )
                                        : Slider(
                                            min: 0,
                                            max: value
                                                .current.duration!.inSeconds
                                                .toDouble(),
                                            inactiveColor: const Color.fromARGB(
                                                255, 124, 110, 110),
                                            activeColor: Colors.green,
                                            value: value
                                                .currentDuration.inSeconds
                                                .toDouble(),
                                            onChanged: (double double) {},
                                            onChangeEnd: (double double) {
                                              value.seek(Duration(
                                                  seconds: double.toInt()));
                                            },
                                          ),
                                  ),
                                  Text(
                                    "${getDurationString(value.currentDuration)}/${getDurationString(value.current.duration!)}",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.skip_previous,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: value.previous,
                          ),
                          IconButton(
                            icon: Icon(
                              value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: () {
                              value.pauseOrResume();
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.skip_next,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: value.next,
                          ),
                          IconButton(
                            icon: Icon(
                              value.repeat ? Icons.repeat_one : Icons.repeat,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: value.toggleRepeat,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
