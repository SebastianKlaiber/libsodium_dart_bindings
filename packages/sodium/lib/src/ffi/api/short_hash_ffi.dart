import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../../api/short_hash.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/size_t_extension.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';

@internal
class ShortHashFFI with ShortHashValidations, KeygenMixin implements ShortHash {
  final LibSodiumFFI sodium;

  ShortHashFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_shorthash_bytes().toSizeT();

  @override
  int get keyBytes => sodium.crypto_shorthash_keybytes().toSizeT();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_shorthash_keygen,
      );

  @override
  Uint8List call({
    required Uint8List message,
    required SecureKey key,
  }) {
    validateKey(key);

    SodiumPointer<Uint8>? messagePtr;
    SodiumPointer<Uint8>? outPtr;
    try {
      outPtr = SodiumPointer.alloc(sodium, count: bytes);
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_shorthash(
          outPtr!.ptr,
          messagePtr!.ptr,
          messagePtr.count,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return outPtr.copyAsList();
    } finally {
      messagePtr?.dispose();
      outPtr?.dispose();
    }
  }
}
