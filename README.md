# flutter_url_image_load_fail

Flutter Widget that allows load images from an URL and define the Widgets that will be shown on loading, loaded with success and failed to load states

## Getting Started

![Alt Text](example/example.gif)

Add the dependency on pubspec.yaml
```yaml
dependencies:
  flutter_url_image_load_fail: ^1.0.0
```

Import the Widget
```dart
import 'package:flutter_url_image_load_fail/flutter_url_image_load_fail.dart';
```

Instantiate the LoadImageFromUrl Widget and use it
```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flutter_url_image_load_fail example'),
      ),
      body: Center(
        child: LoadImageFromUrl(
          imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png', //Image URL to load
          buildSuccessWidget:  (image) => image,
          buildLoadingWidget:  () => Text('Loading...'),
          buildFailedWidget: (retryLoadImage, code, message){
              return ElevatedButton(
                child: Text('Try Again'),
                onPressed: (){
                  retryLoadImage();
                },
              );
            },
            requestTimeout: Duration(seconds: 5) //Optionally set the timeout
        ),
      ),
    );
  }
```
