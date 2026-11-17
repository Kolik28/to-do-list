import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/main.dart';

void main() {
  testWidgets('Daylist home screen renders', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pump();
    expect(find.text('daylist.'), findsOneWidget);
    expect(find.text('Make today count.'), findsOneWidget);
    expect(find.text('New task'), findsOneWidget);
  });
}
