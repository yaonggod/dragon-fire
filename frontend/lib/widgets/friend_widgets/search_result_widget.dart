import 'package:flutter/material.dart';
import 'package:frontend/models/friend_models/search_result_model.dart';

class SearchResultWidget extends StatefulWidget {
  final SearchResultModel searchResult;

  const SearchResultWidget({super.key, required this.searchResult});

  @override
  State<SearchResultWidget> createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends State<SearchResultWidget> {
  bool visible = true;

  Widget showButton() {
    if (widget.searchResult.friendStatus == "NONE" || widget.searchResult.friendStatus == "DISCONNECTED") {
      return Text("친구 신청하기");
    } else if (widget.searchResult.friendStatus == "ACCEPTCHECK") {
      return Text("확인");
    } else if (widget.searchResult.friendStatus == "FRIEND") {
      return Container();
    } else if (widget.searchResult.friendStatus == "WAITING") {
      return Text("수락 대기중");
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return !visible ? Container() : Card(
      color: const Color.fromRGBO(0, 0, 0, 0.5),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage:
                  AssetImage("lib/assets/icons/appIcon.png"),
                  radius: 30,
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.searchResult.toNickname, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.searchResult.friendStatus, style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text(
                      '지존 210점',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                showButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}