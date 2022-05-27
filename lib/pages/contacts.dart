import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:untitled/widgets.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  dynamic contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Select Contact Number"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              FutureBuilder(
                future: getContacts(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  print(snapshot.data.length);
                  return Column(
                    children: [
                      RoundedInputField(
                        obscureText: false,
                        onChanged: (value) async {
                          setState(() {
                            contact = ContactsService.getContacts(
                                withThumbnails: false,
                                query: searchController.text);
                          });
                        },
                        label: 'Search',
                        controller: searchController,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .80,
                        child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              contact = snapshot.data;
                              String name = contact![index]!.displayName;
                              List<Item> num = contact![index]!.phones;

                              return Column(children: [
                                InkWell(
                                  onTap: () {
                                    try {
                                      final number = Contact(phones: num)
                                          .toMap()['phones'][0]['value'];
                                      print(number);

                                      Navigator.pop(context, number);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Contact Number Does Not Exist'),
                                        ),
                                      );
                                    }
                                  },
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      radius: 20,
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(name),
                                  ),
                                ),
                                const Divider()
                              ]);
                            }),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Contact>> getContacts() async {
    bool isGranted = await Permission.contacts.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.contacts.request().isGranted;
    }
    if (isGranted) {
      // if (searchController.text)
      return await ContactsService.getContacts(
          withThumbnails: false, query: searchController.text);
    }
    return [];
  }
}
