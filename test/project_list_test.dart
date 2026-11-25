import 'dart:async';

import 'package:myportofolio_mobile/services/auth_state.dart';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:provider/provider.dart';

Widget app(ApiClient api) => MultiProvider(
  providers: [
    Provider<ApiClient>.value(value: api),
    ChangeNotifierProvider(create: (_) => AuthState(api)),
  ],
  child: const MaterialApp(home: ProjectListScreen()),
);

void main() {
  testWidgets('Loading, empty refresh, and no fetching again on rebuild', (
    tester,
  ) async {
    var calls = 0;
    final response = Completer<http.Response>();
    final api = ApiClient(
      client: MockClient((_) {
        calls++;
        return calls == 1
            ? response.future
            : Future.value(http.Response('[]', 200));
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(app(api));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    response.complete(http.Response('[]', 200));
    await tester.pumpAndSettle();
    expect(find.text('No projects found.'), findsOneWidget);
    tester.element(find.byType(ProjectListScreen)).markNeedsBuild();
    await tester.pump();
    expect(calls, 1);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });

  testWidgets(
    'Failure hides server response; Retry loads list and selected detail',
    (tester) async {
      var calls = 0;
      final api = ApiClient(
        client: MockClient((_) async {
          calls++;
          if (calls == 1) return http.Response('PRIVATE SERVER RESPONSE', 500);
          return http.Response(
            jsonEncode([
              {
                'id': 'selected',
                'title': 'Selected project',
                'description': 'Description',
                'tech_stack': 'Flutter',
                'project_url': 'https://example.com',
                'project_image_url': '',
              },
            ]),
            200,
          );
        }),
      );
      addTearDown(api.close);
      await tester.pumpWidget(app(api));
      await tester.pumpAndSettle();
      expect(find.textContaining('PRIVATE'), findsNothing);
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      await tester.tap(find.text('Selected project'));
      await tester.pumpAndSettle();
      final detail = tester.widget<ProjectDetailScreen>(
        find.byType(ProjectDetailScreen),
      );
      expect(detail.project.id, 'selected');
      expect(find.text('Teknologi: Flutter'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  testWidgets('Failed refresh stays handled and displays Retry', (
    tester,
  ) async {
    var calls = 0;
    final api = ApiClient(
      client: MockClient(
        (_) async => ++calls == 1
            ? http.Response('[]', 200)
            : http.Response('PRIVATE', 503),
      ),
    );
    addTearDown(api.close);
    await tester.pumpWidget(app(api));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Detail includes an image only for nonempty image URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProjectDetailScreen(
          project: Project(
            title: 'Image project',
            description: 'Demo',
            techStack: 'Flutter',
            projectUrl: '',
            projectImageUrl: 'https://example.com/image.png',
          ),
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
