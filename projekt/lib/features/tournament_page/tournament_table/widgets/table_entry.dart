import 'package:flutter/material.dart';

class TableEntry extends StatelessWidget {
  const TableEntry({
    super.key,
    required this.position,
    required this.name,
    required this.color,
    required this.points,
    required this.wins,
    required this.ties,
    required this.loses,
  });

  final String position;
  final String name;
  final Color color;
  final String points;
  final String wins;
  final String ties;
  final String loses;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(20), // Pozycja
            1: FlexColumnWidth(40), // Nazwa gracza
            2: FixedColumnWidth(50), // Punkty
            3: FixedColumnWidth(50), // Wygrane
            4: FixedColumnWidth(50), // Remisy
            5: FixedColumnWidth(50), // Przegrane
          },
          border: TableBorder.symmetric(
            inside: BorderSide(color: Colors.grey.shade400),
          ),
          children: [
            TableRow(
              children: [
                Center(child: Text(position)),
                Center(child: Text(name)),
                Center(child: Text(points)),
                Center(child: Text(wins)),
                Center(child: Text(ties)),
                Center(child: Text(loses)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
