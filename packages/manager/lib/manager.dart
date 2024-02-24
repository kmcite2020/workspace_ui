// ignore_for_file: no_leading_underscores_for_local_identifiers

library manager;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:manager/hive_storage.dart';
import 'package:states_rebuilder/scr/state_management/state_management.dart';

import 'package:states_rebuilder/states_rebuilder.dart' as rebuilder;

typedef UI = rebuilder.ReactiveStatelessWidget;

class RM<T> {
  final T Function() creator;
  final Persistor<T>? persistor;
  late final rebuilder.Injected<T> rm;
  RM.inject(this.creator, {this.persistor}) {
    rm = rebuilder.Injected(
      creator: creator,
      persist: persistable
          ? () => rebuilder.PersistState(
                key: persistor!.key,
                toJson: (state) => jsonEncode(persistor!.toJson(state)),
                fromJson: (json) => persistor!.fromJson(jsonDecode(json)),
              )
          : null,
    );
  }

  factory RM(T state, {Persistor<T>? persistor}) => RM.inject(
        () => state,
        persistor: persistor,
      );

  bool get persistable => persistor != null;
  T call([T? _state]) => _state != null ? rm.state = _state : rm.state;

  static Future<void> build(
    Widget app, {
    Future<void> Function()? init,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await init?.call();
    await storageInitializer(HiveStorage());
    runApp(app);
  }

  static const storageInitializer = rebuilder.RM.storageInitializer;
  static final navigate = rebuilder.RM.navigate;
  static final scaffold = rebuilder.RM.scaffold;
}

class Persistor<T> {
  final String key;
  final Map<String, dynamic> Function(T state) toJson;
  final FutureOr<T> Function(Map<String, dynamic> json) fromJson;

  Persistor({
    required this.key,
    required this.toJson,
    required this.fromJson,
  });
}

abstract class Cubit<T> {
  T get initialState;
  late final Injected<Object?> rm = RM(
    () => initialState,
    persistor: persistor,
  ).rm;
  T get state => rm.state as T;
  set state(T? newState) {
    if (newState == null) return;
    rm.state = newState;
  }

  Persistor<T>? get persistor => null;
}
