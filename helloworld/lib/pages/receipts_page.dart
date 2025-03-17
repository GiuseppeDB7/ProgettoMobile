import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceiptsPage extends StatelessWidget {
  const ReceiptsPage({super.key});

  Future<void> _deleteReceipt(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('receipts')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scontrino eliminato con successo'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errore durante l\'eliminazione'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      extendBodyBehindAppBar: true, // Aggiunto per evitare la fascia scura
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData) {
            return const Center(child: Text('Please log in to view receipts'));
          }

          // Modifica lo StreamBuilder interno
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('receipts')
                .where('userId', isEqualTo: userSnapshot.data!.uid)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error in StreamBuilder: ${snapshot.error}');
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              print('Number of docs: ${docs.length}'); // Debug print

              if (docs.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Nessuno scontrino trovato',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              // Organizziamo gli scontrini per mese
              final groupedReceipts = <String, List<QueryDocumentSnapshot>>{};
              for (var doc in docs) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  print('Document data: $data'); // Debug print
                  final receiptDate = (data['date'] as Timestamp?)?.toDate() ??
                      (data['createdAt'] as Timestamp)
                          .toDate(); // fallback a createdAt
                  final monthKey = DateFormat('MMMM yyyy').format(receiptDate);

                  if (!groupedReceipts.containsKey(monthKey)) {
                    groupedReceipts[monthKey] = [];
                  }
                  groupedReceipts[monthKey]!.add(doc);
                } catch (e) {
                  print('Error processing document: $e');
                  continue;
                }
              }

              // Dopo aver popolato groupedReceipts, ordina i documenti per data
              for (var monthKey in groupedReceipts.keys) {
                groupedReceipts[monthKey]!.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aDate = (aData['date'] as Timestamp?)?.toDate() ??
                      (aData['createdAt'] as Timestamp).toDate();
                  final bDate = (bData['date'] as Timestamp?)?.toDate() ??
                      (bData['createdAt'] as Timestamp).toDate();
                  return bDate.compareTo(
                      aDate); // Ordine decrescente (più recente prima)
                });
              }

              // Ordina anche le chiavi dei mesi per avere i mesi più recenti in alto
              final sortedEntries = groupedReceipts.entries.toList()
                ..sort((a, b) {
                  final aDate = DateFormat('MMMM yyyy').parse(a.key);
                  final bDate = DateFormat('MMMM yyyy').parse(b.key);
                  return bDate.compareTo(aDate); // Ordine decrescente
                });

              // Verifichiamo se abbiamo dati da mostrare
              if (groupedReceipts.isEmpty) {
                return Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Nessuno scontrino trovato',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets
                    .zero, // Rimuovo il padding del SingleChildScrollView
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sortedEntries.map((entry) {
                      // Usa sortedEntries invece di groupedReceipts.entries
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(
                              height: 16), // Spazio dopo il titolo del mese
                          ...entry.value.map((doc) {
                            try {
                              final data = doc.data() as Map<String, dynamic>;
                              final receiptDate =
                                  (data['date'] as Timestamp?)?.toDate() ??
                                      (data['createdAt'] as Timestamp).toDate();
                              final total =
                                  (data['total'] as num?)?.toDouble() ?? 0.0;
                              final fullText =
                                  data['fullText'] as String? ?? 'Nessun testo';

                              // Modifica il Container della receipt
                              return Container(
                                margin: const EdgeInsets.only(
                                    bottom: 8), // Ridotto da 10 a 8
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF000000),
                                      Color(0xFF434343)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical:
                                          8), // Ridotto il padding verticale
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        DateFormat('d MMMM')
                                            .format(receiptDate),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        NumberFormat.currency(
                                          locale: 'it_IT',
                                          symbol: '€',
                                        ).format(total),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4), // Ridotto da 8 a 4
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          fullText.length > 20
                                              ? '${fullText.substring(0, 20)}...'
                                              : fullText,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors
                                                .white, // Cambiato da white70 a white
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Conferma eliminazione'),
                                                  content: const Text(
                                                      'Sei sicuro di voler eliminare questo scontrino?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      child:
                                                          const Text('Annulla'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        _deleteReceipt(
                                                            context, doc.id);
                                                      },
                                                      child: const Text(
                                                        'Elimina',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(
                                        6), // Ridotto da 8 a 6
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.receipt_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            } catch (e) {
                              print('Error rendering receipt: $e');
                              return Container(); // Return empty container in case of error
                            }
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
