import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  ContactPage({this.contact}); // Construtor que recebe um Contato como parâmetro opcional

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late Contact editContact;
  bool userEdited = false; // Variável utilizada para indicar se o usuário foi ou não editado
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final nameFocus = FocusNode(); // Variável de foco, utilizada para focar no textfield 'name', caso tente gravar com o campo vazio

  @override
  Widget build(BuildContext context) {
    return WillPopScope( // Widget que permite executar alguma função quando o for clicado no botão para voltar
      child: Scaffold(
        appBar: AppBar(
          title: Text(editContact.name ?? "Novo Contato"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (editContact.name?.isEmpty != true && editContact.name != null) { // Caso o nome do usuário esteja preenchido
              Navigator.pop(context, editContact); // Fecha a página, e passa como retorno os dados inseridos
            } else {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar( // Caso o nome não esteja preenchido, exibe uma snackbar
                const SnackBar(
                  content: Text("Insira um nome para o contato.", style: TextStyle(color: Colors.white, fontSize: 17),),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                )
              );
              FocusScope.of(context).requestFocus(nameFocus); // Caso o nome não esteja preenchido, ao clicar no botão para salvar, direciona o foco automático para o campo 'name'
            }
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView( // Utilizado para não extourar os limites da tela quando o teclado for exibido
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async{
                  ImagePicker().pickImage(source: ImageSource.camera).then((file){ // Ao clicar no botão da imagem, é direcionado para a câmera do dispositivo
                    if(file == null) return;
                    setState(() {
                      editContact.img = file.path; // Aloca a foto ao contato
                    });
                  });
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: editContact.img != null // Caso o contato ainda não tenha uma image, será exibida a imagem padrão que adicionados ao assets
                            ? FileImage(File(editContact.img!))
                            : const AssetImage("images/person.png")
                                as ImageProvider),
                  ),
                ),
              ),
              TextField(
                controller: nameController,
                focusNode: nameFocus, // Define o foco, que será chamado caso o campo esteja vazio ao tentar salvar
                decoration: const InputDecoration(
                  labelText: "Nome",
                ),
                onChanged: (text) { // Adiciona o valor do campo ao contato
                  userEdited = true; // Indica que o usuário foi editado
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
                onChanged: (text) { // Adiciona o valor do campo ao contato
                  userEdited = true; // Indica que o usuário foi editado
                  editContact.email = text;
                },
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Phone",
                ),
                onChanged: (text) { // Adiciona o valor do campo ao contato
                  userEdited = true; // Indica que o usuário foi editado
                  editContact.phone = text;
                },
              )
            ],
          ),
        ),
      ),
      onWillPop: requestPop, // Quando for clicado no botão para voltar, será chamada a função 'requestPop'
    );
  }

  @override
  void initState() { // Função chamado ao inicializar a página
    super.initState();

    if (widget.contact == null) { // Caso na construção da página não tenha sido passado nenhum parâmetro, cria um 'Contact' novo
      editContact = Contact();
    } else { // Caso na construção da página tenha sido passado o parâmetro de Contato, aloca as informações do mesmo a instância 'editContact'
      editContact = Contact.fromMap(widget.contact!.toMap());

      nameController.text = editContact.name.toString(); // Aloca as informações do contato ao textfield
      emailController.text = editContact.email.toString(); // Aloca as informações do contato ao textfield
      phoneController.text = editContact.phone.toString(); // Aloca as informações do contato ao textfield
    }
  }

  Future<bool> requestPop() { // Função chamada ao clicar no botão de voltar
    if (userEdited) { // Caso tenha sido editado algum campo, exibirá uma caixa de diálogo
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog( // Exibe a caixa de diálogo
              title: const Text("Descartar Alterações?"), // Título da caixa de diálogo
              content: const Text("Se sair, as alterações serão perdidas."), // Conteúdo exibido na caixa de diálogo
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Caso seja clicado no botão 'cancelar', apenas fecha a caixa de diálogo
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () { // Caso seja clicar no botão 'sim', fecha a caixa de diálogo e a página de cadastro de contatos
                    Navigator.pop(context); // Fecha a caixa de diálogo
                    Navigator.pop(context); // Fecha a página de cadastro de contatos
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
