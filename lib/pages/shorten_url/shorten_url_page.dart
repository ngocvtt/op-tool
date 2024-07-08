import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_generator/model/tinyurl.dart';
import 'package:qr_generator/repositories/tinyurl_repository.dart';

class ShortenUrlPage extends StatefulWidget {
  const ShortenUrlPage({super.key});

  @override
  State<ShortenUrlPage> createState() => _ShortenUrlPageState();
}

class _ShortenUrlPageState extends State<ShortenUrlPage> {
  final TextEditingController _longUrlController = TextEditingController();

  final TextEditingController _aliasController = TextEditingController();

  final TextEditingController _domainController = TextEditingController(text: "tinyurl.com");

  final TinyUrlRepo tinyUrlRepo = TinyUrlRepo();

  String urlResult = "";
  bool isError = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Shorten New Url",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: _longUrlController,
            decoration: InputDecoration(
                isDense: true,
                // and add this line
                contentPadding: EdgeInsets.all(15),
                labelText: 'Your long url',
                // Set border for enabled state (default)
                enabledBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(5),
                ),
                // Set border for focused state
                focusedBorder: OutlineInputBorder(
                  borderSide:
                  const BorderSide(width: 1, color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
                )),
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _domainController,
                    enabled: false,
                    decoration: InputDecoration(
                        isDense: true,
                        // and add this line
                        contentPadding: EdgeInsets.all(15),
                        labelText: 'Domain',
                        // Set border for enabled state (default)
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        )),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text("/"),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: _aliasController,
                    decoration: InputDecoration(
                        isDense: true,
                        // and add this line
                        contentPadding: EdgeInsets.all(15),
                        labelText: 'Alias',
                        // Set border for enabled state (default)
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // Set border for focused state
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                          const BorderSide(width: 1, color: Colors.blue),
                          borderRadius: BorderRadius.circular(5),
                        )),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: ElevatedButton(
                onPressed: () async {
                  if (_longUrlController.text.isEmpty)
                    return;

                  tinyUrlRepo.shortenUrl(longUrl: _longUrlController.text, alias: _aliasController.text).then((res){
                    if (res.isSuccess()){
                      setState(() {
                        isError = false;
                        urlResult = res.data?.tinyUrl?? "Some error happened";
                      });
                    }
                    else{
                      setState(() {
                        isError = true;
                        urlResult = res.errors?.join("\n")?? "Error";
                      });
                    }
                  });

                },
                child: const Text("Shorten URL")),
          ),
          SizedBox(height: 30,),
          Text(
            "Result",
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20,),
          isError? _buildError(): _buildSuccessResult()
        ],
      ),
    ));
  }


  Widget _buildSuccessResult(){
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
                borderRadius: BorderRadius.circular(5)
            ),
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(urlResult, style: TextStyle(color: Colors.black),),
          ),
        ),
        SizedBox(width: 10,),
        ElevatedButton(
            onPressed: () async {
              Clipboard.setData(ClipboardData(text: urlResult)).then((_){
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("URL copied to clipboard")));
              });
            },
            child: const Text("Copy")
        )
      ],
    );
  }

  Widget _buildError(){
    return Text("Error: $urlResult", style: TextStyle(color:Colors.red),);
  }

}
