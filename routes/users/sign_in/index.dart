import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

import '../../../mock/session_mock.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
    case HttpMethod.post:
      return _post(context);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _post(RequestContext context) async {
  try {
    await Future<void>.delayed(const Duration(seconds: 1));
    final body = (await context.request.json()) as Map;

    final userEmail = (body['email'] ?? '') as String;
    final password = (body['password'] ?? '') as String;

    if (userEmail.isEmpty || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Preencha os campos corretamente'},
      );
    }

    final userSession = registeredUsers.where((user) {
      return user['email'] == userEmail && user['password'] == password;
    });

    if (userSession.isNotEmpty) {
      final newToken = const Uuid().v4();
      activeTokens.add({userEmail: newToken});
      return Response.json(
        statusCode: 202,
        body: {
          'email': userEmail,
          'name': userSession.first['name'],
          'token': newToken,
        },
      );
    }

    return Response.json(
      statusCode: 422,
      body: {'error': 'Usuário não encontrado'},
    );
  } on Exception {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Preencha os campos corretamente'},
    );
  }
}
