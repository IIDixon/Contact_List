import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_page.dart';

enum OrderOptions { orderaz, orderza }

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

    getAllContacts();
    orderList(OrderOptions.orderaz);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showContactPage();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: contact.length,
          itemBuilder: (context, index) {
            return contactCard(context, index);
          }),
    );
  }

  void orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contact.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contact.sort((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());
        });
        break;
    }
    setState(() {});
  }

  showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )
        )
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      getAllContacts();
    }
  }

  Widget contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        showOptions(context, index);
      },
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
                      image: contact[index].img != null
                          ? FileImage(File(contact[index].img!))
                          : const AssetImage("images/person.png")
                              as ImageProvider),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact[index].name ?? "",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contact[index].email ?? "",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      contact[index].phone ?? "",
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

  void showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: TextButton(
                        onPressed: () {
                          launch("tel: ${contact[index].phone!}");
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.phone, color: Colors.green,),
                            ),
                            Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20),)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showContactPage(contact: contact[index]);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.edit, color: Colors.blue,),
                            ),
                            Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20),)
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: TextButton(
                        onPressed: () {
                          helper.deleteContact(contact[index].id!);
                          setState(() {
                            Contact deletedContact = contact[index];
                            int deletedIndex = contact.indexOf(contact[index]);
                            contact.removeAt(index);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("O contato de ${deletedContact.name} foi removido com sucesso",
                                    style: const TextStyle(fontSize: 17, color: Colors.white),
                                  ),
                                backgroundColor: Colors.red,
                                action: SnackBarAction(
                                  label: "Desfazer",
                                  textColor: Colors.blue,
                                  onPressed: (){
                                    setState(() {
                                      helper.saveContact(deletedContact);
                                      contact.insert(deletedIndex, deletedContact);
                                    });
                                    //getAllContacts();
                                  },
                                ),
                                duration: const Duration(seconds: 3),
                              )
                            );
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.delete, color: Colors.red,),
                            ),
                            Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20),)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contact = list;
      });
    });
  }
}
