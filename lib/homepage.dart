import 'package:database_project/database/local/dbHelper.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> getNotes = [];
  DBhelper? dbref;

  @override
  void initState() {
    // TODO: implement initState
    dbref = DBhelper.getInstance;
    getallNotes();
    super.initState();
  }

  void getallNotes() async {
    getNotes = await dbref!.getAllNote();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AddNote"),
        centerTitle: true,
      ),
      body: getNotes.isNotEmpty
          ? ListView.builder(
              itemCount: getNotes.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                            offset: Offset(2, 4), color: Colors.green.shade50)
                      ]),
                  child: ListTile(
                    leading: Text('${index + 1}'),
                    title: Text(getNotes[index][DBhelper.COLUMN_NOTE_TITLE]),
                    subtitle: Text(getNotes[index][DBhelper.COLUMN_NOTE_DESC]),
                    trailing: Container(
                      width: 50,
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                              child: InkWell(
                                  onTap: () {
                                    titleController.text = getNotes[index]
                                        [DBhelper.COLUMN_NOTE_TITLE];
                                    descController.text = getNotes[index]
                                        [DBhelper.COLUMN_NOTE_DESC];
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return getbottomsheetView(
                                            isUpdate: true,
                                            sno: getNotes[index]
                                                [DBhelper.COLUMN_NOTE_SNO]);
                                      },
                                    );
                                  },
                                  child: Icon(Icons.edit))),
                          Expanded(
                              child: InkWell(
                                  onTap: () async {
                                    bool check = await dbref!.deleteNote(
                                        sno: getNotes[index]
                                            [DBhelper.COLUMN_NOTE_SNO]);
                                    if (check) {
                                      getallNotes();
                                    }
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  )))
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text("No notes yet"),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String errorMsg = "";
          showModalBottomSheet(
            constraints: BoxConstraints(maxWidth: 380),
            context: context,
            builder: (context) {
              return getbottomsheetView();
            },
          );
          // bool check = await dbref!.addNote(
          //     mTitle: "This is first note", mDesc: "this is first Desc");
          // if (check) {
          //   getallNotes();
          // }
        },
        child: Center(child: Text("Add")),
      ),
    );
  }

  Widget getbottomsheetView({bool isUpdate = false, int sno = 0}) {
    return Container(
      width: double.infinity,
      height: 400,
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: Column(
          children: [
            Text(
              isUpdate ? "Update Note" : "Add Note",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 21),
            TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                    hintText: 'Enter title',
                    label: Text('Enter Title'),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11)))),
            SizedBox(height: 21),
            TextFormField(
                controller: descController,
                maxLines: 5,
                decoration: InputDecoration(
                    hintText: 'Enter Desc',
                    label: Text(
                      'Enter Desc',
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(11)))),
            SizedBox(height: 21),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                              side: BorderSide(width: 4, color: Colors.black))),
                      onPressed: () async {
                        var title = titleController.text;
                        var desc = descController.text;
                        if (title.isNotEmpty && desc.isNotEmpty) {
                          bool check = isUpdate
                              ? await dbref!.updateNote(
                                  mtitle: title, mdesc: desc, sno: sno)
                              : await dbref!
                                  .addNote(mTitle: title, mDesc: desc);

                          if (check) {
                            getallNotes();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Please enter data")));
                          }
                          titleController.clear();
                          descController.clear();
                        }

                        Navigator.pop(context);
                      },
                      child: Text(isUpdate ? "Update Note" : "Add note")),
                ),
                SizedBox(
                  width: 11,
                ),
                Expanded(
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                              side: BorderSide(width: 4, color: Colors.black))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
