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
  void initState() { // Método chamado ao iniciar o app
    super.initState();

    /* Contact c = Contact();
    c.name = "Nathan";
    c.phone = "1516848574";
    c.email = "Nathan@gmail.com";*/

    getAllContacts(); // Lista todos os contatos
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
          PopupMenuButton<OrderOptions>( // Cria botão para abrir uma pequena janela com as opções abaixo. Entre <> será o valor que irá ser repassado no onSelected
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz, // Atribui a ordenação de A-Z
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z-A"),
                value: OrderOptions.orderza, // Atribui a ordenção de Z-A
              ),
            ],
            onSelected: orderList, // Chama a função para ordenação da lista, passando como parâmetro o tipo de ordenação selecionado nas opções acima
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton( // Botão flutuante posicionado no rodapé
        onPressed: () {
          showContactPage(); // Ao ser clicado, será mostrado a página de cadastro de contatos
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder( // Cria uma listView
          padding: const EdgeInsets.all(10),
          itemCount: contact.length, // Atribui a quantidade de contatos ao tamanho da listView
          itemBuilder: (context, index) {
            return contactCard(context, index); // Chama o widget que criará os cards dos contatos
          }),
    );
  }

  void orderList(OrderOptions result) { // Função para ordenação da lista de contatos
    switch (result) {
      case OrderOptions.orderaz:
        contact.sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase()); // Algoritmo para ordenar a lista de A-Z
        });
        break;
      case OrderOptions.orderza:
        contact.sort((a, b) {
          return b.name!.toLowerCase().compareTo(a.name!.toLowerCase()); // Algoritmo para ordenar a lista de Z-A
        });
        break;
    }
    setState(() {});
  }

  showContactPage({Contact? contact}) async { // Função que irá chamar a tela de cadastro de contatos
    final recContact = await Navigator.push( // Função que aguardará o cadastro do contato, e ao fechar, será repassado os dados do contato criado como retorno e atribuídos ao 'recContact'
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )
        )
    );
    if (recContact != null) { // Caso retorne um contato não vazio, executará as funções de atualizar ou salvar
      if (contact != null) { // Caso tenha sido passado um contato como parâmetro na chamada da função, então significa que deverá atualizar o cadastro do contato passado
        await helper.updateContact(recContact);
      } else { // Caso não tenha passado o contato como parâmetro, então será criado um novo contato no banco utilizando a função de salvar contatos da classe helper
        await helper.saveContact(recContact);
      }
      getAllContacts(); // Atualiza a lista de contatos
    }
  }

  Widget contactCard(BuildContext context, int index) { // Função de criação dos cards de contato
    return GestureDetector(
      onTap: () { // Função chamada ao clicar sob um card de contato
        showOptions(context, index); // Chama a função que irá exibir opções para o contato selecionado
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
                  shape: BoxShape.circle, // Deixa a imagem circular
                  image: DecorationImage(
                      image: contact[index].img != null // Caso o contato já tenha uma imagem vinculada, essa será mostrada pelo 'FileImage',
                          ? FileImage(File(contact[index].img!))
                          : const AssetImage("images/person.png") // caso contrário será mostrado a imagem padrão que inserimos no assets do pubspec
                              as ImageProvider),
                ),
              ),
              Padding( // Cria as linhas de dados do contato dentro do card
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact[index].name ?? "", // Caso o valor seja nulo, será mostrado uma string vazia
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contact[index].email ?? "", // Caso o valor seja nulo, será mostrado uma string vazia
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      contact[index].phone ?? "", // Caso o valor seja nulo, será mostrado uma string vazia
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

  void showOptions(BuildContext context, int index) { // Função para exibir as opções ao clicar sob o contato
    showModalBottomSheet( // Exibe uma caixa na parte inferir da tela, com as opções
        context: context,
        builder: (context) {
          return BottomSheet( // Dados retornados para a exibição do ModalBottomSheet
            onClosing: () {}, // Função obrigatória para o BottomSheet
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Faz com que ocupe o menor tamanho vertical (visto que é uma coluna) possível
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: TextButton(
                        onPressed: () {
                          launch("tel: ${contact[index].phone!}"); // Direciona para a tela de ligação, já passando o número do contato cadastrado
                          Navigator.pop(context); // Fecha o ModalBottomSheet
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
                          Navigator.pop(context); // Fecha o ModalBottomSheet
                          showContactPage(contact: contact[index]); // Chama a página de cadastro de contatos, passando como parâmetro o contato selecionado
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
                          helper.deleteContact(contact[index].id!); // Chama a função para exclusão do contato
                          setState(() {
                            Contact deletedContact = contact[index]; // Variável utilizada para armazenar o contato deletado, utilizado na snackbar como 'rollback' da exclusão
                            int deletedIndex = contact.indexOf(contact[index]); // Variável utilizada para armazenar a posição do item deletado, utilizado na snackbar como 'rollback'
                            contact.removeAt(index); // Remove o contato da lista de contatos
                            Navigator.pop(context); // Fecha o ModalBottomSheet

                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar( // Exibe uma snackbar, que terá a opção para 'desfazer' a ação, re-inserindo o contato novamente
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
                                      helper.saveContact(deletedContact); // Salva novamente o contato deletado
                                      contact.insert(deletedIndex, deletedContact); // Insere novamente na lista de contatos o contato excluído
                                    });
                                    //getAllContacts();
                                  },
                                ),
                                duration: const Duration(seconds: 3), // Duração de exibição da snackbar
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

  void getAllContacts() { // Função que atualiza a lista de contatos buscando os contatos salvos no banco de dados
    helper.getAllContacts().then((list) {
      setState(() {
        contact = list;
      });
    });
  }
}
