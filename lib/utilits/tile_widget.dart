import 'package:flutter/material.dart';
import 'package:imager/styles/global_style.dart';

class Tile extends StatefulWidget {
  final String name;
  final IconData icon;
  final VoidCallback onClick;
  final bool disabled;
  const Tile({Key? key, required this.name, required this.icon, required this.onClick, required this.disabled}) : super(key: key);

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color:  Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(width: 1, style: BorderStyle.solid, color: Colors.deepOrange)

        ),
        child: InkWell(
          onTap: !widget.disabled ? widget.onClick : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 50, color: !widget.disabled ? Colors.deepOrange : Colors.grey),
                ],
              ),
              Text(widget.name, style: GlobalTextStyle.button_text_14_white)
            ],
          ),
        )
      ),
    );
  }

}
