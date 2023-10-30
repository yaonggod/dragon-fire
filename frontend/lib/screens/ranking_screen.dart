import 'package:flutter/material.dart';
import 'package:frontend/services/ranking_api_services.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    RankingApiServices.getCurrentSeasonTotalRanking();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('랭킹'),
        centerTitle: true,
      ),
      body: const Text('랭킹 페이지'),
    );
  }
}
