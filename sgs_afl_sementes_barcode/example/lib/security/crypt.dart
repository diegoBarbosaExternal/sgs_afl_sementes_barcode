import 'dart:async';
import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as Encrypt;

class Login {
  final CHAVE = '4Rtv9UH56xWtAyNcS5Yr3jrPmWs26Wa6';
  final LENGHT_VETOR = 16;
  StreamSubscription usuario;

  String encrypt(senha) {
    final encrypter = Encrypter(AES(Encrypt.Key.fromUtf8(CHAVE)));
    final senhaEncrypted =
    encrypter.encrypt(senha, iv: IV.fromLength(LENGHT_VETOR));
    return senhaEncrypted.base64;
  }

  String decrypt(senhaEncrypted) {
    final encrypter = Encrypter(AES(Encrypt.Key.fromUtf8(CHAVE)));
    final decrypted =
    encrypter.decrypt64(senhaEncrypted, iv: IV.fromLength(LENGHT_VETOR));
    return decrypted;
  }
}