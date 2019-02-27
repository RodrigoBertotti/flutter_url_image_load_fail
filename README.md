# flutter_url_image_load_fail

Widget to Flutter that allow load images from an URL and define the Widgets that will be shown on states of loading, loaded with success and failed to load

## Getting Started

Add the dependency on pubspec.yaml
```yaml
dependencies:
  flutter_url_image_load_fail: ^0.0.1
```

Import the Widget
```dart
import 'package:flutter_url_image_load_fail/flutter_url_image_load_fail.dart';
```

Create the LoadImageFromUrl Widget and use it
```dart
LoadImageFromUrl(
    'https://upload.wikimedia.org/wikipedia/commons/1/17/Google-flutter-logo.png', //Image URL to load
    (image) => image, //What widget returns when the image is loaded successfully
    () => Text('Loading...'), //What widget returns when the image is loading
    (IRetryLoadImage retryLoadImage, code , message){ //What widget returns when the image failed to load
        return RaisedButton(
            onPressed: (){
                retryLoadImage.retryLoadImage(); //Call this method to retry load the image when it failed to load
            },
        );
    },
)```