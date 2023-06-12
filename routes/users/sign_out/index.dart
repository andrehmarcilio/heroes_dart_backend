import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../../mock/session_mock.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
    case HttpMethod.post:
    case HttpMethod.delete:
      return _delete(context);
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _delete(RequestContext context) async {
  try {
    final header = context.request.headers;

    final userEmail = header['USER_EMAIL'] ?? '';
    final token = header['USER_TOKEN'] ?? '';

    final userSession = activeTokens.where((activeToken) {
      return activeToken[userEmail] == token;
    });

    if (userSession.isNotEmpty) {
      activeTokens.remove(userSession.first);
      return Response.json();
    }

    return Response.json(
      statusCode: 422,
      body: {'error': 'Usuário não encontrado'},
    );
  } on Exception {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Preencha os campos corretamente'},
    );
  }
}
