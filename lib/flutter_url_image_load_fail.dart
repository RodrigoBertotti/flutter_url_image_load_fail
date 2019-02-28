library flutter_url_image_load_fail;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

abstract class IRetryLoadImage{
  void retryLoadImage();
}
typedef Widget BuildFailedWidget(IRetryLoadImage retry, int responseStatusCode, String responseMessage);
typedef Widget BuildSucessWidget(Image image);
typedef Widget BuildLoadingWidget();

class LoadImageFromUrl extends StatefulWidget {
  final String imageUrl;
  Image imageResult;
  BuildLoadingWidget buildLoadingWidget;
  BuildFailedWidget  buildFailedWidget;
  BuildSucessWidget  buildSucessWidget;
  ImageState imageState;
  int responseStatusCode = -1;
  String responseMessage = '';
  Duration requestTimeout;

  LoadImageFromUrl(
    this.imageUrl,
    this.buildSucessWidget,
    this.buildLoadingWidget,
    this.buildFailedWidget,
    {
      requestTimeout
    }
  ){
    this.requestTimeout = requestTimeout != null ? requestTimeout : Duration(seconds: 5);
  }

  @override
  State<StatefulWidget> createState() {
    return LoadImageFromUrlState();
  }
}

class LoadImageFromUrlState extends State<LoadImageFromUrl> implements IRetryLoadImage{
  void initState() { 
    super.initState();
    loadImage();
  }
  Future<void> loadImage({int width, int height}) async {
    setState(() {
      widget.imageResult = null;
      widget.imageState = ImageState.LOADING; 

      HttpClient http = HttpClient();    
      http.getUrl(Uri.parse(widget.imageUrl))
      .then((HttpClientRequest request){
        //headers
        return request.close();
      })
      .timeout(widget.requestTimeout)
      .then((response){
        widget.responseMessage = response.reasonPhrase;
        widget.responseStatusCode = response.statusCode;

        response.toList().timeout(widget.requestTimeout, onTimeout: (){
          setState(() {
            widget.imageState = ImageState.ERROR; 
            widget.responseMessage = 'Request Timeout';
            widget.responseStatusCode = 408;
          });
        }).then((onValue){ 
          setState(() {
            List<int> v = [];
            for(List<int> aux in onValue){
              v += aux;
            }
            widget.imageResult = Image.memory(Uint8List.fromList(v));
            widget.imageState = ImageState.SUCCESS; 
          });          
        }, onError: (e){
          setState(() {
            widget.imageState = ImageState.ERROR; 
            widget.responseMessage = e.toString();
          });
        });
      }, onError: (e){
        setState(() {
          widget.imageState = ImageState.ERROR; 
          widget.responseMessage = e.toString();
        });
      });
    });    
  }

  @override
  Widget build(BuildContext context) {
    if(widget.imageState == ImageState.LOADING){
      return widget.buildLoadingWidget();
    }else if(widget.imageState == ImageState.ERROR){
      return widget.buildFailedWidget(this, widget.responseStatusCode, widget.responseMessage);
    }
    return widget.buildSucessWidget(widget.imageResult);
  }

  @override
  void retryLoadImage() {
    loadImage();
  }
}

enum ImageState { LOADING, ERROR, SUCCESS }