import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class FriendWidget extends StatefulWidget {
  final String nickname;

  const FriendWidget({super.key, required this.nickname});

  @override
  State<FriendWidget> createState() => _FriendWidgetState();
}

class _FriendWidgetState extends State<FriendWidget> {
  bool visible = true;
  String buttonsrc = 'lib/assets/icons/friendButton.png';

  Future<bool> _deleteConfirmDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('친구 삭제'),
          content: Text(
            '${widget.nickname}님을 삭제하시겠습니까?',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void deleteFriend() {
    // 친삭 api 쏘고
    // 친구 안보이게 하기
    setState(() {
      visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !visible
        ? Container()
        : Slidable(
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.15,
              closeThreshold: 0.01,
              openThreshold: 0.001,
              children: [
                SlidableAction(
                  borderRadius: BorderRadius.circular(10.0),
                  padding: const EdgeInsets.only(right: 10),
                  icon: Icons.delete,
                  onPressed: (context) async {
                    bool confirmDelete = await _deleteConfirmDialog(context);
                    if (confirmDelete) {
                      deleteFriend();
                    }
                  },
                ),
              ],
            ),
            child: Card(
              color: const Color.fromRGBO(0, 0, 0, 0.5),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                            Text(
                              widget.nickname,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Text(
                              '지존 210점',
                              style: TextStyle(fontSize: 12),
                            ),
                            const Text(
                              '상대 전적 5승 3패',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {},
                      onTapDown: (_) {
                        setState(() {
                          buttonsrc =
                              'lib/assets/icons/friendButtonPressed.png';
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          buttonsrc = 'lib/assets/icons/friendButton.png';
                        });
                      },
                      onTapCancel: () => setState(() {
                        buttonsrc = 'lib/assets/icons/friendButton.png';
                      }),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(buttonsrc),
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
