import 'package:flutter/material.dart';
import 'package:myapp/smart_dropdown_field.dart';
import 'package:myapp/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Pagination Dropdown',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Pagination Dropdown'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SmartDropdownField<UserModel>(
                url: "https://63c1210999c0a15d28e1ec1d.mockapi.io/users",
                fromJson: (json) => UserModel.fromJson(json),
                itemAsString: (UserModel item) => item.name,
                defaultValue: UserModel(id: "3", name: "Jacob Kling IV"),
                idGetter: (UserModel item) => item.id,
                onChanged: (UserModel? selectedUser) {
                  print("Selected User: ${selectedUser?.name}");
                  print("Selected User: ${selectedUser?.id}");
                },
              ),
              const SizedBox(height: 20),
              SmartDropdownField<UserModel>(
                isMultiSelection: true,
                url: "https://63c1210999c0a15d28e1ec1d.mockapi.io/users",
                fromJson: (json) => UserModel.fromJson(json),
                itemAsString: (UserModel item) => item.name,
                idGetter: (UserModel item) => item.id,
                defaultValues: [
                  UserModel(id: "3", name: "Jacob Kling IV"),
                  UserModel(id: "2", name: "Alfredo Gusikowski")
                ],
                onChangedMulti: (List<UserModel>? selectedUser) {
                  print(
                      "Selected Users: ${selectedUser?.map((user) => user.name).toList()}");
                },
              ),
              const SizedBox(height: 20),
              SmartDropdownField<String>(
                items: const ["Option 1", "Option 2", "Option 3"],
                itemAsString: (String item) => item,
                defaultValue: "Option 4", // Default selected value
                onChanged: (String? selectedOption) {
                  print("Selected Option: $selectedOption");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
