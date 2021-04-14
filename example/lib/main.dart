import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:face/face_detect_plugin.dart';
import 'package:face/model/version_info_model.dart';
import 'package:face/model/active_file_info_model.dart';
import 'package:face/enum/face_detect_orient_priority_enum.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'face_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  Future<bool> activeOnLine() async {
    try {
      bool result = await FaceDetectPlugin.activeOnLine(
          "GJht4drCMdH9t2qV4trUbgeERDNAgdgr9bExHx3cuPCf",
          "9KH8HkgNmshhqRKqZqDxR1cbmeuKjC7vUJLSREaAGGU6");
      return result;
    } catch (e) {
      print(e.message);
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    goToCamera();
  }

  Future<void> goToCamera() async {
    await [
      Permission.camera,
      Permission.storage,
      Permission.phone
    ].request();
    //await Permission.camera.request();
    await activeOnLine();
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new CameraView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _platformVersion = 'Unknown';
  final picker = ImagePicker();
  @override
  void initState() {
    super.initState();
  }

  Future<bool> activeOnLine() async {
    try {
      bool result = await FaceDetectPlugin.activeOnLine(
          "GJht4drCMdH9t2qV4trUbgeERDNAgdgr9bExHx3cuPCf",
          "9KH8HkgNmshhqRKqZqDxR1cbmeuKjC7vUJLSREaAGGU6");
      return result;
    } catch (e) {
      print(e.message);
    }
  }

  Future<void> getSdkVersion() async {
    try {
      VersionInfoModel result = await FaceDetectPlugin.getSdkVersion();
      print(result.version);
    } catch (e) {
      print(e);
    }
  }

  Future<void> getActiveFileInfo() async {
    try {
      ActiveFileInfoModel result = await FaceDetectPlugin.getActiveFileInfo();
      print(result.toString());
    } catch (e) {
      print(e);
    }
  }

  Future<void> setFaceDetectOrientPriority(
      FaceDetectOrientPriorityEnum faceDetectOrientPriorityEnum) async {
    try {
      await FaceDetectPlugin.setFaceDetectDegree(faceDetectOrientPriorityEnum);
      print(faceDetectOrientPriorityEnum);
      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }
  Future<void> getImageToolVersion() async {
    try {
      var result = await FaceDetectPlugin.getImageToolVersion();
      print(result);
    } catch (e) {
      print(e);
    }
  }

  Uint8List buffer1;
  Uint8List buffer2;
  Future getFaceFeature1() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        var  _image = File(pickedFile.path);
        var buffer = await _image.readAsBytes();
        var ret= await FaceDetectPlugin.getFaceFeature(buffer);
        if(ret!=null && ret.isNotEmpty){
          print(ret.length);
          print(ret[0].runtimeType);
          print(ret[0] is Uint8List);
          print(ret[0]);
          buffer1= ret[0];
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

  Future getFaceFeature2() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        var  _image = File(pickedFile.path);
        var buffer = await _image.readAsBytes();
        var ret= await FaceDetectPlugin.getFaceFeature(buffer);
        if(ret!=null && ret.isNotEmpty){
          print(ret.length);
          print(ret[0].runtimeType);
          print(ret[0] is Uint8List);
          print(ret[0]);
          buffer2= ret[0];
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
  Future compareFaceFeature() async {
    if (buffer1!=null && buffer2!=null){
      var ret= await FaceDetectPlugin.compareFaceFeature(buffer1, buffer2);
      print('Score: $ret');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        children: <Widget>[
          Text('Running on: $_platformVersion\n'),
          RaisedButton(
            child: Text("注册引擎"),
            onPressed: activeOnLine,
          ),
          RaisedButton(
            child: Text("获取注册信息"),
            onPressed: getActiveFileInfo,
          ),
          RaisedButton(
            child: Text("获取版本信息"),
            onPressed: getSdkVersion,
          ),
          RaisedButton(
            child: Text("设置视频人脸检测角度"),
            onPressed: () => setFaceDetectOrientPriorityView(context),
          ),
          RaisedButton(
            child: Text("相机模式人脸检测"),
            onPressed: () {
              print("打开相机");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CameraView()));
            },
          ),
          ElevatedButton(onPressed: getImageToolVersion, child: Text("获取Tool版本")),
          ElevatedButton(onPressed: getFaceFeature1, child: Text("照片1")),
          ElevatedButton(onPressed: getFaceFeature2, child: Text("照片2")),
          ElevatedButton(onPressed: compareFaceFeature, child: Text("对比")),
        ],
      ),
    );
  }

  void setFaceDetectOrientPriorityView(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 240.0,
            color: Color(0xfff1f1f1),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () => setFaceDetectOrientPriority(
                        FaceDetectOrientPriorityEnum.ASF_OP_0_ONLY),
                    child: Text("视频模式仅检测0度"),
                  ),
                  RaisedButton(
                    onPressed: () => setFaceDetectOrientPriority(
                        FaceDetectOrientPriorityEnum.ASF_OP_90_ONLY),
                    child: Text("视频模式仅检测90度"),
                  ),
                  RaisedButton(
                    onPressed: () => setFaceDetectOrientPriority(
                        FaceDetectOrientPriorityEnum.ASF_OP_180_ONLY),
                    child: Text("视频模式仅检测180度"),
                  ),
                  RaisedButton(
                    onPressed: () => setFaceDetectOrientPriority(
                        FaceDetectOrientPriorityEnum.ASF_OP_270_ONLY),
                    child: Text("视频模式仅检测270度"),
                  ),
                  RaisedButton(
                    onPressed: () => setFaceDetectOrientPriority(
                        FaceDetectOrientPriorityEnum.ASF_OP_ALL_OUT),
                    child: Text("视频模式全方向人脸检测"),
                  )
                ]),
          );
        });
  }


}
