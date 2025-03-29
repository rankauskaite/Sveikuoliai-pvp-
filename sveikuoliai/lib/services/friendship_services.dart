import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sveikuoliai/models/friendship_model.dart';

class FriendshipService {
  final CollectionReference friendshipCollection = FirebaseFirestore.instance.collection('friendships'); 

  // create
  Future<void> createFriendship(Friendship friendship) async {
    await friendshipCollection.doc(friendship.id).set(friendship.toJson());
  }

  // read if exists
  Future<Friendship?> getFriendship(String id) async {
    DocumentSnapshot doc = await friendshipCollection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Friendship.fromJson(doc.id, doc.data() as Map<String, dynamic>);
  }

  // update
  Future<void> updateFriendship(Friendship friendship) async {
    Map<String, dynamic> data = friendship.toJson();
    data.removeWhere((key, value) => value == null); // pasalinu null values kad nesusigadintu
    await friendshipCollection.doc(friendship.id).update(data);
  }

  // delete
  Future<void> deleteFriendship(String id) async {
    await friendshipCollection.doc(id).delete();
  }

  // if exists
  Future<bool> friendshipExists(String user1, String user2) async {
    String friendshipId = Friendship.generateFriendshipId(user1, user2);
    DocumentSnapshot doc = await friendshipCollection.doc(friendshipId).get();
    return doc.exists;
  }

  // userio visos draugystes readall
  Future<List<Friendship>> getUserFriendships(String userId) async {
    QuerySnapshot querySnapshot = await friendshipCollection
        .where('user1', isEqualTo: userId)
        .get();
    List<Friendship> friendships = querySnapshot.docs
        .map((doc) => Friendship.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();

    QuerySnapshot querySnapshot2 = await friendshipCollection
        .where('user2', isEqualTo: userId)
        .get();
    friendships.addAll(querySnapshot2.docs
        .map((doc) => Friendship.fromJson(doc.id, doc.data() as Map<String, dynamic>)));

    return friendships;
  }

  // update status - idk ar reikia
  Future<void> updateFriendshipStatus(String user1, String user2, String newStatus) async {
    String friendshipId = Friendship.generateFriendshipId(user1, user2);
    await friendshipCollection.doc(friendshipId).update({'status': newStatus});
  }
}
