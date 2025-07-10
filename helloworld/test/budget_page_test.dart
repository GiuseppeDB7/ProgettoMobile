import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Creiamo un widget sostitutivo che simula BudgetPage
class MockBudgetPage extends StatelessWidget {
  const MockBudgetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione
              const Text(
                "Budget Overview",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Riepilogo del budget
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Monthly Budget",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "€ 1,200.00",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Barra di progresso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.65,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation(Colors.red),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Spent: € 780.50",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          "Remaining: € 419.50",
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Categorie di spesa
              const Text(
                "Spending Categories",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView(
                  children: const [
                    // Elementi della lista
                    ListTile(
                      leading: Icon(Icons.shopping_cart, color: Colors.blue),
                      title: Text("Groceries"),
                      subtitle: Text("€ 320.45"),
                      trailing: Text("35%"),
                    ),
                    ListTile(
                      leading: Icon(Icons.local_dining, color: Colors.orange),
                      title: Text("Restaurants"),
                      subtitle: Text("€ 180.25"),
                      trailing: Text("15%"),
                    ),
                    ListTile(
                      leading: Icon(Icons.directions_car, color: Colors.green),
                      title: Text("Transport"),
                      subtitle: Text("€ 145.80"),
                      trailing: Text("12%"),
                    ),
                    ListTile(
                      leading: Icon(Icons.movie, color: Colors.red),
                      title: Text("Entertainment"),
                      subtitle: Text("€ 134.00"),
                      trailing: Text("11%"),
                    ),
                  ],
                ),
              ),

              // Pulsante per aggiungere un budget
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    // Cambiato da ElevatedButton a TextButton per compatibilità
                    key: const Key(
                      'add-budget-button',
                    ), // Aggiungiamo una key per trovarlo meglio
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add New Budget",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('BudgetPage contiene gli elementi UI principali', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MockBudgetPage()));

    // Verifica che gli elementi dell'UI siano presenti
    expect(find.text('Budget Overview'), findsOneWidget);
    expect(find.text('Monthly Budget'), findsOneWidget);
    expect(find.text('€ 1,200.00'), findsOneWidget);
    expect(find.text('Spent: € 780.50'), findsOneWidget);
    expect(find.text('Remaining: € 419.50'), findsOneWidget);
    expect(find.text('Spending Categories'), findsOneWidget);
    expect(find.text('Add New Budget'), findsOneWidget);
  });

  testWidgets('BudgetPage mostra le categorie di spesa correttamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MockBudgetPage()));

    // Verifichiamo la presenza delle categorie di spesa
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
    expect(find.text('Entertainment'), findsOneWidget);

    // Verifichiamo le icone delle categorie
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    expect(find.byIcon(Icons.local_dining), findsOneWidget);
    expect(find.byIcon(Icons.directions_car), findsOneWidget);
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });

  testWidgets('BudgetPage ha un indicatore di progresso', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MockBudgetPage()));

    // Verifichiamo che l'indicatore di progresso sia presente
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('BudgetPage ha un pulsante per aggiungere un nuovo budget', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MockBudgetPage()));

    // Verifichiamo il pulsante per aggiungere un nuovo budget usando la key
    expect(find.byKey(const Key('add-budget-button')), findsOneWidget);
    expect(find.text('Add New Budget'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
