import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final CollectionReference lists =
      FirebaseFirestore.instance.collection('lists');

  Future<void> addList(String name, String description, double budget) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      await lists.add({
        'name': name,
        'description': description,
        'budget': budget,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw 'Error creating list: ${e.toString()}';
    }
  }

  // Get current user's lists
  Stream<QuerySnapshot> getListsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return lists
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Update list method
  Future<void> updateList(String docID, String newDescription) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      final doc = await lists.doc(docID).get();
      if (!doc.exists) throw 'List not found';

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != user.uid) {
        throw 'You don\'t have permission to modify this list';
      }

      await lists.doc(docID).update({
        'description': newDescription,
      });
    } catch (e) {
      throw 'Error updating list: ${e.toString()}';
    }
  }

  // Delete list method
  Future<void> deleteList(String docID) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'User not authenticated';

      final doc = await lists.doc(docID).get();
      if (!doc.exists) throw 'List not found';

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != user.uid) {
        throw 'You don\'t have permission to delete this list';
      }

      await lists.doc(docID).delete();
    } catch (e) {
      throw 'Error deleting list: ${e.toString()}';
    }
  }
}
