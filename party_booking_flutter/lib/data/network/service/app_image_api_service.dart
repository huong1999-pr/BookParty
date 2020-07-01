import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:party_booking/data/network/model/base_list_response_model.dart';
import 'package:party_booking/data/network/model/base_response_model.dart';
import 'package:party_booking/res/constants.dart';
import 'package:party_booking/widgets/common/utiu.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppImageAPIService {
  static String token;
  final Dio dio;
  ProgressDialog progressDialog;

  AppImageAPIService({this.dio, this.progressDialog});

  Future<BaseResponseModel> updateAvatar(File imageToUpdate) async {
    FormData formData = new FormData.fromMap({
      "image": await MultipartFile.fromFile(imageToUpdate.path,
          filename: imageToUpdate.path?.split("/")?.last,
          contentType: MediaType('image', 'jpeg'))
    });

    BaseResponseModel response;
    var result = await dio
        .put(
      'user/avatar',
      data: formData,
    )
        .catchError((onError) {
      progressDialog.hide();
    });

    if (result.statusCode == 200) {
      response = BaseResponseModel.fromJson(result.data);
    }
    progressDialog.hide();
    return response;
  }

  Future<BaseListResponseModel> uploadImages(List<Asset> listImage) async {
    var listMultiPath = List();

    for(int i = 0; i < listImage.length; i++) {
      var image = listImage[i];
      var path =
      await FlutterAbsolutePath.getAbsolutePath(image.identifier);
      listMultiPath.add(
          MapEntry(
            'image', MultipartFile.fromFileSync(path,
              filename: image.name,
              contentType: MediaType('image', 'jpeg'))),
          );
    }

    FormData formData = FormData();
    formData.files.addAll([
      ...listMultiPath
    ]);

    BaseListResponseModel response;
    var result = await dio.post('product/upload_image', data: formData,
        onSendProgress: (int sent, int total) {
      _updateProgress(sent, total);
    }).catchError((onError) {
      print(onError);
      progressDialog.hide();
    });

    progressDialog.hide();

    if (result.statusCode == 200) {
      response = BaseListResponseModel.fromJson(result.data);
    } else {
      UTiu.showToast(message: BaseResponseModel.fromJson(result.data).message, isFalse: true);
    }
    progressDialog.hide();
    return response;
  }

  void _updateProgress(int sent, int total) {
    progressDialog.update(
      progress: (sent ~/ total * 100).toDouble(),
      message: "Please wait...",
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
  }

  static AppImageAPIService create(BuildContext context) {
    var random = Random();
    String boundary = 'dio-boundary-' +
        random.nextInt(4294967296).toString().padLeft(10, '0');
    BaseOptions options = new BaseOptions(
        baseUrl: "http://139.180.131.30:3000/",
        connectTimeout: 100000,
        receiveTimeout: 3000,
        method: 'POST'
    );
    Dio dio = new Dio(options);
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options options) async {
      // If no token, request token firstly and lock this interceptor
      // to prevent other request enter this interceptor.

      if (token == null) {
        dio.interceptors.requestLock.lock();
        // We use a new Dio(to avoid dead lock) instance to request token.
        SharedPreferences preferences = await SharedPreferences.getInstance();
        token = preferences.getString(Constants.USER_TOKEN);
      }
      //Set the token to headers
      options.headers["authorization"] = token;
      options.headers['content-type'] =
          "multipart/form-data; boundary=$boundary";
      dio.interceptors.requestLock.unlock();
      return options; //continue
    }));
    dio.interceptors.add(LogInterceptor(
        responseBody: true,
        error: true,
        request: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: true));

    //Progress
    ProgressDialog progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Download,
        isDismissible: false,
        showLogs: true);
    progressDialog.style(
        message: 'Uploading images...',
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));
    progressDialog.show();
    return AppImageAPIService(dio: dio, progressDialog: progressDialog);
  }
}
