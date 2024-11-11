// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yt_music/components/neo_box.dart';
import 'package:yt_music/components/utils/human_format.dart';
import 'package:yt_music/providers/youtube_provider.dart';
import 'package:share_plus/share_plus.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<YouTubeProvider>(builder: (context, value, child) {
      return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // APPBAR + SONG DETAILS + PLAYER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back)),
                      const Text('Now Playing'),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.menu)),
                    ],
                  ),

                  Column(
                    children: [
                      NeoBox(
                          child: Column(
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                value.current.mediumThumbnail,
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: Text(
                                        value.current.title,
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(value.current.author),
                                  ],
                                ),
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          )
                        ],
                      )),

                      const SizedBox(height: 20),

                      // PLAYER CONTROLS
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(getDurationString(value.currentDuration)),
                                IconButton(
                                    onPressed: () {
                                      Share.share(
                                          'Check out this song: ${value.current.title} by ${value.current.author} on YouTube: ${value.current.url}');
                                    },
                                    icon: Icon(Icons.share)),
                                IconButton(
                                    onPressed: () {
                                      value.toggleRepeat();
                                    },
                                    icon: Icon(value.repeat
                                        ? Icons.repeat_one
                                        : Icons.repeat)),
                                Text(getDurationString(value.current.duration)),
                              ],
                            ),
                          ),
                          value.isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: LinearProgressIndicator(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                )
                              : SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 0)),
                                  child: Slider(
                                    min: 0,
                                    max: value.current.duration!.inSeconds
                                        .toDouble(),
                                    inactiveColor: Colors.grey,
                                    activeColor: Colors.green,
                                    value: value.currentDuration.inSeconds
                                        .toDouble(),
                                    onChanged: (double double) {},
                                    onChangeEnd: (double double) {
                                      value.seek(
                                          Duration(seconds: double.toInt()));
                                    },
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // PLAYER BUTTONS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: value.previous,
                              child: NeoBox(
                                child: const Icon(Icons.skip_previous),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                value.pauseOrResume();
                              },
                              child: NeoBox(
                                child: value.isPlaying
                                    ? Icon(Icons.pause)
                                    : Icon(Icons.play_arrow),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: value.next,
                              child: NeoBox(
                                child: const Icon(Icons.skip_next),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ));
    });
  }
}
