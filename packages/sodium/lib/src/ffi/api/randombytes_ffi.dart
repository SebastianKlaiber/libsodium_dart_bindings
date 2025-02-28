import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/helpers/validations.dart';
import '../../api/randombytes.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/size_t_extension.dart';
import '../bindings/sodium_pointer.dart';

@internal
class RandombytesFFI implements Randombytes {
  final LibSodiumFFI sodium;

  RandombytesFFI(this.sodium);

  @override
  int get seedBytes => sodium.randombytes_seedbytes().toSizeT();

  @override
  int random() => sodium.randombytes_random();

  @override
  int uniform(int upperBound) => sodium.randombytes_uniform(upperBound);

  @override
  Uint8List buf(int size) {
    final ptr = SodiumPointer<Uint8>.alloc(sodium, count: size);
    try {
      sodium.randombytes_buf(ptr.ptr.cast(), ptr.byteLength.toIntPtr());
      return ptr.copyAsList();
    } finally {
      ptr.dispose();
    }
  }

  @override
  Uint8List bufDeterministic(int size, Uint8List seed) {
    Validations.checkIsSame(seed.length, seedBytes, 'seed');

    SodiumPointer<Uint8>? seedPtr;
    SodiumPointer<Uint8>? resultPtr;
    try {
      seedPtr = seed.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      resultPtr = SodiumPointer.alloc(sodium, count: size);
      sodium.randombytes_buf_deterministic(
        resultPtr.ptr.cast(),
        resultPtr.byteLength.toIntPtr(),
        seedPtr.ptr,
      );
      return resultPtr.copyAsList();
    } finally {
      resultPtr?.dispose();
      seedPtr?.dispose();
    }
  }

  @override
  void close() {
    final result = sodium.randombytes_close();
    SodiumException.checkSucceededInt(result);
  }

  @override
  void stir() => sodium.randombytes_stir();
}
