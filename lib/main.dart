import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_face_api/face_api.dart' as Regula;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var image1 = new Regula.MatchFacesImage();
  var image2 = new Regula.MatchFacesImage();
  String _similarity = "0.0";






  Future<String?> networkImageToBase64(String imageUrl) async {
    http.Response response = await http.get(Uri.parse(imageUrl));
    final bytes = response?.bodyBytes;
    return (bytes != null ? base64Encode(bytes) : null);
  }

  setImage(bool first, Uint8List? imageFile, int type) {
    if (imageFile == null) return;
    setState(() => _similarity = "0.0");
    if (first) {
      image1.bitmap = base64Encode(imageFile);
      image1.imageType = type;

    } else {
      image2.bitmap = base64Encode(imageFile);
      image2.imageType = type;

    }
  }
  pickFromUrl(){
    if (image2.bitmap==null){
      print('null');
    }
    else{
      setImage(
          false,
          base64Decode(
              image2.bitmap!.replaceAll("\n", "")),
          Regula.ImageType.PRINTED);
      print('succes');
    }
  }

  matchimage () async {
    image2.bitmap = await networkImageToBase64('https://lh3.googleusercontent.com/a/ACg8ocIKb9fnqHYHtqFZgID3dKMtOqSMRDzkVoIl2MyqoDLC3Zk=s96-c-rg-br100');

    if (image1.bitmap == null ||
        image1.bitmap == "" ||
        image2.bitmap == null ||
        image2.bitmap == "") return;
    setState(() => _similarity = "Processing...");
    var request = new Regula.MatchFacesRequest();
    request.images = [image1, image2];
    Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
      var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
      Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75)
          .then((str) {
        var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
            json.decode(str));
        setState(() => _similarity = split!.matchedFaces.length > 0
            ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
            "%")
            : "error");
      });
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pickFromUrl();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // image2.bitmap = base64Encode(img2);




    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Container(
                width: 300,
                height: 300,
              ),
              // ElevatedButton(onPressed: ()async{
              //
              //   image2.bitmap = await networkImageToBase64('https://lh3.googleusercontent.com/a/ACg8ocIKb9fnqHYHtqFZgID3dKMtOqSMRDzkVoIl2MyqoDLC3Zk=s96-c-rg-br100');
              //
              //   if (image1.bitmap == null ||
              //       image1.bitmap == "" ||
              //       image2.bitmap == null ||
              //       image2.bitmap == "") return;
              //   setState(() => _similarity = "Processing...");
              //   var request = new Regula.MatchFacesRequest();
              //   request.images = [image1, image2];
              //   Regula.FaceSDK.matchFaces(jsonEncode(request)).then((value) {
              //     var response = Regula.MatchFacesResponse.fromJson(json.decode(value));
              //     Regula.FaceSDK.matchFacesSimilarityThresholdSplit(
              //         jsonEncode(response!.results), 0.75)
              //         .then((str) {
              //       var split = Regula.MatchFacesSimilarityThresholdSplit.fromJson(
              //           json.decode(str));
              //       setState(() => _similarity = split!.matchedFaces.length > 0
              //           ? ((split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2) +
              //           "%")
              //           : "error");
              //     });
              //   });
              //
              //
              //
              // },child: Text('similarity')),
              ElevatedButton(onPressed: () async{


             await   Regula.FaceSDK.presentFaceCaptureActivity().then((result){

                  var response = Regula.FaceCaptureResponse.fromJson(
                      json.decode(result))!;
                  if (response.image != null &&
                      response.image!.bitmap != null)
                    setImage(
                        true,
                        base64Decode(
                            response.image!.bitmap!.replaceAll("\n", "")),
                        Regula.ImageType.LIVE);
                });
             matchimage();




              }, child: Text('pick')),
              Text(_similarity),




            ],
          ),
        ),
      ),
    );
  }
}




