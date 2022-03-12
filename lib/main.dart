import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'controller/theme_control.dart';

var request = Uri.parse(
    'https://api.hgbrasil.com/finance?format=json-cors&key=ac5f2c5e'); //API

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        ),

        //primarySwatch: Colors.purple,
        brightness: ThemeController.instance.isDartTheme
            ? Brightness.dark
            : Brightness.light,
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
}

Future<Map> getData() async {
  // retorna um map do futuro
  http.Response response = await http.get(request); // puxa os dados da api
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();

  final dolarController = TextEditingController();

  final euroController = TextEditingController();

  double dolar = 0;
  double euro = 0;

  void _limpaCamp() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _limpaCamp();
      return;
    }
    double real = double.parse(text);
    dolarController.text =
        (real / dolar).toStringAsFixed(2); //mostrando apenas 2 casas decimais
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _limpaCamp();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(
        2); //convertendo primeiro para reais e depois para euro
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _limpaCamp();
      return;
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('\$ Conversor de Moedas \$'),
        centerTitle: true,
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              // se não estiver conectado
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text('Carregando dados',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25,
                      ),
                      textAlign: TextAlign.center),
                );
              default: // se tiver erro
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar dados',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 25,
                        ),
                        textAlign: TextAlign.center),
                  );
                } else {
                  // se não tiver erro
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  //percorre array da API em busca dos resultados

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .stretch, // alarga pra ocupar o máximo espaço possível
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextField(
                            "Real", "R\$ ", realController, _realChanged),
                        Divider(),
                        buildTextField(
                            "Dólar", "US\$ ", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euro", "€ ", euroController, _euroChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

// class CustomSwitch extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Switch(
//       value: ThemeController.instance.isDartTheme,
//       onChanged: (value) {
//         ThemeController.instance.changeTheme();
//       },
//     );
//   }
// }

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function funcao) {
  return TextField(
    controller: controller,
    //label
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(), // desenha borda do label
        prefixText: prefix), //fixa um texto no label
    style: TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    onChanged: (texto) {
      funcao(texto);
    },
    keyboardType: TextInputType.number, //apenas teclado numérico
  );
}
