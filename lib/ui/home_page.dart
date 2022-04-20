import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contact = [];

  @override
  void initState() {
    super.initState();

   /* Contact c = Contact();
    c.name = "Nathan";
    c.phone = "1516848574";
    c.email = "Nathan@gmail.com";*/

    helper.getAllContacts().then((list){
      setState(() {
        contact = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child:const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: contact.length,
          itemBuilder: (context,index){
            return contactCard(context, index);
          }
      ),
    );
  }

  showContactPage(){

  }

  Widget contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contact[index].img != null ? FileImage(File(contact[index].img!)) : const AssetImage("images/person.png") as ImageProvider
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact[index].name ?? "",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(contact[index].email ?? "",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(contact[index].phone ?? "",
                        style: const TextStyle(fontSize: 18),
                      )
                    ],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
