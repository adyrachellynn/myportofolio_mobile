import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

Finder field(String label) => find.ancestor(
  of: find.byWidgetPredicate(
    (widget) =>
        widget is InputDecorator && widget.decoration.labelText == label,
  ),
  matching: find.byType(TextFormField),
);

Future<void> fill(WidgetTester tester, String label, String value) async {
  await tester.ensureVisible(field(label));
  await tester.enterText(field(label), value);
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

Widget formApp(ApiClient api, AuthState auth) => MultiProvider(
  providers: [
    Provider<ApiClient>.value(value: api),
    ChangeNotifierProvider<AuthState>.value(value: auth),
  ],
  child: const MaterialApp(home: ProjectFormPage()),
);

void main() {
  test('AuthState logs in and always clears token when logout fails', () async {
    final api = ApiClient(
      client: MockClient(
        (request) async => request.url.path.endsWith('/token/')
            ? http.Response('{"token":"test-only"}', 200)
            : http.Response('PRIVATE', 503),
      ),
    );
    final auth = AuthState(api);
    addTearDown(api.close);
    addTearDown(auth.dispose);
    var changes = 0;
    auth.addListener(() => changes++);
    await auth.login('test-user', 'test-password');
    expect(auth.isLoggedIn, isTrue);
    await auth.logout();
    expect(auth.token, isNull);
    expect(changes, 2);
  });

  testWidgets(
    'Card guard cancels, validates login, then opens form and logs out',
    (tester) async {
      var requests = 0;
      final api = ApiClient(
        client: MockClient((_) async {
          requests++;
          return http.Response('{"token":"test-only"}', 200);
        }),
      );
      tester.platformDispatcher.textScaleFactorTestValue = 0.8;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(MyApp(apiClient: api));
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsNothing);
      await tester.tap(find.text('Tambah Proyek'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(requests, 0);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: field('Password'),
                matching: find.byType(EditableText),
              ),
            )
            .obscureText,
        isTrue,
      );
      await fill(tester, 'Username', 'test-user');
      await fill(tester, 'Password', 'test-password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(requests, 1);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Logout').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Logout').hitTestable());
      await tester.pumpAndSettle();
      final auth = tester
          .element(find.byType(ProjectFormPage))
          .read<AuthState>();
      expect(auth.isLoggedIn, isFalse);
    },
  );

  testWidgets('Drawer Add Project uses login guard and resumes after success', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient(
        (_) async => http.Response('{"token":"test-only"}', 200),
      ),
    );
    tester.platformDispatcher.textScaleFactorTestValue = 0.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await fill(tester, 'Username', 'test-user');
    await fill(tester, 'Password', 'test-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets(
    'Login shows progress, disables submit, and hides server response on failure',
    (tester) async {
      final completer = Completer<http.Response>();
      final api = ApiClient(client: MockClient((_) => completer.future));
      final auth = AuthState(api);
      addTearDown(api.close);
      addTearDown(auth.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: auth,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await fill(tester, 'Username', 'test-user');
      await fill(tester, 'Password', 'test-password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      completer.complete(http.Response('PRIVATE', 400));
      await tester.pumpAndSettle();
      expect(auth.isLoggedIn, isFalse);
      expect(find.textContaining('Login gagal'), findsOneWidget);
      expect(find.textContaining('PRIVATE'), findsNothing);
    },
  );

  for (final status in [201, 200, 401, 403]) {
    testWidgets('Save handles HTTP $status correctly', (tester) async {
      var calls = 0;
      Map<String, dynamic>? payload;
      final api = ApiClient(
        client: MockClient((request) async {
          calls++;
          expect(request.headers['Authorization'], 'Token test-only');
          payload = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({...payload!, 'id': 'created'}),
            status,
          );
        }),
      );
      final auth = AuthState(api, initialToken: 'test-only');
      addTearDown(api.close);
      addTearDown(auth.dispose);
      await tester.pumpWidget(formApp(api, auth));
      await save(tester);
      expect(calls, 0);
      await fill(tester, 'Nama Proyek', 'My Project');
      await fill(tester, 'Deskripsi Proyek', 'Description');
      await fill(tester, 'Teknologi yang Digunakan', 'Flutter');
      await fill(tester, 'Tautan Proyek', 'not-a-url');
      await save(tester);
      expect(calls, 0);
      await fill(tester, 'Tautan Proyek', 'https://example.com');
      await fill(tester, 'URL Gambar Proyek', 'https://example.com/logo.png');
      await save(tester);
      expect(calls, 1);
      expect(
        payload!.keys,
        containsAll([
          'title',
          'description',
          'tech_stack',
          'project_url',
          'project_image_url',
        ]),
      );
      expect(payload!.containsKey('id'), isFalse);
      expect(payload!.containsKey('category'), isFalse);
      if (status == 201) {
        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<EditableText>(
                find.descendant(
                  of: field('Nama Proyek'),
                  matching: find.byType(EditableText),
                ),
              )
              .controller
              .text,
          isEmpty,
        );
      } else {
        expect(find.byType(AlertDialog), findsNothing);
        if (status == 401) {
          expect(auth.isLoggedIn, isFalse);
          expect(find.byType(LoginScreen), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
          expect(find.byType(ProjectFormPage), findsOneWidget);
          expect(calls, 1);
        } else if (status == 403) {
          expect(find.textContaining('tidak punya izin'), findsOneWidget);
          expect(auth.isLoggedIn, isTrue);
        }
      }
      expect(tester.takeException(), isNull);
    });
  }
}
