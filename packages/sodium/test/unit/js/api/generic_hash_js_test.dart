@OnPlatform(<String, dynamic>{'!js': Skip('Requires dart:js')})

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/generic_hash_js.dart';
import 'package:sodium/src/js/api/helpers/generic_hash/generic_hash_consumer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late GenericHashJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = GenericHashJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_generichash_BYTES,
      () => sut.bytes,
      'bytes',
    ),
    Tuple3(
      () => mockSodium.crypto_generichash_BYTES_MIN,
      () => sut.bytesMin,
      'bytesMin',
    ),
    Tuple3(
      () => mockSodium.crypto_generichash_BYTES_MAX,
      () => sut.bytesMax,
      'bytesMax',
    ),
    Tuple3(
      () => mockSodium.crypto_generichash_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_generichash_KEYBYTES_MIN,
      () => sut.keyBytesMin,
      'keyBytesMin',
    ),
    Tuple3(
      () => mockSodium.crypto_generichash_KEYBYTES_MAX,
      () => sut.keyBytesMax,
      'keyBytesMax',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_generichash_BYTES_MIN).thenReturn(5);
      when(() => mockSodium.crypto_generichash_BYTES_MAX).thenReturn(5);
      when(() => mockSodium.crypto_generichash_KEYBYTES_MIN).thenReturn(5);
      when(() => mockSodium.crypto_generichash_KEYBYTES_MAX).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_generichash_keygen,
    );

    group('call', () {
      test('asserts if outLen is invalid', () {
        expect(
          () => sut(
            message: Uint8List(0),
            outLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_BYTES_MIN);
        verify(() => mockSodium.crypto_generichash_BYTES_MAX);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut(
            message: Uint8List(0),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_KEYBYTES_MIN);
        verify(() => mockSodium.crypto_generichash_KEYBYTES_MAX);
      });

      test('calls crypto_generichash with correct defaults', () {
        const hashBytes = 15;
        when(() => mockSodium.crypto_generichash_BYTES).thenReturn(hashBytes);
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = List.generate(20, (index) => index * 2);

        sut(message: Uint8List.fromList(message));

        verify(
          () => mockSodium.crypto_generichash(
            hashBytes,
            Uint8List.fromList(message),
            null,
          ),
        );
      });

      test('calls crypto_generichash with all arguments', () {
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        const outLen = 5;
        final key = List.generate(5, (index) => index * 10);
        final message = List.generate(20, (index) => index * 2);

        sut(
          message: Uint8List.fromList(message),
          outLen: outLen,
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_generichash(
            outLen,
            Uint8List.fromList(message),
            Uint8List.fromList(key),
          ),
        );
      });

      test('returns calculated hash', () {
        final hash = List.generate(25, (index) => 10 + index);
        when(() => mockSodium.crypto_generichash_BYTES).thenReturn(hash.length);
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(hash));

        final result = sut(message: Uint8List(10));

        expect(result, hash);
      });

      test('throws exception on failure', () {
        when(() => mockSodium.crypto_generichash_BYTES).thenReturn(10);
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut(
            message: Uint8List(15),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('createConsumer', () {
      test('asserts if outLen is invalid', () {
        expect(
          () => sut.createConsumer(
            outLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_BYTES_MIN);
        verify(() => mockSodium.crypto_generichash_BYTES_MAX);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.createConsumer(
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_KEYBYTES_MIN);
        verify(() => mockSodium.crypto_generichash_KEYBYTES_MAX);
      });

      test('returns GenericHashConsumerJS with defaults', () {
        const outLen = 55;
        when(() => mockSodium.crypto_generichash_BYTES).thenReturn(outLen);
        when(
          () => mockSodium.crypto_generichash_init(
            any(),
            any(),
          ),
        ).thenReturn(0);

        final result = sut.createConsumer();

        expect(
          result,
          isA<GenericHashConsumerJS>()
              .having((c) => c.sodium, 'sodium', mockSodium)
              .having(
                (c) => c.outLen,
                'outLen',
                outLen,
              ),
        );
      });

      test('returns GenericHashConsumerJS with key', () {
        when(
          () => mockSodium.crypto_generichash_init(
            any(),
            any(),
          ),
        ).thenReturn(0);

        const outLen = 5;
        final secretKey = List.generate(5, (index) => index * index);

        final result = sut.createConsumer(
          outLen: outLen,
          key: SecureKeyFake(secretKey),
        );

        expect(
          result,
          isA<GenericHashConsumerJS>()
              .having((c) => c.sodium, 'sodium', mockSodium)
              .having(
                (c) => c.outLen,
                'outLen',
                outLen,
              ),
        );
      });
    });
  });
}
