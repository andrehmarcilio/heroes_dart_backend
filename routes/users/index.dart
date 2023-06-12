import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';

import '../../mock/session_mock.dart';

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
    final body = (await context.request.json()) as Map;

    final userName = (body['name'] ?? '') as String;
    final userEmail = (body['email'] ?? '') as String;
    final password = (body['password'] ?? '') as String;

    if (userName.isEmpty || userEmail.isEmpty || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Preencha os campos corretamente'},
      );
    }

    registeredUsers.add(body);

    final newToken = const Uuid().v4();

    activeTokens.add({userEmail: newToken});
    return Response.json(
      statusCode: 202,
      body: {
        'email': userEmail,
        'name': userName,
        'token': newToken,
      },
    );
  } on Exception {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Preencha os campos corretamente'},
    );
  }
}
