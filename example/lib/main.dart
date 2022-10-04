import 'dart:math';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:rx_future/rx_future.dart';

void main() {
  Get.put<MyController>(MyController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  final MyController controller = Get.find<MyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            FloatingActionButton(
              onPressed: () {
                controller.cancel();
              },
            ),
            Obx(() {
              return Text(
                '${controller.state.result}',
                style: Theme.of(context).textTheme.headline4,
              );
            }),
            Obx(() {
              print("the value of loading is ${controller.state.loading}");
              if (controller.state.loading) {
                return const CircularProgressIndicator();
              } else {
                if (controller.state.hasError) {
                  return Text(controller.state.error.toString());
                }
              }
              return Text("${controller.state.lastResult}");
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.getData();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

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
