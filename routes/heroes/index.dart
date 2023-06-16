import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../../mock/heroes_mock.dart';
import '../../mock/session_mock.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context);
    case HttpMethod.post:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.put:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context) async {
  await Future<void>.delayed(const Duration(seconds: 1));
  final header = context.request.headers;

  try {
    final userEmail = header['USER_EMAIL'] ?? '';
    final token = header['USER_TOKEN'] ?? '';

    final userSession = activeTokens.where((activeToken) {
      return activeToken[userEmail] == token;
    });

    if (userSession.isNotEmpty) {
      return Response.json(body: heroesMock);
    }

    return Response.json(
      statusCode: 401,
      body: {'error': 'Nenhuma sessão encontrada, por favor, faça o login ;)'},
    );
  } on Exception {
    return Response.json(
      statusCode: 401,
      body: {'error': 'Nenhuma sessão encontrada, por favor, faça o login ;)'},
    );
  }
}
