import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:projekt/features/basic_page/providers/tournament_list_provider.dart';
import 'package:projekt/features/services/tournament_service.dart';

class TournamentsList extends StatelessWidget {
  const TournamentsList({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final service = context.watch<TournamentService>();
    final data = context.watch<TournamentListData>();
    return FutureBuilder(
      future: service.getUserTournaments(),
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.circular(
              15,
            ),
          ),
          width: width,
          height: height * 0.7,
          child: CustomScrollView(
            slivers: [
              SliverList.separated(
                itemCount: data.tournaments!.length,
                itemBuilder: (context, index) => TournamentEntry(
                  name: data.tournaments![index].name,
                  type: data.tournaments![index].type!,
                  id: data.tournaments![index].id,
                ),
                separatorBuilder: (context, _) => const SizedBox(
                  height: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TournamentEntry extends StatelessWidget {
  const TournamentEntry({
    required this.name,
    required this.type,
    required this.id,
    super.key,
  });

  final String name;
  final String type;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: ElevatedButton(
        onPressed: () {
          context.push('/tournament/$id');
        },
        child: Column(
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 24),
            ),
            Text(
              type,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
