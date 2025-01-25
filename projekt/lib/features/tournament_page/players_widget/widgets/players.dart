import 'package:flutter/material.dart';

class Players extends StatelessWidget {
  const Players({required this.playersInfo, super.key});

  final List<String> playersInfo;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 400,
        child: CustomScrollView(
          slivers: [
            SliverList.builder(
              itemCount: playersInfo.length,
              itemBuilder: (context, index) => PlayerEntry(
                name: playersInfo[index],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerEntry extends StatelessWidget {
  const PlayerEntry({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton(
        onPressed: () {},
        child: Center(
          child: Text(name),
        ),
      ),
    );
  }
}
