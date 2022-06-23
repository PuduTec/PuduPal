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
  var loadingPercentage = 0;
  final js = '''
ViewEnum =  {
    InicioSesion: "Inicio de sesión",
    InicioSesionCarnet: "Inicio de sesión con carnet",
    InicioSesionClaveUnica: "Inicio de sesión con Clave Única",
    InicioSesionCorreo: "Inicio de sesión con correo",
    Dashboard: "Descarga de pase movilidad",
    NoSePuedeDeterminar: "No se pude determinar la vista :("
}

function currentView() {
    let url = window.location.host
    if (url === "mevacuno.gob.cl") {
        let loggedIn = document.getElementById("my-login-screen").style.display === "none"
        if (!loggedIn) {
            let popup_carnet = document.getElementsByClassName("popup-backdrop")[0]
            if (popup_carnet.classList.contains("backdrop-in")) {
                return ViewEnum.InicioSesionCarnet
            }
            else {
                let active_tab = document.getElementsByClassName("toolbar-inner")[0].children[0]
                if (active_tab.classList.contains("tab-link-active")) {
                    return ViewEnum.InicioSesion
                }
                else {
                    return ViewEnum.InicioSesionCorreo
                }
            }
        }
        else {
            return ViewEnum.Dashboard
        }
    }
    else if (url === "accounts.claveunica.gob.cl") {
        return ViewEnum.InicioSesionClaveUnica
    }
    else {
        return ViewEnum.NoSePuedeDeterminar
    }
}

function getElementWithInnerHtml(list, inner) {
    for (let elem of list) {
        if (elem.innerHTML == inner) return elem
    }
    return undefined
}

function highlightElements(currentView) {
    if (currentView === ViewEnum.InicioSesion) {
        let claveUnica = document.getElementsByClassName("backbluex")[0]
        claveUnica.style.outline = "3px solid red"
        claveUnica.style.outlineOffset = "3px"

        let carnet = getElementWithInnerHtml(document.getElementsByTagName("a"), "N° Serie Cédula Chilena")
        carnet.style.outline = "3px solid red"
        carnet.style.outlineOffset = "3px"

        // let correo = getElementWithInnerHtml(document.getElementsByTagName("a"), "Correo electrónico")
        // correo.style.borderBottom = "3px solid red"

        // let claveUnicaTab = getElementWithInnerHtml(document.getElementsByTagName("a"), "Clave Única y/o C.I Chilena")
        // claveUnicaTab.style.borderBottom = ""
    }
    else if (currentView === ViewEnum.InicioSesionCarnet) {
        let acceder = getElementWithInnerHtml(document.getElementsByTagName("a"), "Acceder")
        acceder.style.outline = "3px solid red"
        acceder.style.outlineOffset = "3px"
        
        let input = document.getElementsByTagName("ul")[5]
        input.style.outline = "3px solid red"
        input.style.outlineOffset = "-3px"

        let cerrar = document.getElementsByClassName("popup-close")[3]
        console.dir(cerrar)
        cerrar.style.borderBottom = "3px solid red"
    }
    else if (currentView === ViewEnum.InicioSesionCorreo) {
        // let correo = getElementWithInnerHtml(document.getElementsByTagName("a"), "Correo electrónico")
        // correo.style.borderBottom = ""

        // let claveUnica = getElementWithInnerHtml(document.getElementsByTagName("a"), "Clave Única y/o C.I Chilena")
        // claveUnica.style.borderBottom = "3px solid red"
        
        let acceder = getElementWithInnerHtml(document.getElementsByTagName("span"), "Acceder").parentElement
        acceder.style.outline = "3px solid red"
        acceder.style.outlineOffset = "3px"
        
        let input = document.getElementsByTagName("ul")[2]
        input.style.outline = "3px solid red"
        input.style.outlineOffset = "-5px"
    }
    else if (currentView === ViewEnum.InicioSesionClaveUnica) {
        let rutField = document.getElementsByClassName("rut")[0]
        rutField.style.outline = "3px solid red"
        rutField.style.outlineOffset = "3px"

        let passwordField = document.getElementById("pword")
        passwordField.style.outline = "3px solid red"
        passwordField.style.outlineOffset = "3px"

        let continuar = document.getElementsByClassName("gob-btn-primary")[0]
        continuar.style.outline = "3px solid red"
        continuar.style.outlineOffset = "3px"
    }
    else if (currentView == ViewEnum.Dashboard) {
        let descargar = document.getElementsByClassName("color-red")[0]
        descargar.style.outline = "3px solid red"
        descargar.style.outlineOffset = "3px"

        descargar.scrollIntoView({behavior: "smooth"})
    }
}

setInterval(() => {
  let view = currentView()
  highlightElements(view)
  CurrentViewChannel.postMessage(view)
}, 600)
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
            body: Stack(
              children: [
                Expanded(
                  child: WebView(
                    initialUrl: widget.pagina.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: _createJavascriptChannels(context),
                    onWebViewCreated: (webViewController) {
                      controller.complete(webViewController);
                    },
                    onPageStarted: (url) {
                      setState(() {
                        loadingPercentage = 0;
                      });
                    },
                    onProgress: (progress) {
                      setState(() {
                        loadingPercentage = progress;
                      });
                    },
                    onPageFinished: (url) async {
                      loadingPercentage = 100;
                      await futureController.data!.runJavascript(js);
                    },
                  ),
                ),
                if (loadingPercentage < 100)
                  LinearProgressIndicator(
                    value: loadingPercentage / 100.0,
                  ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          offset: const Offset(0.0, -0.5),
                          color: Colors.black.withAlpha(30),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Text(
                      instruction,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
