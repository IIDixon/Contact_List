import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Colunas da tabela do banco de dados
const String contactTable = "contactTable";
const String idColumn = "idColumn";
const String nameColumn = "nameColumn";
const String emailColumn = "emailColumn";
const String phoneColumn = "phoneColumn";
const String imgColumn = "imgColumn";


class ContactHelper{ // Classe que faz toda a comunicação com o banco de dados

  // Faz com que a instância dessa classe seja única
  ContactHelper.internal();

  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;
  //

  Database? _db;

  Future<Database> get db async{ // Pega as informações do banco de dados
    if(_db != null){ // Caso o banco já exista, retorna as informações do mesmo
      return _db!;
    }else{ // Caso não exista, faz a criação e retorna as informações do mesmo
      _db = await initDb();
      return _db!;
    }
  }

  Future<Database> initDb() async{ // Função para criação do banco de dados
    final databasesPath = await getDatabasesPath(); // Inicia a criação do banco de dados
    final path = join(databasesPath, "Contacts.db"); // Cria o banco de dados com o nome "Contacts.db"

    return openDatabase(path,version: 1, onCreate: (Database db, int newerVersion) async{
      await db.execute( // Executa a criação da tabela no banco de dados
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact?> saveContact(Contact contact) async{ // Função para salvar um novo contato
    Database dbContact = await db; // Pega as informações do banco de dados
    contact.id = await dbContact.insert(contactTable, contact.toMap()); // Grava o registro no banco de dados, em formato 'Map'
    return contact;
  }

  Future<Contact?> getContact(int id) async{ // Função para buscar um determinado contato no banco de dados
    Database dbContact = await db; // Pega as informações do banco de dados
    List<Map> maps = await dbContact.query(contactTable, // Busca na tabela contactTable
        columns: [idColumn, nameColumn, phoneColumn, imgColumn], // As colunas determinadas
        where: "$idColumn = ?", // onde o 'idColumn'
        whereArgs: [id] // seja igual ao 'id' passado como parâmetro
    );
    if(maps.isNotEmpty){ // Caso haja resultados, retorna o primeiro contato
      return Contact.fromMap(maps.first);
    } else{ // Caso contrário, retorna um vazio
      return null;
    }
  }

  Future<int> deleteContact(int id) async{ // Função para excluir um contato
    Database dbContact = await db; // Pega as informações do banco de dados
    return await dbContact.delete(contactTable, // Deleta da tabela 'contactTable'
        where: "$idColumn = ?", // onde o 'idColumn'
        whereArgs: [id] // for igual ao 'id' passado como parâmetro
    );
  }

  Future<int> updateContact(Contact contact) async{ // Função para atualização das informações do contato
    Database dbContact = await db; // Pega as informações do banco de dados
    return await dbContact.update(contactTable, // Atualiza os registro da tabela 'contactTable'
        contact.toMap(), // Passa as informações a serem atualizadas
        where: "$idColumn = ?", // onde o 'idColumn'
        whereArgs: [contact.id] // for igual ao 'id' do contato passado como parâmetro
    );
  }

  Future<List<Contact>> getAllContacts() async{ // Função para listar todos os contatos
    Database dbContact = await db; // Pega as informações do banco de dados
    List<Map> listmap = await dbContact.rawQuery("SELECT * FROM $contactTable"); // Seleciona todos os registros da tabela 'contactTable' e atribui a uma List do tipo 'Map'
    List<Contact> listContact = []; // Cria uma lista vazia do tipo 'Contact'

    for(Map m in listmap){ // Para cada registro retornado na query anterior
      listContact.add(Contact.fromMap(m)); // Adiciona na listContact
    }
    return listContact; // Retorna a lista com os contatos
  }

  Future<int> deleteAllContacts() async{ // Função para excluir todos os contatos
    Database dbContact = await db; // Pega as informações do banco de dados
    return await dbContact.delete(contactTable); // Executa a exclusão dos registros da tabela e retorna um inteiro
  }

  Future<int?> getNumber() async{ // Função para verificar a quantidade de registros na tabela 'contactTable'
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async{ // Função para fechar a conexão com o banco de dados
    Database dbContact = await db; // Pega as informações do banco de dados
    dbContact.close(); // Fecha a conexão
  }

}

class Contact{

  Contact({this.id,this.name = "", this.email = "", this.phone = ""});

  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  // Construtor a partir de um MAP lido
  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  // Exportação para um MAP para armazenamento
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  // Define o retorno do método toString
  @override
  String toString() {
    return "Contact(id: $id, name: $name, email:$email, phone: $phone, img: $img)";
  }
}