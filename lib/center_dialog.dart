import 'package:flutter/cupertino.dart';

class CenterAlterWidget extends StatefulWidget {
  final Function onConfirm;
  final Function onCancel;
  final String title;
  final String desText;

  const CenterAlterWidget(this.title, this.desText, {required this.onConfirm, required this.onCancel});

  @override
  CenterAlterWidgetState createState() => CenterAlterWidgetState();
}

class CenterAlterWidgetState extends State<CenterAlterWidget> {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.title),
      content: Column(
        children: [
          const SizedBox(height: 10,),
          Align(
            alignment: const Alignment(0, 0),
            child: Text(widget.desText),
          )
        ],
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('已完成'),
          onPressed: () async {
            widget.onConfirm();
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: const Text('取消'),
          onPressed: () async {
            widget.onCancel();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

}