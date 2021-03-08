import 'dart:async';
import 'dart:convert';
//import 'dart:html';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:barcode_scan_example/utilities/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'model/Sementes.dart';


class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {

  _salvaLoteEnviado() async {

    try{

      String lote = _sementeEncontrada.lote;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("ultimoLoteEnviado", lote);

      setState(() {
        _ultimoLoteEnviado = lote;
      });

    } catch (e){

      print("salvar lote: " + e.toString());

    }

  }

  _recuperarLoteEnviado() async {

    try {

      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _ultimoLoteEnviado = prefs.getString("ultimoLoteEnviado");
      });
      print("Lote recuperado: " + _ultimoLoteEnviado);

    } catch (e){

      print("recuperar lote: " + e.toString());
    }

  }


  limparCampos(){
    scanResult = new ScanResult();
    barcodeInsertResult = new ScanResult();
    _controllerLote.text = null;
    _controllerEtiqueta_A.text = null;
    _sementeEncontrada = null;
  }


  String _ultimoLoteEnviado = "Nenhum lote enviado";

  var telaLargura;
  var telaAltura;
  double defaultFontSize;

  var tempScan;
  var result;

  ScanResult scanResult = new ScanResult();
  ScanResult barcodeInsertResult = new ScanResult();
  String _statusEnvio;

  Sementes _sementeEncontrada;

  TextEditingController _controllerLote = TextEditingController();
  TextEditingController _controllerEtiqueta_A = TextEditingController();

  final _flashOnController = TextEditingController(text: "Flash on");
  final _flashOffController = TextEditingController(text: "Flash off");
  final _cancelController = TextEditingController(text: "Cancel");

  var _aspectTolerance = 0.00;
  var _numberOfCameras = 0;
  var _selectedCamera = -1;
  var _useAutoFocus = true;
  var _autoEnableFlash = false;

  int _indiceAtual = 0;

  static final _possibleFormats = BarcodeFormat.values.toList()
    ..removeWhere((e) => e == BarcodeFormat.unknown);

  // ignore: file_names
  List<BarcodeFormat> selectedFormats = [..._possibleFormats];

  List<Sementes> _sementes = List<Sementes>();

  String _titulo = "SGS - Sementes Petrovina";

  @override
  // ignore: type_annotate_public_apis
  initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      _numberOfCameras = await BarcodeScanner.numberOfCameras;
      print("Largura da tela: " + MediaQuery.of(context).size.width.toString());
      _recuperarLoteEnviado();
    });


  }

  /// FORMATAR DATETIME RECEBIDO
  _formatarData(String data){

    var aaa = DateTime.now().millisecondsSinceEpoch;
    var intData = int.parse(data);

    initializeDateFormatting("pt_BR");

    var formatador = DateFormat("dd/MM/y - HH:mm:ss ");

//    DateTime dataConvertida = DateTime.parse(int.parse(data));
    DateTime dataConvertida = DateTime.fromMicrosecondsSinceEpoch(intData);
    String dataFormatada = formatador.format(dataConvertida);

    return dataFormatada;

  }

  /// ENVIA LOTE E ETIQUETA PARA API
  void _transmiteCodBarras(context) async {


    var corpo = json.encode(_sementeEncontrada.toJson());

    String url = URL_LISTASEMENTES + _sementeEncontrada.id.toString();

    /// Retorna resposta do server, dizendo se funcionou ou não.
    http.Response response = await http.put(
        url,
        headers: {
          "Content-type": "application/json; charset=UTF-8"
        },
        body: corpo
    );

    _statusEnvio = response.statusCode.toString();

  }

  void defineVariaveis(var tempScan, var result){


  }

  _cardCodBarras() {
    if (scanResult != null) {
      return Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
//              ListTile(
//                title: Text("Result Type"),
//                subtitle: Text(scanResult.type?.toString() ?? ""),
//              ),
            ListTile(
              title: Text(
                scanResult.rawContent ?? "Escaneie algum código de barras",
              ),
              //subtitle: Text(scanResult.rawContent ?? ""),
            ),
//              ListTile(
//                title: Text("Format"),
//                subtitle: Text(scanResult.format?.toString() ?? ""),
//              ),
//              ListTile(
//                title: Text("Format note"),
//                subtitle: Text(scanResult.formatNote ?? ""),
//              ),
          ],
        ),
      );
    } else {
      return Text("");
    }
  }

  Future<List<Sementes>> _recuperarSementes() async {

    http.Response response = await http.get(URL_LISTASEMENTES);
    var dadosJson = json.decode(response.body);

    List<Sementes> listaSementes = List();
    for (var semente in dadosJson) {

      Sementes s = Sementes(
        semente["id"],
        semente["produtor"],
        semente["cultivar"],
        semente["lote"],
        semente["peneira"],
        semente["classe"],
        semente["kg_bag"],
        semente["producao_bag"],
        semente["armazem"],
        semente["etiqueta_a"],
        semente["etiqueta_b"],
        semente["etiqueta_c"],
        semente["etiqueta_d"],
        semente["status"],
        semente["observacoes"],
        semente["data"],
        semente["arquivo"],
      );
      listaSementes.add(s);
    }
//    print("Quantidade de itens: " + listaSementes.length.toString());
//    print (response.body.toString());
    _sementes = listaSementes;

//    return listaSementes;
  }

  _cardListaDeSemente()  {

    String codBarras = "";
    String codEtiqueta = "";

    codBarras = scanResult != null ? scanResult.rawContent : _controllerLote.text;

    if (barcodeInsertResult != null){
      codEtiqueta = barcodeInsertResult.rawContent;
      barcodeInsertResult = null;
    } else if (_controllerEtiqueta_A.text != ""){
      codEtiqueta = _controllerEtiqueta_A.text;
    }
//    codEtiqueta = barcodeInsertResult != null ? barcodeInsertResult.rawContent : null;

    _recuperarSementes();

    /// SE TIVER SEMENTE E NOVO CÓDIGO DE BARRAS
    if (codBarras != ""){

      for (var s in _sementes){

        if (s.lote.toString() == codBarras.toString()){
          _sementeEncontrada = s;
          if (codEtiqueta != ""){
            _sementeEncontrada.etiqueta_a = codEtiqueta;

          }

        }
      }
    }
    /// ENCONTROU SEMENTE PARA EXIBIR
    if (_sementeEncontrada != null) {

      _controllerEtiqueta_A.text = _sementeEncontrada.etiqueta_a ?? "Nenuma etiqueta adicionada";

      double espacoLinha = 5;
      double tamH1 = 26;
      double tamH2 = 15;

      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: <Widget>[
              Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Lote: ${_sementeEncontrada.lote}", style: TextStyle(fontSize: tamH1),)),
              Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Produtor: ${_sementeEncontrada.produtor}", style: TextStyle(fontSize: tamH2),)),
              Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Cultivar: ${_sementeEncontrada.cultivar}", style: TextStyle(fontSize: tamH2),)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Peneira: ${_sementeEncontrada.peneira}", style: TextStyle(fontSize: tamH2),)),
                  Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Classe: ${_sementeEncontrada.classe}", style: TextStyle(fontSize: tamH2),)),
                  Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Armazém: ${_sementeEncontrada.armazem}", style: TextStyle(fontSize: tamH2),)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Kg Bag: ${_sementeEncontrada.kg_bag}", style: TextStyle(fontSize: tamH2),)),
                  Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Produção Bag: ${_sementeEncontrada.producao_bag}", style: TextStyle(fontSize: tamH2),)),
                ],
              ),

              Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Observações: ${_sementeEncontrada.observacoes}", style: TextStyle(fontSize: tamH2),)),
//              Text("Data: " + _formatarData(_sementeEncontrada.data.substring(6,19))),

//              Container(padding: EdgeInsets.only(top: espacoLinha), child: Text("Data: " + _formatarData(_sementeEncontrada.data.substring(6,19)), style: TextStyle(fontSize: tamH2),)),


              Container(
                padding: EdgeInsets.only(top: espacoLinha * 2, bottom: espacoLinha * 2),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("ETIQUETA SGS", style: TextStyle(fontSize: tamH2, fontWeight: FontWeight.bold),),
                          Text(_sementeEncontrada.etiqueta_a),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.border_color),
                      color: Colors.black45,
                      onPressed: (){

                        showDialog(
                            context: context,
                            builder: (context){
                              return AlertDialog(
                                title: Text("Digite manualmente uma etiqueta SGS"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    TextField(
                                      controller: _controllerEtiqueta_A,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        labelText: "Etiqueta SGS",
                                        hintText: "Digite manualmente uma etiqueta",
                                      ),
                                    ),
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancelar"),
                                  ),
                                  FlatButton(
                                    onPressed: () {
//                                      setState(() {
//
////                                        for (var s in _sementes){
////                                          if (s.lote.toString() == _sementeEncontrada.lote.toString()){
////                                            s.etiqueta_a = _controllerEtiqueta_A.text;
////                                            _sementeEncontrada.etiqueta_a = _controllerEtiqueta_A.text;
////                                          }
////                                        }
//
//                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text("Salvar"),
                                  ),
                                ],
                              );
                            }
                        );
                      },
                    ),
                  ],
                ),
              ),


              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: FlatButton(
                          color: Colors.green,
                          onPressed: (){
                            scan(1);
                          },
                          child: Row(
                            children: <Widget>[
                              Transform.rotate(
                                angle: pi/2,
                                child: Icon(Icons.format_align_justify, color: Colors.white,),
                              ),
                              Text(" VINCULAR ETIQUETA SGS", style: TextStyle(color: Colors.white),)
                            ],

                          )
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 0),
                      child: FlatButton(
                          color: Colors.green,
                          onPressed: (){

                            String tempLote = _sementeEncontrada.lote;
                            String tempEtiq = _sementeEncontrada.etiqueta_a;

                            try {
                              _transmiteCodBarras(context);
                              _salvaLoteEnviado();

                              showDialog(
                                  context: context,
                                  builder: (context){
                                    return AlertDialog(
                                      title: Text("Etiquetas SGS"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text("Etiqueta ${tempEtiq} vinculada com sucesso ao lote ${tempLote}.")
                                        ],
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: (){
                                            Navigator.pop(context);

                                          },
                                          child: Text("OK"),
                                        ),

                                      ],
                                    );
                                  }
                              );
                              limparCampos();

                            } catch (e) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text("Erro no envio"),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Text(
                                              "Erro: ${e}")
                                        ],
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          },
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.send, color: Colors.white,),
                              Text(" ENVIAR", style: TextStyle(color: Colors.white),)
                            ],

                          )
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlatButton(
              color: Colors.green,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.linked_camera, color: Colors.white,),
                  Text(" Utilizar câmera", style: TextStyle(color: Colors.white),),
                ],

              ),
              onPressed: (){
                scan(0);
              },
            ),
            SizedBox(
              height: 10,
            ),

            Text("Último Lote enviado"),
            Text(_ultimoLoteEnviado ?? "Nenhum lote enviado"),
          ],
        ),

      );
    }
  }

  @override
  Widget build(BuildContext context) {

    telaAltura = MediaQuery.of(context).size.height;
    telaLargura = MediaQuery.of(context).size.width;
    defaultFontSize = telaLargura > 330 ? 14 : 10;

    if (scanResult != null){
      _controllerLote.text = scanResult.rawContent ?? "";
    }

    var contentList = <Widget>[
      if (scanResult != null)
        Card(
          child: Column(
            children: <Widget>[
//              ListTile(
//                title: Text("Result Type"),
//                subtitle: Text(scanResult.type?.toString() ?? ""),
//              ),
              ListTile(
                title: Text(scanResult.rawContent ?? "",),
                //subtitle: Text(scanResult.rawContent ?? ""),
              ),
//              ListTile(
//                title: Text("Format"),
//                subtitle: Text(scanResult.format?.toString() ?? ""),
//              ),
//              ListTile(
//                title: Text("Format note"),
//                subtitle: Text(scanResult.formatNote ?? ""),
//              ),
            ],
          ),
        ),
//      ListTile(
//        title: Text("Selecionae a câmera"),
//        dense: true,
//        enabled: false,
//      ),
//      RadioListTile(
//        onChanged: (v) => setState(() => _selectedCamera = -1),
//        value: -1,
//        title: Text("Default camera"),
//        groupValue: _selectedCamera,
//      ),
    ];

//    for (var i = 0; i < _numberOfCameras; i++) {
//      contentList.add(RadioListTile(
//        onChanged: (v) => setState(() => _selectedCamera = i),
//        value: i,
//        title: Text("Camera ${i + 1}"),
//        groupValue: _selectedCamera,
//      ));
//    }

//    contentList.addAll([
//      ListTile(
//        title: Text("Button Texts"),
//        dense: true,
//        enabled: false,
//      ),
//      ListTile(
//        title: TextField(
//          decoration: InputDecoration(
//            hasFloatingPlaceholder: true,
//            labelText: "Flash On",
//          ),
//          controller: _flashOnController,
//        ),
//      ),
//      ListTile(
//        title: TextField(
//          decoration: InputDecoration(
//            hasFloatingPlaceholder: true,
//            labelText: "Flash Off",
//          ),
//          controller: _flashOffController,
//        ),
//      ),
//      ListTile(
//        title: TextField(
//          decoration: InputDecoration(
//            hasFloatingPlaceholder: true,
//            labelText: "Cancel",
//          ),
//          controller: _cancelController,
//        ),
//      ),
//    ]);

//    if (Platform.isAndroid) {
//      contentList.addAll([
//        ListTile(
//          title: Text("Android Opções específicas"),
//          dense: true,
//          enabled: false,
//        ),
//        ListTile(
//          title:
//          Text("Aspect tolerance (${_aspectTolerance.toStringAsFixed(2)})"),
//          subtitle: Slider(
//            min: -1.0,
//            max: 1.0,
//            value: _aspectTolerance,
//            onChanged: (value) {
//              setState(() {
//                _aspectTolerance = value;
//              });
//            },
//          ),
//        ),
//        CheckboxListTile(
//          title: Text("Usar auto foco"),
//          value: _useAutoFocus,
//          onChanged: (checked) {
//            setState(() {
//              _useAutoFocus = checked;
//            });
//          },
//        )
//      ]);
//    }

//    contentList.addAll([
//      ListTile(
//        title: Text("Other options"),
//        dense: true,
//        enabled: false,
//      ),
//      CheckboxListTile(
//        title: Text("Start with flash"),
//        value: _autoEnableFlash,
//        onChanged: (checked) {
//          setState(() {
//            _autoEnableFlash = checked;
//          });
//        },
//      )
//    ]);

//    contentList.addAll([
//      ListTile(
//        title: Text("Barcode formats"),
//        dense: true,
//        enabled: false,
//      ),
//      ListTile(
//        trailing: Checkbox(
//          tristate: true,
//          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//          value: selectedFormats.length == _possibleFormats.length
//              ? true
//              : selectedFormats.length == 0 ? false : null,
//          onChanged: (checked) {
//            setState(() {
//              selectedFormats = [
//                if (checked ?? false) ..._possibleFormats,
//              ];
//            });
//          },
//        ),
//        dense: true,
//        enabled: false,
//        title: Text("Detect barcode formats"),
//        subtitle: Text(
//          'If all are unselected, all possible platform formats will be used',
//        ),
//      ),
//    ]);

//    contentList.addAll(_possibleFormats.map(
//          (format) => CheckboxListTile(
//        value: selectedFormats.contains(format),
//        onChanged: (i) {
//          setState(() => selectedFormats.contains(format)
//              ? selectedFormats.remove(format)
//              : selectedFormats.add(format));
//        },
//        title: Text(format.toString()),
//      ),
//    ));



    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,

          title: Text("SGS - Sementes Petrovina"),
          actions: <Widget>[

            IconButton(
              icon: Icon(Icons.delete_sweep),
              tooltip: "Atualizar",
              onPressed: (){

                setState(() {
                  limparCampos();
                });

              },
            ),

//            IconButton(
//              icon: Icon(Icons.camera_alt),
//              tooltip: "Scan",
//              onPressed: (){
//
//                scan(0);
//
////                setState(() {
////
////                  try{
////                    _titulo = scanResult.rawContent ?? "SGS - Sementes Petrovinas";
////                  } catch(e){
////                    _titulo = "SGS - Sementes Petrovinas";
////                  }
////
////                });
//
//
//              },
//            )
          ],
        ),
        body: SingleChildScrollView(

          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

//              scanResult != null ? _cardCodBarras() : Text(""),

              Padding(
                padding: const EdgeInsets.all(3),
                child: Card(
                  elevation: 3,
                  child: Row(
                    children: <Widget>[

                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(),
                            controller: _controllerLote,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(12),
                              border: InputBorder.none,
                              hintText: "Escaneie ou digite um código",
                              hintStyle: TextStyle(fontSize: defaultFontSize),
                              labelStyle: TextStyle(color: Colors.black),
                            ),

                          ),
                        ),
                      ),

                      SizedBox(
                        width: 10,
                        height: 10,
                      ),

                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ButtonTheme(
                          minWidth: 56,
                          height: 36,
                          child: FlatButton(

                            color: Colors.green,
                            child: Icon(Icons.check, color: Colors.white,),
                            onPressed: (){
                              FocusScope.of(context).requestFocus(new FocusNode());
                              setState(() {
                                scanResult.rawContent = _controllerLote.text;
                              });
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              _cardListaDeSemente(),

            ],
          ),
        ),

        // Tela de Navegação inferior
        bottomNavigationBar: BottomNavigationBar(
          // type: BottomNavigationBarType.fixed, // até 3. um 4 muda para shiffiting
          // type: BottomNavigationBarType.shifting,
            type: BottomNavigationBarType.fixed,
            currentIndex: _indiceAtual, //item do botão e acompanha a cor
            onTap: (indice){
              setState(() {
                _indiceAtual = indice;

                if(_indiceAtual == 0){
                  Navigator.pop(context);
                }
                else{
                  scan(0);
                }
              });
            },

            fixedColor: Colors.green, // Cor do clicado
            //unselectedItemColor: Colors.grey, // Cor dos botões
            items: [

              BottomNavigationBarItem(
                backgroundColor: Colors.green,
                title: Text("Login"),
                icon: Icon(Icons.person_outline),
              ),

              BottomNavigationBarItem(
                backgroundColor: Colors.green,
                title: Text("Nova Consulta"),
                icon: Icon(Icons.camera_alt),
              ),

//              BottomNavigationBarItem(
//                backgroundColor: Colors.lightBlue,
//                title: Text("Inscrições"),
//                icon: Icon(Icons.subscriptions),
//              ),
//
//              BottomNavigationBarItem(
//                title: Text("Biblioteca"),
//                icon: Icon(Icons.folder),
//              ),

            ]
        ),
      ),
    );
  }

  Future scan(int insertScan) async {

    tempScan = insertScan;

    try {
      var options = ScanOptions(
        strings: {
          "cancel": _cancelController.text,
          "flash_on": _flashOnController.text,
          "flash_off": _flashOffController.text,
        },
        restrictFormat: selectedFormats,
        useCamera: _selectedCamera,
        autoEnableFlash: _autoEnableFlash,
        android: AndroidOptions(
          aspectTolerance: _aspectTolerance,
          useAutoFocus: _useAutoFocus,
        ),
      );

      result = await BarcodeScanner.scan(options: options);

//      setState(() {
//        scanResult = result;
//      });

      setState(() {
        if (tempScan == 1){
          barcodeInsertResult = result;
        } else {
          scanResult = result;
        }
      });

//      setState(() => scanResult = result);
      int i = 1;
    } on PlatformException catch (e) {
      var result = ScanResult(
        type: ResultType.Error,
        format: BarcodeFormat.unknown,
      );

      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result.rawContent = 'The user did not grant the camera permission!';
        });
      } else {
        result.rawContent = 'Unknown error: $e';
      }

      setState(() {

        if (tempScan == 1){
          barcodeInsertResult = result;
        } else {
          scanResult = result;
        }

        try{
          _titulo = result.rawContent;
        } catch(e){
          _titulo = "SGS - Sementes Petrovinas";
        }

      });

    }

  }
}
