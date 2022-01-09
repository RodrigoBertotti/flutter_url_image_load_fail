library flutter_url_image_load_fail;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';


typedef Widget BuildFailedWidget(void retryLoadImage(), int responseStatusCode, String responseMessage);
typedef Widget BuildSuccessWidget(Image image);
typedef Widget BuildLoadingWidget();

class LoadImageFromUrl extends StatefulWidget {
  final String imageUrl;
  Image? imageResult;
  BuildLoadingWidget? buildLoadingWidget;
  BuildFailedWidget? buildFailedWidget;
  BuildSuccessWidget buildSuccessWidget;
  Duration? requestTimeout;

  LoadImageFromUrl(
      {
        required this.imageUrl, required this.buildSuccessWidget,
        this.buildLoadingWidget, this.buildFailedWidget,
        this.requestTimeout,
      });

  @override
  State<StatefulWidget> createState() {
    return LoadImageFromUrlState(
      buildSuccessWidget: buildSuccessWidget,
      imageUrl: imageUrl,
      buildFailedWidget: buildFailedWidget,
      buildLoadingWidget: buildLoadingWidget,
      requestTimeout: requestTimeout
    );
  }
}

class LoadImageFromUrlState extends State<LoadImageFromUrl> {

  final String imageUrl;
  BuildLoadingWidget? buildLoadingWidget;
  BuildFailedWidget? buildFailedWidget;
  BuildSuccessWidget buildSuccessWidget;
  ImageState imageState = ImageState.LOADING;
  late Duration requestTimeout;
  Image? imageResult;
  int responseStatusCode = -1;
  String responseMessage = '';

  LoadImageFromUrlState({
    required this.imageUrl, required this.buildSuccessWidget,
    this.buildLoadingWidget, this.buildFailedWidget,
    Duration? requestTimeout,
  }){
    this.requestTimeout = requestTimeout != null ? requestTimeout : Duration(seconds: 5);
  }

  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage({int? width, int? height}) async {
    setState(() {
      imageResult = null;
      imageState = ImageState.LOADING;
      responseStatusCode = -1;
    });

    HttpClient http = HttpClient();
    http
        .getUrl(Uri.parse(imageUrl))
        .then((HttpClientRequest request) {
          //headers
          return request.close();
        })
        .timeout(requestTimeout)
        .then((response) {
          responseMessage = response.reasonPhrase;
          responseStatusCode = response.statusCode;

          response.toList().timeout(requestTimeout, onTimeout: () {
            setState(() {
              imageState = ImageState.ERROR;
              responseMessage = 'Request Timeout';
              responseStatusCode = 408;
            });
            return [];
          }).then((value) {
            List<int> v = [];
            for (List<int> aux in value) {
              v += aux;
            }
            String errorMessageOrResult = String.fromCharCodes(v);
            setState(() {
              if (errorMessageOrResult.length < 1000 &&
                  errorMessageOrResult.contains("File not found")
              ) {
                imageState = ImageState.ERROR;
                responseMessage = errorMessageOrResult;
              } else {
                imageResult = Image.memory(Uint8List.fromList(v));
                imageState = ImageState.SUCCESS;
              }
            });
          }, onError: (e) {
            setState(() {
              imageState = ImageState.ERROR;
              responseMessage = e.toString();
            });
          });
        }, onError: (e) {
          setState(() {
            imageState = ImageState.ERROR;
            responseMessage = e.toString();
            responseStatusCode = 400;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    if (imageState == ImageState.SUCCESS) {
      try {
        return buildSuccessWidget(imageResult!);
      }catch(e){
        imageState = ImageState.ERROR;
        responseStatusCode = 400;
        responseMessage = e.toString();
        imageResult = null;
      }
    }
    if (imageState == ImageState.LOADING) {
      return buildLoadingWidget == null
        ? Container()
        : buildLoadingWidget!();
    }
    return buildFailedWidget == null
        ? Container()
        : buildFailedWidget!(
          this.loadImage, responseStatusCode, responseMessage
        );
  }


}

enum ImageState { LOADING, ERROR, SUCCESS }