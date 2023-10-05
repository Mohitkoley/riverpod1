import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:http/http.dart" as http;
import 'package:riverpod1/model/user_model.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

final helloWorldProvider = Provider((ref) => "Hello world");

final counterStateProvider = StateProvider((ref) => 0);

final apiData = FutureProvider.autoDispose<List<TodoModel>>((ref) async {
  try {
    final response =
        await http.get(Uri.https("jsonplaceholder.typicode.com", "/todos"));
    if (response.statusCode == 200) {
      List<TodoModel> listData = todoModelFromJson(response.body);
      return listData;
    }
  } catch (e) {
    rethrow;
  }
  return [];
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Widget? _onFetchindData(WidgetRef ref, BuildContext context) {
    final result = ref.watch(apiData);

    return result.when(
        data: (data) {
          return data.isEmpty
              ? const Text("No data")
              : Container(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ...data.map((e) => Text(e.title)).toList(),
                      ],
                    ),
                  ),
                );
        },
        error: (obj, err) {
          return Text("$err");
        },
        loading: () => const CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final number = ref.watch(counterStateProvider);
    final call = ref.read(counterStateProvider.notifier);

    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Riverpod"),
          actions: [
            IconButton(
                onPressed: () {
                  call.update((state) => state - 1);
                },
                icon: Icon(Icons.remove))
          ],
        ),
        //body: _onFetchindData(ref, context),
        body: Center(
          child: Text(number.toString(), style: TextStyle(fontSize: 30)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            call.update((state) => state + 1);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
