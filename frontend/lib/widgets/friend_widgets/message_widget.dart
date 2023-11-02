import 'package:flutter/material.dart';

class MessageWidget extends StatefulWidget {
  final String nickname;

  const MessageWidget({super.key, required this.nickname});

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  bool visible = true;

  void acceptFriend() {}

  Future<void> _acceptDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${widget.nickname}님과 친구가 되었습니다.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void rejectFriend() {}

  Future<void> _rejectDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${widget.nickname}님의 친구 신청을 거절했습니다.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  void checkFriend() {}

  @override
  Widget build(BuildContext context) {
    return visible
        ? Card(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      '${widget.nickname}님이 친구를 신청했습니다. 수락하시겠습니까?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () async {
                      acceptFriend();
                      await _acceptDialog(context);

                      setState(() {
                        visible = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5)),
                      child: const Icon(Icons.check),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () async {
                      rejectFriend();
                      await _rejectDialog(context);
                      setState(() {
                        visible = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5)),
                      child: const Icon(Icons.close_outlined),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
  }
}
