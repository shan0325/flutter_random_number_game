import 'package:flutter/material.dart';

import '../models/game_record.dart';
import '../widgets/ad_mob_banner.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, required this.records});

  final List<GameRecord> records;

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBD2A4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color(0xFF54473F),
        ),
        title: const Text(
          'Records',
          style: TextStyle(
            color: Color(0xFF54473F),
          ),
        ),
        actions: [
          DropdownButton<String>(
            value: _sortOption,
            icon: const Icon(Icons.sort, color: Color(0xFF54473F)),
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
                  style: const TextStyle(color: Color(0xFF54473F)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFE9EED9),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: widget.records.length,
          itemBuilder: (context, index) {
            final record = widget.records[index];
            return ListTile(
              leading: Text(
                '${widget.records.length - index}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF54473F),
                ),
              ),
              title: Text(
                record.record,
                style: const TextStyle(
                  color: Color(0xFF54473F),
                ),
              ),
              subtitle: Text(
                record.date,
                style: const TextStyle(
                  color: Color(0xFF54473F),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
