import 'package:flutter/material.dart';
import 'package:yt_music/components/utils/human_format.dart';
import 'package:yt_music/models/song.dart';

class CustomListItem extends StatelessWidget {
  final Song song;
  final int index;
  final Function goToSong;
  const CustomListItem({
    super.key,
    required this.song,
    required this.index,
    required this.goToSong,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(song.lowThumbnail, width: 60, height: 60)),
      title: Text(
        song.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
      subtitle: Row(
        children: [
          Text(
            song.author.substring(
                0, song.author.length > 15 ? 15 : song.author.length),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 10),
          Text("Duration - ${getDurationString(song.duration)}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10))
        ],
      ),
      onTap: () => goToSong(),
    );
  }
}
