import 'dart:ffi';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

class _SodiumMacos implements Sodium {
  final Sodium _sodium;

  _SodiumMacos(this._sodium);

  @override
  Crypto get crypto => _sodium.crypto;

  @override
  Uint8List pad(Uint8List buf, int blocksize) => _sodium.pad(buf, blocksize);

  @override
  Randombytes get randombytes => _sodium.randombytes;

  @override
  SecureKey secureAlloc(int length) => _sodium.secureAlloc(length);

  @override
  SecureKey secureCopy(Uint8List data) => _sodium.secureCopy(data);

  @override
  SecureKey secureRandom(int length) => _sodium.secureRandom(length);

  @override
  SecureKey secureHandle(dynamic nativeHandle) =>
      _sodium.secureHandle(nativeHandle);

  @override
  Uint8List unpad(Uint8List buf, int blocksize) =>
      _sodium.unpad(buf, blocksize);

  @override
  SodiumVersion get version => const SodiumVersion(10, 3, '1.0.18');
}

class SodiumMacos extends SodiumPlatform {
  static void registerWith() {
    SodiumPlatform.instance = SodiumMacos();
  }

  @override
  Future<Sodium> loadSodium({bool initNative = true}) => SodiumInit.init(
        DynamicLibrary.process(),
      ).then((sodium) => _SodiumMacos(sodium));
}
