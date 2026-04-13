// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const List<int> _enviedkeygeminiKey = <int>[
    2855905717,
    1141723035,
    252174662,
    1272616793,
    241687211,
    2010813558,
    3752010839,
    3732449212,
    2047376247,
    1486567184,
    3100522100,
    2658686672,
    2728311339,
    521180324,
    526984580,
  ];

  static const List<int> _envieddatageminiKey = <int>[
    2855905758,
    1141723134,
    252174655,
    1272616710,
    241687245,
    2010813444,
    3752010808,
    3732449233,
    2047376168,
    1486567287,
    3100522001,
    2658686653,
    2728311362,
    521180362,
    526984685,
  ];

  static final String geminiKey = String.fromCharCodes(
    List<int>.generate(
      _envieddatageminiKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddatageminiKey[i] ^ _enviedkeygeminiKey[i]),
  );
}
