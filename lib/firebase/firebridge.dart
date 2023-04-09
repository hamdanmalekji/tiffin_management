import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiffin_app/home_page.dart';
import 'package:collection/collection.dart';

class FireBridge {
  static Future<List<String>?> loadAllUsers() async {
    final list = await FirebaseFirestore.instance
        .collection('Tiffin')
        .doc('users')
        .get();
    if (list.exists) {
      print('Load ${list.data()!['list']}');
      return List.from(list.data()!['list']);
    }
    return null;
  }

  static Future<Map<String, bool>?> loadTicks(String name) async {
    try {
      final list = await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('user|$name')
          .get();
      if (list.exists) {
        print('Load ${list.data()!['ticks']}');
        return Map.from(list.data()!['ticks'] ?? {});
      } else {
        await FirebaseFirestore.instance
            .collection('Tiffin')
            .doc('user|$name')
            .set({'ticks': {}});
        return {};
      }
    } on Exception catch (e) {}
    return null;
  }

  static Future<Map<String, List<TransactionModel>>?> loadTransaction() async {

      final payments = await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('payments')
          .get();
      if (payments.data() == null) {
        return {};
      }
      return payments.data()!.map<String,List<TransactionModel>>(
            (key, value) => MapEntry(
          key,
          List.of(value).map<TransactionModel>(
                (e) => TransactionModel(format.parse(e['date']), e['amount']),
          ).toList(growable: false),
        ),
      );
  }

  static Future<TiffinData?> loadTiffinData(List<String> users) async {
    try {
      final list = await FirebaseFirestore.instance.collection('Tiffin').get();
      if (list.docs.length > 1) {
        final out = list.docs
            .where((element) => element.id.startsWith('user|'))
            .toList();
        final List<Map<String, bool>> outputList = [];
        for (final user in users) {
          outputList.add(Map<String, bool>.from(out
                  .firstWhereOrNull((element) => element.id == 'user|$user')
                  ?.data()['ticks'] ??
              {}));
        }
        final cost =
            list.docs.firstWhereOrNull((element) => element.id == 'cost');
        return TiffinData(
            outputList,
            Map<String, num>.from(cost
                    ?.data()
                    .entries
                    .where((element) => element.value != null)
                    .toList(growable: false)
                    .asMap()
                    .map((key, value) => MapEntry(
                        value.key.replaceAll('_', '/'), value.value)) ??
                {}));
      }
    } on Exception {}
    return null;
  }

  static Future<bool> updateTick(String name, Map<String, bool> ticks) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('user|$name')
          .update({'ticks': ticks});
      return true;
    } on Exception {
      return false;
    }
  }
  static Future<bool> updateUserName(List<String> users) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('user')
          .update({'list':users});
      print('DONE');
      return true;
    } on Exception catch (e) {
      print('ERROR ${e.toString()}');
      return false;
    }
  }

  static Future<bool> updateCost(String date, num? cost) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('cost')
          .update({date.replaceAll('/', '_'): cost});
      print('DONE');
      return true;
    } on Exception catch (e) {
      print('ERROR ${e.toString()}');
      return false;
    }
  }

  static Future<bool> addTransaction(String user, double amount) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('payments')
          .update(
        {
          user: FieldValue.arrayUnion(
            [
              {
                'date': format.format(DateTime.now()),
                'amount': amount,
              }
            ],
          ),
        },
      );
      return true;
    } on Exception catch (e) {
      print('ERROR ${e.toString()}');
      return false;
    }
  }

  static Future<bool> addUser(String user) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('users').update({"list":FieldValue.arrayUnion([user])});

      return true;
    } on Exception catch (e) {
      print('ERROR ${e.toString()}');
      return false;
    }
  }

  static Future<bool> removeUser(String user) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tiffin')
          .doc('users').update({"list":FieldValue.arrayRemove([user])});

      return true;
    } on Exception catch (e) {
      print('ERROR ${e.toString()}');
      return false;
    }
  }

  static Future<TiffinViewModel?> loadTiffins(
      List<String> users, DateTime start, DateTime end) async {
    final Map<String, List<String>> map = {};
    final lower = start.subtract(const Duration(days: 1));
    final upper = end.add(const Duration(days: 1));
    final model = await loadTiffinData(users);
    if (model != null) {
      final ticks = model.ticks;
      for (int i = 0; i < users.length; i++) {
        final user = users[i];
        final data = ticks[i];
        for (final entry in data.entries.where((element) => element.value)) {
          final date = format.parse(entry.key);
          if (date.isAfter(lower) && date.isBefore(upper)) {
            if (map.containsKey(entry.key)) {
              map[entry.key]!.add(user);
            } else {
              map[entry.key] = [user];
            }
          }
        }
      }
      return TiffinViewModel(map, model.cost);
    }
    return null;
  }
}

class TransactionModel {
  final DateTime dateTime;
  final double amount;

  TransactionModel(this.dateTime, this.amount);
}

class TiffinViewModel {
  final Map<String, List<String>> map;
  final Map<String, num> cost;

  TiffinViewModel(this.map, this.cost);
}

class TiffinData {
  final List<Map<String, bool>> ticks;
  final Map<String, num> cost;

  TiffinData(this.ticks, this.cost);
}
