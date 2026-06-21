import 'package:flutter/material.dart';

import '../models/game_difficulty.dart';
import '../models/game_record.dart';
import '../theme/game_theme.dart';
import '../widgets/ad_mob_banner.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({
    super.key,
    required this.records,
    required this.difficulty,
  });

  final List<GameRecord> records;
  final GameDifficulty difficulty;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final ScrollController _scrollController = ScrollController();
  String _sortOption = 'record';

  @override
  void initState() {
    super.initState();
    _sortRecords();
  }

  void _sortRecords() {
    setState(() {
      if (_sortOption == 'record') {
        widget.records.sort(
          (a, b) => double.parse(a.record).compareTo(double.parse(b.record)),
        );
      } else if (_sortOption == 'date') {
        widget.records.sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.appBar,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: colors.text,
        ),
        title: Text(
          'Records',
          style: TextStyle(color: colors.text),
        ),
        actions: [
          DropdownButton<String>(
            value: _sortOption,
            icon: Icon(Icons.sort, color: colors.text),
            onChanged: (String? newValue) {
              setState(() {
                _sortOption = newValue!;
                _sortRecords();
              });
            },
            items: <String>['record', 'date']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'record' ? 'Record' : 'Date',
                  style: TextStyle(color: colors.text),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Container(
        color: colors.screen,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: widget.records.length,
          itemBuilder: (context, index) {
            final record = widget.records[index];
            return ListTile(
              leading: Text(
                '${widget.records.length - index}',
                style: TextStyle(
                  fontSize: 20,
                  color: colors.text,
                ),
              ),
              title: Text(
                record.record,
                style: TextStyle(color: colors.text),
              ),
              subtitle: Text(
                '${widget.difficulty.label} · ${record.date}',
                style: TextStyle(color: colors.mutedText),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
