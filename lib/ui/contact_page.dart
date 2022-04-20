import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:io';

import '../helpers/contact_helper.dart';

class ContactPage extends StatefulWidget {

  final Contact? contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  Contact? editContact;
  bool userEdited = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editContact?.name ?? "Novo Contato"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.save),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            GestureDetector(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: editContact!.img != null ? FileImage(File(editContact!.img!)) : const AssetImage("images/person.png") as ImageProvider
                  ),
                ),
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Nome",),
              onChanged: (text){
                userEdited = true;
                setState(() {
                  editContact!.name = text;
                });
              },
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: "Email",),
              onChanged: (text){
                userEdited = true;
                editContact!.email = text;
              },
            ),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Phone",),
              onChanged: (text){
                userEdited = true;
                editContact!.phone = text;
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if(widget.contact == null){
      editContact = Contact();
    } else{
      editContact = Contact.fromMap(widget.contact!.toMap());

      nameController.text = editContact!.name.toString();
      emailController.text = editContact!.email.toString();
      phoneController.text = editContact!.phone.toString();
    }
  }
}
