import 'package:flutter/material.dart';
import 'package:flutter_url_image_load_fail/flutter_url_image_load_fail.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_url_image_load_fail Simple Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Example'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: LoadImageFromUrl(
              imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png', //Image URL to load
              buildSuccessWidget:  (image) => image,
              buildLoadingWidget:  () => Text('My custom loading...', style: TextStyle(fontSize: 21, color: Colors.blueAccent, fontWeight: FontWeight.w600),),
              buildFailedWidget: (void Function() retryLoadImage, int code, String errorMessage){
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      child: Text('An error occurred:\n\nError: $errorMessage\n\nCode: ${code.toString()}', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),),
                      padding: EdgeInsets.only(bottom: 30),
                    ),
                    ElevatedButton(
                      child: Text('Try again', style: TextStyle( fontSize: 18, fontWeight: FontWeight.w600),),
                      onPressed: (){
                        retryLoadImage();
                      },
                    ),
                  ],
                );
              },
              requestTimeout: Duration(seconds: 5) //Optionally set the timeout
          ),
        ),
      ),
    );
  }
}
