import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';

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

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.pagina});

  final Pagina pagina;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

//DetailScreen muestra la WebView al hacer click en un elemento de la lista
class _DetailScreenState extends State<DetailScreen> {
  String instruction = "";
  final controller = Completer<WebViewController>();
  final js = '''
function currentView() {
    let url = window.location.host
    if (url === "mevacuno.gob.cl") {
        let popup_carnet = document.getElementsByClassName("popup-backdrop")[0]
        if (popup_carnet.classList.contains("backdrop-in")) {
            return "Inicio de Sesión Carnet"
        }
        else {
            return "Hub Inicio de Sesión"
        }
    }
    else if (url === "accounts.claveunica.gob.cl") {
        return "Inicio de Sesión Clave Única"
    }
    else {
        return "No se pude determinar la vista :("
    }
}

window.addEventListener("touchstart", (e) => {
    setTimeout(() => {
        CurrentViewChannel.postMessage(currentView())
    }, 400)
})

CurrentViewChannel.postMessage(currentView())
''';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        future: controller.future,
        builder: (context, futureController) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.pagina.name),
            ),
            body: Column(
              children: [
                Expanded(
                  child: WebView(
                    initialUrl: widget.pagina.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (webViewController) {
                      controller.complete(webViewController);
                    },
                    onPageFinished: (url) async {
                      await futureController.data!.runJavascript(js);
                    },
                    javascriptChannels: _createJavascriptChannels(context),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          offset: const Offset(0.0, -0.5),
                          color: Colors.black.withAlpha(30),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Text(instruction),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Set<JavascriptChannel> _createJavascriptChannels(BuildContext context) {
    return {
      JavascriptChannel(
        name: 'CurrentViewChannel',
        onMessageReceived: (message) {
          setState(() {
            instruction = message.message;
          });
        },
      ),
    };
  }
}
