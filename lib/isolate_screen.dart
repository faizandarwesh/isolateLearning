import 'dart:isolate';

import 'package:flutter/material.dart';

class IsolateScreen extends StatelessWidget {
  const IsolateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Learning Isolate"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/images/bouncy_ball.gif",
              width: 200,
              height: 200,
            ),
            ElevatedButton(
                onPressed: () {
                  double result = complexTask1();
                  print("Total : $result");
                },
                child: const Text("Task 1")),
            ElevatedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  await Isolate.spawn(complexTask2, receivePort.sendPort);
                  receivePort.listen((total) {
                    debugPrint("Total : $total");
                  });
                },
                child: const Text("Task 2")),
            ElevatedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  await Isolate.spawn(complexTask3,
                      (iteration: 1000000000, sendPort: receivePort.sendPort));
                  receivePort.listen((result) {
                    print("Total : $result");
                  });
                },
                child: const Text("Task 3")),
            ElevatedButton(
                onPressed: () async {
                  final receivePort = ReceivePort();
                  await Isolate.spawn(complexTask4,
                      (1000000000,receivePort.sendPort));
                  receivePort.listen((result) {
                    print("Total : $result");
                  });
                },
                child: const Text("Task 4")),
          ],
        ),
      ),
    );
  }

  double complexTask1() {
    var total = 0.0;

    for (int i = 0; i < 1000000000; i++) {
      total += i;
    }

    return total;
  }
}

complexTask2(SendPort sendPort) {
  var total = 0.0;

  for (int i = 0; i < 1000000000; i++) {
    total += i;
  }

  sendPort.send(total);
}

complexTask3(({int iteration, SendPort sendPort}) data) {
  var total = 0.0;

  for (int i = 0; i < data.iteration; i++) {
    total += i;
  }

  data.sendPort.send(total);
}

complexTask4((int iteration, SendPort sendPort) data) {
  var total = 0.0;

  for (int i = 0; i < data.$1; i++) {
    total += i;
  }

  data.$2.send(total);
}
