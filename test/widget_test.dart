import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Home retains four action cards and provides ApiClient', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.byType(ItemCard), findsNWidgets(4));
    for (final label in [
      'Lihat Proyek',
      'Tambah Proyek',
      'Logout',
      'Tambah Education',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    final context = tester.element(find.byType(Scaffold).first);
    expect(context.read<ApiClient>(), isA<ApiClient>());
    expect(tester.takeException(), isNull);
  });
}
