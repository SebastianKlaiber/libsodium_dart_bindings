import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/sign.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
import '../bindings/to_safe_int.dart';
import 'helpers/sign/signature_consumer_js.dart';
import 'helpers/sign/verification_consumer_js.dart';
import 'secure_key_js.dart';

@internal
class SignJS with SignValidations implements Sign {
  final LibSodiumJS sodium;

  SignJS(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_sign_PUBLICKEYBYTES.toSafeUInt32();

  @override
  int get secretKeyBytes => sodium.crypto_sign_SECRETKEYBYTES.toSafeUInt32();

  @override
  int get bytes => sodium.crypto_sign_BYTES.toSafeUInt32();

  @override
  int get seedBytes => sodium.crypto_sign_SEEDBYTES.toSafeUInt32();

  @override
  KeyPair keyPair() {
    final keyPair = JsError.wrap(() => sodium.crypto_sign_keypair());

    return KeyPair(
      publicKey: keyPair.publicKey,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);

    final keyPair = JsError.wrap(
      () => seed.runUnlockedSync(
        (seedData) => sodium.crypto_sign_seed_keypair(seedData),
      ),
    );

    return KeyPair(
      publicKey: keyPair.publicKey,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  Uint8List call({
    required Uint8List message,
    required SecureKey secretKey,
  }) {
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_sign(message, secretKeyData),
      ),
    );
  }

  @override
  Uint8List open({
    required Uint8List signedMessage,
    required Uint8List publicKey,
  }) {
    validateSignedMessage(signedMessage);
    validatePublicKey(publicKey);

    return JsError.wrap(
      () => sodium.crypto_sign_open(signedMessage, publicKey),
    );
  }

  @override
  Uint8List detached({
    required Uint8List message,
    required SecureKey secretKey,
  }) {
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_sign_detached(message, secretKeyData),
      ),
    );
  }

  @override
  bool verifyDetached({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    validateSignature(signature);
    validatePublicKey(publicKey);

    return JsError.wrap(
      () => sodium.crypto_sign_verify_detached(
        signature,
        message,
        publicKey,
      ),
    );
  }

  @override
  SignatureConsumer createConsumer({
    required SecureKey secretKey,
  }) {
    validateSecretKey(secretKey);

    return SignatureConsumerJS(
      sodium: sodium,
      secretKey: secretKey,
    );
  }

  @override
  VerificationConsumer createVerifyConsumer({
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    validateSignature(signature);
    validatePublicKey(publicKey);

    return VerificationConsumerJS(
      sodium: sodium,
      signature: signature,
      publicKey: publicKey,
    );
  }

  @override
  SecureKey skToSeed(SecureKey secretKey) {
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => SecureKeyJS(
          sodium,
          sodium.crypto_sign_ed25519_sk_to_seed(secretKeyData),
        ),
      ),
    );
  }

  @override
  Uint8List skToPk(SecureKey secretKey) {
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_sign_ed25519_sk_to_pk(secretKeyData),
      ),
    );
  }
}
