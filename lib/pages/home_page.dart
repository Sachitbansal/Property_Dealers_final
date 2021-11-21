import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/add.dart';
import 'package:untitled/pages/update_prooperty.dart';
import 'home.dart';
import 'loginPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.uid,
  }) : super(key: key);
  final String? uid;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = false;
  late String dropdownValue = 'name';
  late Map<String, dynamic> userMap;
  final TextEditingController searchController = TextEditingController();
  final itemList = ['name', 'password', 'Pin Code', 'State'];
  final authUserid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    void onSearch() async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      setState(() {
        isLoading = true;
      });

      await firestore
          .collection(widget.uid.toString())
          .where(dropdownValue, isEqualTo: searchController.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
      });
    }

    logout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are now Signed Out'),
        ),
      );
    }

    final Stream<QuerySnapshot> studentsStream = FirebaseFirestore.instance
        .collection(widget.uid.toString())
        .snapshots();

    DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 20),
          ),
        );

    // For Deleting User
    CollectionReference students =
        FirebaseFirestore.instance.collection(widget.uid.toString());
    Future<void> deleteUser(id) {
      return students.doc(id).delete();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Add(
              collection: widget.uid.toString(),
            ),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Dashboard'),
            TextButton(
              onPressed: () {
                logout();
              },
              child: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: studentsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Something Went Wrong.'),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final List storedocs = [];
                  snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map a = document.data() as Map<String, dynamic>;
                    storedocs.add(a);
                    a['id'] = document.id;
                  }).toList();

                  return isLoading
                      ? const Center(
                          child: Text('Loading'),
                        )
                      : Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(10),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blue, width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: onSearch,
                                  ),
                                  hintText: 'Search',
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(10),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.blue, width: 1.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: dropdownValue,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 10,
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValue = value!;
                                  });
                                },
                                items: itemList.map(buildMenuItem).toList(),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 20.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Table(
                                  border: TableBorder.all(),
                                  columnWidths: const <int, TableColumnWidth>{
                                    1: FixedColumnWidth(140),
                                  },
                                  defaultVerticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Container(
                                            color: Colors.greenAccent,
                                            child: const Center(
                                              child: Text(
                                                'Name',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            color: Colors.greenAccent,
                                            child: const Center(
                                              child: Text(
                                                'Email',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            color: Colors.greenAccent,
                                            child: const Center(
                                              child: Text(
                                                'Action',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    for (var i = 0;
                                        i < storedocs.length;
                                        i++) ...[
                                      TableRow(
                                        children: [
                                          TableCell(
                                            child: Center(
                                              child: Text(
                                                storedocs[i]['buyRent'],
                                                style: const TextStyle(
                                                    fontSize: 18.0),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Center(
                                              child: Text(
                                                storedocs[i]['bedRooms'],
                                                style: const TextStyle(
                                                    fontSize: 18.0),
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                IconButton(
                                                  onPressed: () => {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdateStudentPage(
                                                          id: storedocs[i]
                                                              ['id'],
                                                          collection: widget.uid
                                                              .toString(),
                                                        ),
                                                      ),
                                                    )
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.orange,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () => {
                                                    deleteUser(
                                                        storedocs[i]['id'])
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                }),
            TextButton(
              child: const Text('Enter Template'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Home(
                        uid: widget.uid.toString(),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
