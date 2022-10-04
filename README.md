# RxFuture

A powerful library that integrate Getx Rx to introduce a new type called RxFuture which make it easy to handle future states (loading, error) and get the result of this future, with some functionality like canceling the future.

## Get started

### Add dependency

```yaml
dependencies:
  rx_future: ^1.0.2
```

### Super simple to use

1- import rx_future and get state manager then create your own GetxController.

```dart
import 'package:get/state_manager.dart';
import 'package:rx_future/rx_future.dart';

class MyController extends GetxController {}

```

2- declare your rxFuture, and pass initial value.

```dart
class MyController extends GetxController {
    RxFuture<Map<String, dynamic>> state = RxFuture({});
}
```

3- define your functions to trigger the future

```dart
class MyController extends GetxController {
  RxFuture<Map<String, dynamic>> state = RxFuture({});

  Future<void> getData() async {

  }
}

```

4- now trigger the state by passing a future callback to the observe method.

```dart
class MyController extends GetxController {
  RxFuture<Map<String, dynamic>> state = RxFuture({});

  Future<void> getData() async {
    // you have access to value here, so you can maybe depend on it to get a new data.
    await state.observe((value) async {
      // this callback should return Future<T> or
      // Future<Map<String , dynamic>> in our case.
      return await myApi();
    });
  }
}

```

5- now you can use state.error & state.loading by listening to them in your ui code

```dart

Obx(() {
    // handle loading state.
    if(myController.state.loading){
        return const CircularProgressIndicator();
    }

    // handle error state
    if(myController.state.hasError){
        return Text(myController.state.error.toString());
    }

    // you have result to show.
    return MyWidget(myController.state.result);

})

```

That was so easy, wasn't it?

` Declare more than one RxFuture for multiple state to handle.`

## More

let's have a closer look on more functionality

1- hooks there is many hooks that would be triggered in different situations, here is an example:

```dart
await state.observe(
  (value) async {
    return await myApi();
  },
  // triggered once our future is completed.
  onSuccess: (value) {
     print("success $value");
  },

  // triggered once our future throw an error, providing the error.
  onError: (e) {},

  // triggered when our future canceled by .cancel() method.
  onCancel: () {},
);

```

for example canceling your future is easy now, just call .cancel() method on your RxFuture

```dart
void cancel(){
  state.cancel();
}
```

the above code would cancel any running future in this RxFuture, and would trigger onCancel method.

`What happen on multiple calls? what would happen to my state `

by default when you call state.observe() more than one time before it is completed, it would ignore the new calls, always changing your state due to your first call until it will completed.

you can change this behavior be passing MultipleCallsBehavior param to the observe method

```dart
state.observe(
  (val) async {
    return await myApi();
  },
  // the default, ignoring new calls until the first call completed.
  multipleCallsBehavior: MultipleCallsBehavior.abortNew,
)
```

to ignore old calls and refresh your state due to your new calls use MultipleCallsBehavior.abortOld

```dart
state.observe(
  (val) async {
    return await myApi();
  },
  // the default, ignoring old calls and refresh the state due to new call.
  multipleCallsBehavior: MultipleCallsBehavior.abortOld,
)
```

calling .observe more than one when loading would trigger onMultipleCalls hook

```dart
await state.observe(
  (value) async {
    return await myApi();
  },
  // triggered once our future is completed.
  onMultipleCalls: () {},
);

```

## ❤️ Found this project useful?

If you found this project useful, then please consider giving it a ⭐ on Github and sharing it with your friends via social media.
