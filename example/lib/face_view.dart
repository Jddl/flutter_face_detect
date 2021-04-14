import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:face/face_detect_camera_view.dart';
import 'package:face/face_detect_plugin.dart';
import 'package:image_picker/image_picker.dart';

class CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {

  FaceDetectCameraController faceController;
  double score = 0;
  String picPath ;
  final picker = ImagePicker();
  Uint8List buffer1;
  Future getFaceFeature1() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        var  _image = File(pickedFile.path);
        var buffer = await _image.readAsBytes();
        var ret= await FaceDetectPlugin.getFaceFeature(buffer);
        if(ret!=null && ret.isNotEmpty){
          buffer1= ret[0];
          print(buffer1);
          setState(() {
            picPath = pickedFile.path;
          });
        }else{
          print('未找到人脸');
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            FaceDetectCameraView(
              showRectView: true,
              faceViewCreatedCallback: (FaceDetectCameraController faceController) {
                this.faceController = faceController
                    ..faceDetectStreamListen((data) async {
                      print(data.runtimeType);
                      if (data is List<FaceDetectInfoModel>){
                          var list = data;
                          for(var face in list){
                            print(face.feature);

                            if(buffer1!=null){
                              var ret= await FaceDetectPlugin.compareFaceFeature(buffer1, face.feature);
                                setState(() {
                                  score = ret;
                                });
                            }
                          }
                      }
                    });
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(onPressed: getFaceFeature1, child: Text("选择对比照片")),
                    picPath==null?Container():Image.file(File(picPath),width: 100,height: 100,),
                    Text('对比得分：$score',style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
