import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Contact editContact;
  bool userEdited = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final nameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(editContact.name ?? "Novo Contato"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (editContact.name?.isEmpty != true && editContact.name != null) {
              Navigator.pop(context, editContact);
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Insira um nome para o contato.", style: TextStyle(color: Colors.white, fontSize: 17),),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                )
              );
              FocusScope.of(context).requestFocus(nameFocus);
            }
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async{
                  ImagePicker().pickImage(source: ImageSource.camera).then((file){
                    if(file == null) return;
                    setState(() {
                      editContact.img = file.path;
                    });
                  });
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: editContact.img != null
                            ? FileImage(File(editContact.img!))
                            : const AssetImage("images/person.png")
                                as ImageProvider),
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                focusNode: nameFocus,
                decoration: const InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text) {
                  userEdited = true;
                  setState(() {
                    editContact.name = text;
                  });
                },
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                ),
                onChanged: (text) {
                  userEdited = true;
                  editContact.email = text;
                },
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                onChanged: (text) {
                  userEdited = true;
                  editContact.phone = text;
                },
              )
            ],
          ),
        ),
      ),
      onWillPop: requestPop,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      editContact = Contact();
    } else {
      editContact = Contact.fromMap(widget.contact!.toMap());

      nameController.text = editContact.name.toString();
      emailController.text = editContact.email.toString();
      phoneController.text = editContact.phone.toString();
    }
  }

  Future<bool> requestPop() {
    if (userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Descartar Alterações?"),
              content: const Text("Se sair, as alterações serão perdidas."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text("Sim"),
                )
              ],
            );
          });
      return Future.value(false); // Sai automaticamente da tela
    } else {
      return Future.value(true); // Não sai automaticamente da tela
    }
  }
}
