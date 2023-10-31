import 'package:flutter/material.dart';
import 'package:frontend/models/ranking_models/total_ranking_model.dart';
import 'package:frontend/services/ranking_api_services.dart';

class RankingScreen extends StatelessWidget {
  RankingScreen({super.key});
  final Future<List<TotalRankingModel>> allRankings =
      RankingApiServices.getCurrentSeasonTotalRanking();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 1.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 5,
            child: Container(
              // decoration: const BoxDecoration(color: Colors.blue),
              child: FutureBuilder(
                future: allRankings,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                      itemBuilder: (context, index) {
                        var rank = snapshot.data![index];
                        return Card(
                          color: const Color(0xffececec),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person_rounded),
                            ),
                            title: Text(rank.nickname),
                            subtitle: Text('${rank.rank} 등'),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 5),
                      itemCount: snapshot.data!.length,
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
