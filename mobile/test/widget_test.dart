import 'package:enterprise_task_management/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the initial task management shell', (tester) async {
    await tester.pumpWidget(const EnterpriseTaskManagementApp());
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Choose organization'), findsOneWidget);
  });
}
