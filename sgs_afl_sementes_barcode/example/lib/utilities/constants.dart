library Constants;
import 'package:flutter/material.dart';

//const String URL_LISTASEMENTES = "http://jsonplaceholder.typicode.com/posts";
const String URL_LISTASEMENTES = "https://online.br.sgs.com/sementesapi/api/tb_petrovinas_arquivo/";

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: Colors.green,//Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);