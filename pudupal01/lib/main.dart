import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Pagina {
  final String name;
  final String url;

  const Pagina(this.name, this.url);
}
//Lista de Páginas Web para trámites

List<Pagina> _paginas = [
  const Pagina("Pase Movilidad", "https://mevacuno.gob.cl/"),
  const Pagina("Certificados Registro Civil",
      "https://www.registrocivil.cl/principal/servicios-en-linea"),
  const Pagina("AFP Provida", "https://www.provida.cl/"),
  const Pagina("AFP Capital", "https://home.afpcapital.cl/"),
  const Pagina("AFP Habitat", "https://www.afphabitat.cl/"),
  const Pagina("AFP Modelo", "https://nueva.afpmodelo.cl/afiliados"),
  const Pagina("AFP Plan Vital", "https://www.planvital.cl/afiliado/inicio"),
];

void main() => runApp(MyApp());

//Muestra en pantalla la lista de páginas web
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const title = 'Trámites Web';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: ListView.builder(
          itemCount: _paginas.length,
          itemBuilder: (context, index) {
            return ListTile(
                title: Text(_paginas[index].name),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailScreen(pagina: _paginas[index]),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}

//DetailScreen muestra la WebView al hacer click en un elemento de la lista
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.pagina});

  final Pagina pagina;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pagina.name),
      ),
      body: WebView(
        initialUrl: pagina.url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
