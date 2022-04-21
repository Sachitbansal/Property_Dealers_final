import 'package:flutter/material.dart';

class SearchBarData extends StatefulWidget {
  const SearchBarData({Key? key}) : super(key: key);

  @override
  State<SearchBarData> createState() => _SearchBarDataState();
}

class _SearchBarDataState extends State<SearchBarData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Data'),
      ),
    );
  }
}
