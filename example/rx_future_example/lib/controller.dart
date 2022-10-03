import 'dart:math';

import 'package:get/get.dart';
import 'package:rx_future/rx_future.dart';

class MyController extends GetxController {
  RxFuture<int> state = RxFuture(0);

  Future<void> getData() async {
    await state.observe(
      (val) async {
        return await getRandomNumber();
      },
      onSuccess: (val) {
        print("Success Getting Number $val");
      },
    );
  }

  void cancel() {
    state.cancel();
  }
}

Future<int> getRandomNumber() async {
  await Future.delayed(const Duration(seconds: 3));
  return Random().nextInt(500);
}
