import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  const project = Project(
    id: 'server-id',
    title: 'Portfolio',
    description: 'Demo',
    techStack: 'Django',
    projectUrl: '',
  );
  final data = {...project.toJson(), 'id': project.id};

  test('Public GET parses JSON array without Authorization', () async {
    final api = ApiClient(
      baseUrl: 'http://example.test/',
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://example.test/api/v1/projects/');
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response(jsonEncode([data]), 200);
      }),
    );
    addTearDown(api.close);
    final projects = await api.getProjects();
    expect(projects.single.id, 'server-id');
    expect(projects.single.techStack, 'Django');
  });

  test(
    'Create sends snake_case JSON without id and authenticates by token',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/projects/');
          expect(request.headers['Authorization'], 'Token test-only');
          expect(request.headers['Content-Type'], contains('application/json'));
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body.containsKey('id'), isFalse);
          expect(body['tech_stack'], 'Django');
          return http.Response(jsonEncode(data), 201);
        }),
      );
      addTearDown(api.close);
      expect(
        (await api.createProject(project, token: 'test-only')).id,
        'server-id',
      );
    },
  );

  test(
    'Login posts credentials; logout accepts an empty 204 response',
    () async {
      final api = ApiClient(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          if (request.url.path.endsWith('/token/')) {
            expect(jsonDecode(request.body), {
              'username': 'test-user',
              'password': 'test-password',
            });
            expect(request.headers.containsKey('Authorization'), isFalse);
            return http.Response('{"token":"test-only"}', 200);
          }
          expect(request.url.path, '/api/v1/auth/logout/');
          expect(request.headers['Authorization'], 'Token test-only');
          return http.Response('', 204);
        }),
      );
      addTearDown(api.close);
      final token = await api.obtainToken('test-user', 'test-password');
      await api.logout(token: token);
    },
  );

  test('Every endpoint throws sanitized ApiException on non-2xx', () async {
    final api = ApiClient(
      client: MockClient(
        (_) async => http.Response('PRIVATE SERVER RESPONSE', 401),
      ),
    );
    addTearDown(api.close);
    final matcher = isA<ApiException>()
        .having((error) => error.statusCode, 'status', 401)
        .having(
          (error) => error.toString(),
          'safe message',
          isNot(contains('PRIVATE')),
        );
    await expectLater(api.getProjects(), throwsA(matcher));
    await expectLater(
      api.createProject(project, token: 'test-only'),
      throwsA(matcher),
    );
    await expectLater(
      api.obtainToken('test-user', 'test-password'),
      throwsA(matcher),
    );
    await expectLater(api.logout(token: 'test-only'), throwsA(matcher));
  });
}
