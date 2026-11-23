import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

Finder field(String label) => find.ancestor(
  of: find.byWidgetPredicate(
    (widget) =>
        widget is InputDecorator && widget.decoration.labelText == label,
  ),
  matching: find.byType(TextFormField),
);

Future<void> enter(WidgetTester tester, String label, String value) async {
  final target = field(label);
  await tester.ensureVisible(target);
  await tester.enterText(target, value);
  tester.testTextInput.hide();
  await tester.pumpAndSettle();
}

Future<void> save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Simpan'));
  await tester.tap(find.text('Simpan'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Required fields, limits, and optional HTTP(S) URL validation', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    for (final entry in {
      'Nama Gelar / Sertifikasi': 255,
      'Institusi / Penyelenggara': 255,
      'Tahun / Periode': 50,
    }.entries) {
      final input = tester.widget<TextFormField>(field(entry.key));
      expect(input.validator!(null), isNotNull);
      expect(input.validator!('   '), isNotNull);
      expect(input.validator!('x' * entry.value), isNull);
      expect(input.validator!('x' * (entry.value + 1)), isNotNull);
    }
    final url = tester.widget<TextFormField>(
      field('URL Gambar / Logo Institusi'),
    );
    for (final invalid in [
      'abc',
      'ftp://example.com',
      'https://',
      'https://bad host/logo',
      'https://-invalid.com/logo',
      'https://example.com:99999/logo',
    ]) {
      expect(url.validator!(invalid), isNotNull);
    }
    for (final valid in [
      '',
      '  ',
      'https://example.com/logo.png',
      'http://example.com',
    ]) {
      expect(url.validator!(valid), isNull);
    }
    await save(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text('Nama gelar / sertifikasi tidak boleh kosong!'),
      findsOneWidget,
    );
  });

  testWidgets('Narrow form submits all values and resets in place', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));
    await enter(tester, 'Nama Gelar / Sertifikasi', 'S1 Sistem Informasi');
    await enter(tester, 'Institusi / Penyelenggara', 'Universitas Indonesia');
    await enter(tester, 'Tahun / Periode', '2025 - Sekarang');
    await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Certification').last);
    await tester.pumpAndSettle();
    await enter(tester, 'Deskripsi', 'Fokus studi teknologi');
    await enter(tester, 'URL Gambar / Logo Institusi', 'invalid');
    await save(tester);
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      find.text('Masukkan URL http atau https yang valid!'),
      findsOneWidget,
    );
    await enter(
      tester,
      'URL Gambar / Logo Institusi',
      'https://example.com/logo.png',
    );
    await save(tester);
    expect(find.text('Education berhasil ditambahkan!'), findsOneWidget);
    for (final text in [
      'Nama Gelar / Sertifikasi: S1 Sistem Informasi',
      'Institusi / Penyelenggara: Universitas Indonesia',
      'Tahun / Periode: 2025 - Sekarang',
      'Kategori: Certification',
      'Deskripsi: Fokus studi teknologi',
      'URL Gambar / Logo Institusi: https://example.com/logo.png',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(EducationFormPage), findsOneWidget);
    for (final input in tester.widgetList<EditableText>(
      find.byType(EditableText),
    )) {
      expect(input.controller.text, isEmpty);
    }
    expect(
      tester
          .state<FormFieldState<String>>(
            find.byType(DropdownButtonFormField<String>),
          )
          .value,
      'Formal Education',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Education card pushes; drawer replaces and Home returns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 0.8;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Tambah Education'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);
    expect(
      find.text('Kamu telah menekan tombol Tambah Education!'),
      findsOneWidget,
    );
    final context = tester.element(find.byType(EducationFormPage));
    expect(Navigator.of(context).canPop(), isTrue);
    Navigator.of(context).pop();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();
    expect(find.byType(EducationFormPage), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(EducationFormPage))).canPop(),
      isFalse,
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
