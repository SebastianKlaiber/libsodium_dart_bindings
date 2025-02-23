import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/generic_hash.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/size_t_extension.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/generic_hash/generic_hash_consumer_ffi.dart';
import 'helpers/keygen_mixin.dart';

@internal
class GenericHashFFI
    with GenericHashValidations, KeygenMixin
    implements GenericHash {
  final LibSodiumFFI sodium;

  GenericHashFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_generichash_bytes().toSizeT();

  @override
  int get bytesMin => sodium.crypto_generichash_bytes_min().toSizeT();

  @override
  int get bytesMax => sodium.crypto_generichash_bytes_max().toSizeT();

  @override
  int get keyBytes => sodium.crypto_generichash_keybytes().toSizeT();

  @override
  int get keyBytesMin => sodium.crypto_generichash_keybytes_min().toSizeT();

  @override
  int get keyBytesMax => sodium.crypto_generichash_keybytes_max().toSizeT();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_generichash_keygen,
      );

  @override
  Uint8List call({
    required Uint8List message,
    int? outLen,
    SecureKey? key,
  }) {
    if (outLen != null) {
      validateOutLen(outLen);
    }
    if (key != null) {
      validateKey(key);
    }

    SodiumPointer<Uint8>? outPtr;
    SodiumPointer<Uint8>? inPtr;
    try {
      outPtr = SodiumPointer.alloc(
        sodium,
        count: outLen ?? bytes,
      );
      inPtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runMaybeUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_generichash(
          outPtr!.ptr,
          outPtr.count.toIntPtr(),
          inPtr!.ptr,
          inPtr.count,
          keyPtr?.ptr ?? nullptr,
          keyPtr?.count.toIntPtr() ?? 0,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return outPtr.copyAsList();
    } finally {
      outPtr?.dispose();
      inPtr?.dispose();
    }
  }

  @override
  GenericHashConsumer createConsumer({
    int? outLen,
    SecureKey? key,
  }) {
    if (outLen != null) {
      validateOutLen(outLen);
    }
    if (key != null) {
      validateKey(key);
    }

    return GenericHashConsumerFFI(
      sodium: sodium,
      outLen: outLen ?? bytes,
      key: key,
    );
  }
}
