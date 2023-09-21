import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_generator/model/logo_config.dart';
import 'package:qr_generator/pages/qr/logo-config-cell.dart';

class LogoPicker extends StatefulWidget {
  final List<LogoConfig> logos;
  final LogoConfig initialLogo;
  final Function onLogoPicked;
  const LogoPicker({super.key, this.logos = const [], required this.onLogoPicked, required this.initialLogo});

  @override
  State<LogoPicker> createState() => _LogoPickerState();
}

class _LogoPickerState extends State<LogoPicker> {

  late LogoConfig currentLogo;

  @override
  void initState() {
    currentLogo = widget.initialLogo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick logo!'),
      content: Container(
        height: 300,
        width: 300,
        child: SingleChildScrollView(
          child: GridView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
            itemCount: widget.logos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
            ),
            itemBuilder: (BuildContext context, int index) {
              return _buildPickerCell(currentLogo.path == widget.logos[index].path, widget.logos[index]);
            }
          ),
          // child: GridView(
          //   // crossAxisAlignment: CrossAxisAlignment.start,
          //   gridDelegate: null,
          //   children: widget.logos.map((e) {
          //     print(e.name);
          //     return LogoConfigCell(logoConfig: e);
          //   }).toList(),
          // ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text("Look great!"),
          onPressed: () {
            widget.onLogoPicked(currentLogo);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }


  Widget _buildPickerCell(bool isPicked, LogoConfig logoConfig){
    return GestureDetector(
      onTap: (){
        setState(() {
          currentLogo = logoConfig;
        });
      },
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            border: Border.all(color: isPicked? Colors.blue: Colors.grey, width: isPicked? 3: 0),
            borderRadius: BorderRadius.circular(5.0)
        ),
        child: LogoConfigCell(logoConfig: logoConfig, size: 80, fontSize: 14,),
      ),
    );
  }
}
