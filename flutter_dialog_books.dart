import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyData {
  final int id;
  final String title;
  final String body;
  final int userId;

  MyData({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
  });

  factory MyData.fromJson(Map<String, dynamic> json) {
    return MyData(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }
}

void main() {
  runApp(MyApp());
}
stl
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controllerTitle = TextEditingController();
  final TextEditingController _controllerBody = TextEditingController();
  final TextEditingController _controllerUserId = TextEditingController();

  List<MyData> dataList = [];

  final String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        dataList = List<MyData>.from(
          responseData.map((json) => MyData.fromJson(json)),
        );
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future postData(MyData data) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );
    if (response.statusCode == 201) {
      fetchData();
    } else {
      throw Exception('Failed to add data');
    }
  }

  Future updateData(MyData data) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${data.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data.toJson()),
    );
    if (response.statusCode == 200) {
      fetchData();
      print("salam2");
    } else {
      throw Exception('Failed to update data');
    }
  }

  Future deleteData(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      fetchData();
    } else {
      throw Exception('Failed to delete data');
    }
  }

  Future<void> showAddDialog() async {
  TextEditingController addTitleController = TextEditingController();
  TextEditingController addBodyController = TextEditingController();
  TextEditingController addUserIdController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add Data'),
        content: Column(
          children: [
            TextField(
              controller: addTitleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: addBodyController,
              decoration: InputDecoration(labelText: 'Body'),
            ),
            TextField(
              controller: addUserIdController,
              decoration: InputDecoration(labelText: 'UserID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Dispose controllers when the dialog is closed
              addTitleController.dispose();
              addBodyController.dispose();
              addUserIdController.dispose();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              MyData newData = MyData(
                id: 0, // You may set a placeholder value or generate it on the server side
                title: addTitleController.text,
                body: addBodyController.text,
                userId: int.tryParse(addUserIdController.text) ?? 0,
              );
              postData(newData);
              Navigator.of(context).pop();
              // Dispose controllers when the dialog is closed
              addTitleController.dispose();
              addBodyController.dispose();
              addUserIdController.dispose();
            },
            child: Text('Add'),
          ),
        ],
      );
    },
  );
}



    Future<void> showDeleteConfirmationDialog(int id) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Data'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      deleteData(id);
    }
  }

  Future<void> showUpdateDialog(MyData data) async {
    TextEditingController updateTitleController = TextEditingController();
    TextEditingController updateBodyController = TextEditingController();
    TextEditingController updateUserIdController = TextEditingController();

    updateTitleController.text = data.title;
    updateBodyController.text = data.body;
    updateUserIdController.text = data.userId.toString();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Data'),
          content: Column(
            children: [
              TextField(
                controller: updateTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: updateBodyController,
                decoration: InputDecoration(labelText: 'Body'),
              ),
              TextField(
                controller: updateUserIdController,
                decoration: InputDecoration(labelText: 'UserID'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Dispose controllers when the dialog is closed
                updateTitleController.dispose();
                updateBodyController.dispose();
                updateUserIdController.dispose();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update data using the new values from controllers
                MyData updatedData = MyData(
                  id: data.id,
                  title: updateTitleController.text,
                  body: updateBodyController.text,
                  userId: int.tryParse(updateUserIdController.text) ?? 0,
                );
                updateData(updatedData);
                Navigator.of(context).pop();
                // Dispose controllers when the dialog is closed
                updateTitleController.dispose();
                updateBodyController.dispose();
                updateUserIdController.dispose();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _controllerTitle.dispose();
    _controllerBody.dispose();
    _controllerUserId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD App'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _controllerTitle,
                  decoration: InputDecoration(labelText: 'Enter Title'),
                ),
                TextField(
                  controller: _controllerBody,
                  decoration: InputDecoration(labelText: 'Enter Body'),
                ),
                TextField(
                  controller: _controllerUserId,
                  decoration: InputDecoration(labelText: 'Enter UserID'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showAddDialog();
                  },
                  child: Text('Add Data'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('ID: ${dataList[index].id} - ${dataList[index].title}'),
                  subtitle: Text(dataList[index].body),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showUpdateDialog(dataList[index]);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDeleteConfirmationDialog(dataList[index].id);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
