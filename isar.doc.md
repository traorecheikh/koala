Schema
Define your data models with Isar collections

Copy Markdown
Open
Schema
When you use Isar to store your app's data, you're dealing with collections. A collection is like a database table and can only contain a single type of Dart object.

Anatomy of a Collection
You define each Isar collection by annotating a class with @collection or @Collection().


@collection
class User {
  Id? id;
  String? firstName;
  String? lastName;
}
To persist a field, Isar must have access to it. Make it public or provide getter and setter methods.

Data Types
Isar supports the following data types:

Primitive Types

@collection
class PrimitiveTypes {
  PrimitiveTypes(this.id);
  final int id;
  bool? boolValue;
  int? intValue;
  double? doubleValue;
  DateTime? dateValue;
  String? stringValue;
}
Lists

@collection
class ListTypes {
  ListTypes(this.id);
  final int id;
  List<bool>? boolList;
  List<int>? intList;
  List<double>? doubleList;
  List<DateTime>? dateList;
  List<String>? stringList;
}
Lists cannot contain null values. Use nullable types instead.

Enums

enum Status { active, inactive, pending }
@collection
class Task {
  Task(this.id);
  final int id;
  @enumerated
  Status? status;
  @Enumerated(EnumType.ordinal)
  Status? ordinalStatus;
  @Enumerated(EnumType.name)
  Status? namedStatus;
}
EnumType.ordinal
EnumType.name
EnumType.value
Stores the index of the enum value (default).


// Status.active = 0
// Status.inactive = 1
// Status.pending = 2
Embedded Objects

@embedded
class Address {
  String? street;
  String? city;
  String? country;
}
@collection
class Person {
  Person(this.id);
  final int id;
  String? name;
  Address? address;
  List<Address>? addresses;
}
Ids
Every collection needs an Id field to uniquely identify objects.


@collection
class User {
  User(this.id);
  final int id;
  String? name;
}
For auto-incrementing IDs, use the collection.autoIncrement() method when inserting:


isar.write((isar) {
  final user = User(isar.users.autoIncrement());
  isar.users.put(user);
});
Custom IDs

@collection
class User {
  User(this.id);
  final int id; // You manage the ID
  String? name;
}
Field Annotations
@Index
Create indexes for better query performance:


@collection
class User {
  User(this.id);
  final int id;
  @Index()
  String? email;
  @Index(type: IndexType.value)
  String? username;
  @Index(caseSensitive: false)
  String? name;
}
@Ignore
Exclude fields from storage:


@collection
class User {
  User(this.id);
  final int id;
  String? name;
  @ignore
  String? temporaryData; // Not stored
}
@Name
Rename fields in the database:


@collection
class User {
  User(this.id);
  final int id;
  @Name("user_name")
  String? name;
}
@Size
Limit string size:


@collection
class User {
  User(this.id);
  final int id;
  @Size(max: 100)
  String? shortText;
  @Size(max: 1000)
  String? longText;
}
Composite Indexes
Create indexes on multiple fields:


@collection
@Index(composite: ['lastName', 'age'])
class User {
  User(this.id);
  final int id;
  String? firstName;
  String? lastName;
  int? age;
}
Modeling Relationships
Isar Plus v4 models relationships with embedded objects or manual ID fields instead of runtime link types. See the dedicated Relationships page for concrete examples lifted from the codebase.

Migration
Isar handles schema migrations automatically in most cases:

Adding new fields
Removing fields
Changing field types (with data loss)
Adding/removing indexes
Changing the type of an existing field will result in data loss for that field.

Next StepsQuick Start
Get started with Isar Plus in your Flutter project

Copy Markdown
Open
Quick Start
This guide will help you get started with Isar Plus in just a few minutes.

Isar Plus works on iOS, Android, Desktop, and Web with persistent storage via OPFS/IndexedDB.

Installation
Add Dependencies
Add Isar Plus to your project:

Flutter
Dart CLI

dependencies:
  isar_plus: ^1.2.0
  isar_plus_flutter_libs: ^1.2.0
  path_provider: ^2.1.5
dev_dependencies:
  build_runner: ^2.10.4
Define Your Schema
Create your first collection:

lib/models/user.dart

import 'package:isar_plus/isar_plus.dart';
part 'user.g.dart';
@collection
class User {
  User({required this.id});
  final int id;
  late String name;
  int? age;
  late String email;
}
The part directive is required for code generation.

Generate Code
Run the code generator:


flutter pub run build_runner build
Or watch for changes:


flutter pub run build_runner watch
Open Isar Instance
Initialize Isar in your app:

lib/main.dart

import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final dir = await getApplicationDocumentsDirectory();
  final isar = Isar.open(
    schemas: [UserSchema],
    directory: dir.path,
  );
  runApp(MyApp(isar: isar));
}
Use Your Database
Start storing and querying data:


// Create
await isar.writeAsync((isar) async {
  final user = User(id: isar.users.autoIncrement())
    ..name = 'John Doe'
    ..age = 25
    ..email = 'john@example.com';
  
  isar.users.put(user);
});
// Read
final allUsers = await isar.users.where().findAllAsync();
// Query
final youngUsers = await isar.users
  .where()
  .ageLessThan(30)
  .findAllAsync();
// Update
await isar.writeAsync((isar) async {
  user.age = 26;
  isar.users.put(user);
});
// Delete
await isar.writeAsync((isar) async {
  isar.users.delete(user.id);
});
Next StepsIndexes
Optimize query performance with powerful indexing strategies

Copy Markdown
Open
Indexes
Indexes are Isar's most powerful feature for query optimization. Learn how to use single, composite, and multi-entry indexes effectively.

Understanding indexes is essential to optimize query performance!

What are Indexes?
Without indexes, queries must scan through every object linearly. With indexes, queries can jump directly to the relevant data.

Example Without Index

@collection
class Product {
  Id? id;
  late String name;
  late int price;
}
Unindexed Data:

id	name	price
1	Book	15
2	Table	55
3	Chair	25
4	Pencil	3
5	Lightbulb	12
6	Carpet	60
7	Pillow	30
8	Computer	650
9	Soap	2
To find products > €30, Isar must check all 9 rows:


final expensive = await isar.products.where()
  .priceGreaterThan(30)
  .findAll();
With Index
Add an index to the price field:


@collection
class Product {
  Id? id;
  late String name;
  
  @Index()
  late int price;
}
Generated Index (sorted):

price	id
2	9
3	4
12	5
15	1
25	3
30	7
55	2
60	6
650	8
Now the query jumps directly to the relevant rows! ⚡

Creating Indexes
Single Property Index

@collection
class User {
  Id? id;
  @Index()
  late String email;
  @Index(type: IndexType.value)
  late String username;
}
IndexType.value
IndexType.hash
IndexType.hashElements
Default - Stores the actual value. Supports all where clauses.


@Index(type: IndexType.value)
late String email;
// Supports: equalTo, between, startsWith, etc.
await isar.users.where()
  .emailStartsWith('john')
  .findAll();
Composite Indexes
Index multiple properties together for complex queries:


@collection
class Person {
  Id? id;
  late String firstName;
  @Index(composite: ['firstName'])
  late String lastName;
  late int age;
}

// Uses composite index efficiently
final people = await isar.persons
  .where()
  .lastNameFirstNameEqualTo('Doe', 'John')
  .findAll();
Composite indexes can also use only the first property: .lastNameEqualTo('Doe')

Multi-Property Composite

@collection
@Index(composite: ['lastName', 'age'])
class Person {
  Id? id;
  late String firstName;
  late String lastName;
  late int age;
}

// All of these use the composite index:
.firstNameEqualTo('John')
.firstNameLastNameEqualTo('John', 'Doe')
.firstNameLastNameAgeEqualTo('John', 'Doe', 25)
Multi-Entry Indexes
Create indexes for list elements:


@collection
class Post {
  Id? id;
  late String title;
  @Index(type: IndexType.value)
  late List<String> tags;
}

// Fast lookup by any tag
final flutterPosts = await isar.posts
  .where()
  .tagsElementEqualTo('flutter')
  .findAll();
Multi-entry indexes can significantly increase database size for lists with many elements.

Unique Indexes
Enforce uniqueness constraints:


@collection
class User {
  Id? id;
  @Index(unique: true)
  late String username;
  late int age;
}

await isar.writeAsync((isar) async {
  final user1 = User()
    ..id = 1
    ..username = 'john_doe'
    ..age = 25;
  await isar.users.put(user1); // ✅ inserted
  final user2 = User()
    ..id = 2
    ..username = 'john_doe'
    ..age = 30;
  await isar.users.put(user2); // ✅ overwrites the previous row
  final current = await isar.users
      .where()
      .usernameEqualTo('john_doe')
      .findFirst();
  print(current);
  // => {id: 2, username: john_doe, age: 30}
});
Unique indexes always replace

v4 keeps the most recent write for a unique key combination. If you need to reject duplicates instead of overwriting, query first and throw your own error:


await isar.writeAsync((isar) async {
  final exists = await isar.users
      .where()
      .usernameEqualTo('john_doe')
      .findFirst();
  if (exists != null) {
    throw StateError('username already taken');
  }
  final user = User()
    ..id = 42
    ..username = 'john_doe'
    ..age = 30;
  await isar.users.put(user);
});
Case Sensitivity
Control case sensitivity for string indexes:


@collection
class User {
  Id? id;
  @Index(caseSensitive: false)
  late String email;
}

// Both find the same user
await isar.users.where().emailEqualTo('JOHN@example.com').findAll();
await isar.users.where().emailEqualTo('john@example.com').findAll();
Case-insensitive indexes take slightly more space but provide flexible queries.

Index for Sorting
Indexes provide super-fast sorting:


@collection
class Product {
  Id? id;
  late String name;
  @Index()
  late int price;
}
Without Index
With Index

// ❌ Slow - loads all, then sorts
final cheapest = await isar.products
  .where()
  .sortByPrice()
  .limit(4)
  .findAll();
Using indexed sorting avoids loading and sorting all results in memory!

Where Clauses
Use indexes with where clauses for maximum performance:


@collection
class Product {
  Id? id;
  late String name;
  @Index()
  late int price;
}

// Fast - uses index
final products = await isar.products
  .where()
  .priceBetween(10, 100)
  .findAll();
// Fast - index + sort
final sorted = await isar.products
  .where()
  .anyPrice()
  .limit(10)
  .findAll();
// Fast - index + filter
final filtered = await isar.products
  .where()
  .priceGreaterThan(50)
  .where()
  .nameStartsWith('iPhone')
  .findAll();
Index Types Comparison
Type	Size	Where Clauses	Use Case
IndexType.value	Large	All	Full text search, ranges
IndexType.hash	Small	Equality only	Unique constraints, lookups
IndexType.hashElements	Medium	List elements	Tag systems, categories
Best Practices
Choose the Right Properties
Index properties used frequently in where clauses:


@collection
class User {
  Id? id;
  @Index() // Frequently queried
  late String email;
  late String name; // Not indexed - rarely queried alone
}
Don't Over-Index
Each index increases write time and storage:


// ❌ Too many indexes
@collection
class User {
  @Index() Id? id; // Id is already indexed!
  @Index() late String email;
  @Index() late String name;
  @Index() late String phone;
  @Index() late int age;
}
// ✅ Index only what you query
@collection
class User {
  Id? id;
  @Index(unique: true) late String email;
  late String name;
  late String phone;
  late int age;
}
Use Composite Indexes Wisely

// ✅ Good - queries firstName + lastName together
  @Index(composite: ['lastName'])
late String firstName;
// ❌ Bad - separate queries
@Index()
late String firstName;
@Index()
late String lastName;
Profile Your Queries
Use Isar Inspector to analyze query performance:


// Enable inspector in debug mode
final isar = Isar.open(
  schemas: [UserSchema],
  inspector: true, // Open inspector
);
Index Limitations
Only the first 1024 bytes of strings are indexed
Maximum of 3 properties in composite indexes (on web)
Indexes increase write operation time
Indexes consume additional storage
Next StepsTransactions
Ensure data consistency with ACID-compliant transactions

Copy Markdown
Open
Transactions
Transactions combine multiple database operations in a single atomic unit of work. Isar provides ACID-compliant transactions with automatic rollback.

All Isar transactions are ACID compliant - Atomic, Consistent, Isolated, Durable.

Overview
Transactions ensure data consistency:

Atomic - All operations succeed or none do
Consistent - Data remains valid
Isolated - Concurrent transactions don't interfere
Durable - Committed changes persist
Transaction Types
Type	Sync Method	Async Method	Use Case
Read	.read()	.readAsync()	Consistent reads
Write	.write()	.writeAsync()	Data modifications
Most read operations use implicit transactions automatically.

Read Transactions
Read transactions provide a consistent snapshot of the database:


@collection
class Contact {
  Id? id;
  late String name;
  late int age;
}
Async
Sync
Implicit

// Explicit async read transaction
final result = await isar.readAsync((isar) async {
  final contacts = isar.contacts.where().findAll();
  final count = isar.contacts.count();
  
  return {
    'contacts': contacts,
    'count': count,
  };
});
Async read transactions run in parallel with other transactions!

Write Transactions
All write operations must be wrapped in an explicit transaction:


await isar.writeAsync((isar) async {
  final contact = Contact()
    ..name = 'John Doe'
    ..age = 25;
  
  isar.contacts.put(contact);
});
Auto Commit
Transactions auto-commit on success:


await isar.writeAsync((isar) async {
  isar.contacts.put(contact1);
  isar.contacts.put(contact2);
  isar.contacts.put(contact3);
  // All changes committed together ✅
});
Auto Rollback
Transactions auto-rollback on error:


try {
  await isar.writeAsync((isar) async {
    isar.contacts.put(contact1); // ✅ Executed
    isar.contacts.put(contact2); // ✅ Executed
    throw Exception('Error!');
    isar.contacts.put(contact3); // ❌ Not executed
  });
} catch (e) {
  // All changes rolled back ↩️
  print('Transaction failed: $e');
}
When a transaction fails, it must not be used again, even if you catch the error.

Best Practices
✅ DO: Batch Operations

// ✅ Good - Single transaction
await isar.writeAsync((isar) async {
  for (var contact in contacts) {
    isar.contacts.put(contact);
  }
});
// ✅ Even better - Bulk operation
await isar.writeAsync((isar) async {
  isar.contacts.putAll(contacts);
});
❌ DON'T: Multiple Transactions

// ❌ Bad - Many transactions (slow!)
for (var contact in contacts) {
  await isar.writeAsync((isar) async {
    isar.contacts.put(contact);
  });
}
✅ DO: Minimize Transaction Scope

// ✅ Good - Prepare data outside transaction
final processedContacts = contacts.map((c) => 
  Contact()
    ..name = c.name.toUpperCase()
    ..age = c.age
).toList();
await isar.writeAsync((isar) async {
  isar.contacts.putAll(processedContacts);
});
❌ DON'T: Heavy Operations Inside

// ❌ Bad - Heavy processing in transaction
await isar.writeAsync((isar) async {
  final processedContacts = contacts.map((c) => 
    Contact()
      ..name = c.name.toUpperCase()
      ..age = c.age
  ).toList();
  
  isar.contacts.putAll(processedContacts);
});
❌ DON'T: Network Calls

// ❌ Very Bad - Network call in transaction
await isar.writeAsync((isar) async {
  final response = await http.get('https://api.example.com/data');
  final contacts = parseContacts(response.body);
  isar.contacts.putAll(contacts);
});
// ✅ Good - Network call outside
final response = await http.get('https://api.example.com/data');
final contacts = parseContacts(response.body);
await isar.writeAsync((isar) async {
  isar.contacts.putAll(contacts);
});
Never perform network calls, file I/O, or other long-running operations inside transactions!

Complex Transactions
Multiple Collections

await isar.writeAsync((isar) async {
  // Create user
  final user = User()..name = 'John';
  isar.users.put(user);
  
  // Create profile linked to user
  final profile = Profile()
    ..userId = user.id
    ..bio = 'Developer';
  isar.profiles.put(profile);
  
  // Create posts
  final posts = [
    Post()..userId = user.id..title = 'First Post',
    Post()..userId = user.id..title = 'Second Post',
  ];
  isar.posts.putAll(posts);
  
  // All operations committed together ✅
});
Conditional Operations

await isar.writeAsync((isar) async {
  final user = await isar.users.get(userId);
  
  if (user != null && user.age >= 18) {
    user.verified = true;
    isar.users.put(user);
  } else {
    throw Exception('User not eligible');
  }
});
Update with Validation

await isar.writeAsync((isar) async {
  final users = isar.users
    .where()
    .ageGreaterThan(18)
    .findAll();
  
  for (var user in users) {
    if (!user.verified) {
      user.verified = true;
      user.verifiedAt = DateTime.now();
      isar.users.put(user);
    }
  }
});
Transaction Isolation
Concurrent Reads
Read During Write
Write Blocking

// Multiple read transactions run in parallel
final future1 = isar.readAsync((isar) async {
  return isar.contacts.where().findAll();
});
final future2 = isar.readAsync((isar) async {
  return isar.contacts.count();
});
// Both execute simultaneously ⚡
final results = await Future.wait([future1, future2]);
Error Handling
Basic Error Handling

try {
  await isar.writeAsync((isar) async {
    isar.contacts.put(contact);
  });
  print('Transaction succeeded');
} catch (e) {
  print('Transaction failed: $e');
  // Changes automatically rolled back
}
Custom Validation

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}
try {
  await isar.writeAsync((isar) async {
    if (contact.age < 0) {
      throw ValidationException('Age cannot be negative');
    }
    isar.contacts.put(contact);
  });
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
} catch (e) {
  print('Unexpected error: $e');
}
Retry Logic

Future<void> putWithRetry(Contact contact, {int maxAttempts = 3}) async {
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await isar.writeAsync((isar) async {
        isar.contacts.put(contact);
      });
      return; // Success
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(Duration(milliseconds: 100 * attempt));
    }
  }
}
Synchronous vs Asynchronous
When to Use Async
When to Use Sync

// ✅ Use async in UI isolate
await isar.writeAsync((isar) async {
  isar.contacts.put(contact);
});
// Doesn't block UI
Default to async in UI code. Use sync only in background isolates for maximum performance.

Performance Tips
Batch Operations


// ✅ Fast - 1 transaction
await isar.writeAsync((isar) => isar.contacts.putAll(list));
// ❌ Slow - N transactions
for (var item in list) {
  await isar.writeAsync((isar) => isar.contacts.put(item));
}
Minimize Duration


// ✅ Fast
final data = prepareData();
await isar.writeAsync((isar) => isar.contacts.putAll(data));
// ❌ Slow
await isar.writeAsync((isar) {
  final data = prepareData(); // Heavy operation
  isar.contacts.putAll(data);
});
Use Bulk Operations


// ✅ Optimized
await isar.writeAsync((isar) async {
  isar.contacts.putAll(contacts);
  isar.posts.deleteAll(postIds);
});
Common Patterns
Create or Update

await isar.writeAsync((isar) async {
  final existing = isar.users
    .where()
    .emailEqualTo(user.email)
    .findFirst();
  
  if (existing != null) {
    user.id = existing.id; // Reuse ID
  }
  
  isar.users.put(user);
});
Atomic Counter

Future<int> incrementCounter(String key) async {
  return await isar.writeAsync((isar) async {
    final counter = isar.counters
      .where()
      .keyEqualTo(key)
      .findFirst() ?? Counter()..key = key..value = 0;
    
    counter.value++;
    isar.counters.put(counter);
    return counter.value;
  });
}
Bulk Update

await isar.writeAsync((isar) async {
  final users = isar.users
    .where()
    .statusEqualTo('pending')
    .findAll();
  
  for (var user in users) {
    user.status = 'active';
  }
  
  isar.users.putAll(users);
});
Next StepsWatchers
React to database changes in real-time

Copy Markdown
Open
Watchers
Watchers allow you to subscribe to changes in your database and react efficiently. Perfect for real-time UI updates and sync operations.

Watchers notify you after a transaction commits successfully and the target actually changes.

Overview
You can watch:

Specific objects - Get notified when one object changes
Collections - Get notified when any object in a collection changes
Queries - Get notified when query results change
Watching Objects
Watch a specific object by its ID:


@collection
class User {
  Id? id;
  late String name;
  late int age;
}
Full Object
Lazy

// Get the updated object
Stream<User?> userStream = isar.users.watchObject(5);
userStream.listen((user) {
  if (user == null) {
    print('User deleted');
  } else {
    print('User changed: ${user.name}');
  }
});
// Trigger changes
final user = User()..id = 5..name = 'David'..age = 25;
await isar.writeAsync((isar) => isar.users.put(user));
// Output: User changed: David
user.name = 'Mark';
await isar.writeAsync((isar) => isar.users.put(user));
// Output: User changed: Mark
await isar.writeAsync((isar) => isar.users.delete(5));
// Output: User deleted
The object doesn't need to exist yet. The watcher will notify you when it's created.

Fire Immediately
Get the current value immediately:


Stream<User?> userStream = isar.users.watchObject(
  5,
  fireImmediately: true,
);
userStream.listen((user) {
  print('User: ${user?.name}');
});
// Immediately outputs current value (or null)
Watching Collections
Watch all changes in a collection:

Lazy
Full Objects

// Just get notified
Stream<void> usersStream = isar.users.watchLazy();
usersStream.listen((_) {
  print('A user changed');
});
await isar.writeAsync((isar) async {
  isar.users.put(User()..name = 'Alice');
});
// Output: A user changed
Watching Queries
Watch specific query results:


@collection
class User {
  Id? id;
  late String name;
  late int age;
}

// Build a query
final adultsQuery = isar.users
  .where()
  .ageGreaterThan(18)
  .build();
// Watch query results
Stream<List<User>> adultsStream = adultsQuery.watch(
  fireImmediately: true,
);
adultsStream.listen((adults) {
  print('Adults: ${adults.map((u) => u.name).join(', ')}');
});
// Immediately outputs current results
// Add a child (no notification)
await isar.writeAsync((isar) async {
  isar.users.put(User()..name = 'Child'..age = 10);
});
// No output - doesn't match query
// Add an adult (triggers notification)
await isar.writeAsync((isar) async {
  isar.users.put(User()..name = 'Alice'..age = 25);
});
// Output: Adults: Alice
// Add another adult
await isar.writeAsync((isar) async {
  isar.users.put(User()..name = 'Bob'..age = 30);
});
// Output: Adults: Alice, Bob
Query watchers only notify when results actually change!

Lazy Query Watching

final adultsQuery = isar.users
  .where()
  .ageGreaterThan(18)
  .build();
Stream<void> adultsStream = adultsQuery.watchLazy();
adultsStream.listen((_) {
  print('Adult users changed');
});
Query Watcher Limitations
When using offset, limit, or distinct, watchers may notify even when visible results haven't changed.


// May over-notify
final topUsers = isar.users
  .where()
  .sortByAge()
  .limit(10)
  .build();
topUsers.watch().listen((users) {
  // Might trigger even if top 10 didn't change
});
Real-World Examples
Flutter UI Updates

class UserListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: isar.users.where().watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        
        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.name),
              subtitle: Text('Age: ${user.age}'),
            );
          },
        );
      },
    );
  }
}
User Profile

class UserProfileWidget extends StatelessWidget {
  final int userId;
  
  const UserProfileWidget({required this.userId});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: isar.users.watchObject(userId, fireImmediately: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('User not found');
        }
        
        final user = snapshot.data!;
        return Column(
          children: [
            Text('Name: ${user.name}'),
            Text('Age: ${user.age}'),
          ],
        );
      },
    );
  }
}
Search Results

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}
class _SearchWidgetState extends State<SearchWidget> {
  String searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final query = isar.users
      .where()
      .nameContains(searchQuery, caseSensitive: false)
      .build();
    
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        Expanded(
          child: StreamBuilder<List<User>>(
            stream: query.watch(fireImmediately: true),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();
              
              final users = snapshot.data!;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(users[index].name),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
Sync to Server

class SyncService {
  void startWatching() {
    isar.users.watchLazy().listen((_) async {
      await syncUsersToServer();
    });
  }
  
  Future<void> syncUsersToServer() async {
    final users = await isar.users.where().findAll();
    // Send to server...
  }
}
Cache Invalidation

class CacheService {
  final _cache = <int, User>{};
  
  void startWatching() {
    isar.users.watchLazy().listen((_) {
      _cache.clear();
      print('Cache invalidated');
    });
  }
  
  Future<User?> getUser(int id) async {
    if (_cache.containsKey(id)) {
      return _cache[id];
    }
    
    final user = await isar.users.get(id);
    if (user != null) {
      _cache[id] = user;
    }
    return user;
  }
}
Performance Considerations
Best Practices
Anti-Patterns

// ✅ Use lazy watchers when you don't need data
isar.users.watchLazy().listen((_) {
  // Just invalidate cache or flag for refresh
  needsRefresh = true;
});
// ✅ Watch specific queries, not entire collections
isar.users
  .where()
  .statusEqualTo('active')
  .watch()
  .listen((activeUsers) {
    // Handle active users
  });
// ✅ Cancel subscriptions when done
final subscription = isar.users.watchLazy().listen((_) {});
// Later...
subscription.cancel();
Combining with StreamBuilder

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: isar.users
        .where()
        .ageGreaterThan(18)
        .build()
        .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No users found');
        }
        
        final users = snapshot.data!;
        return ListView(
          children: users.map((user) => 
            ListTile(title: Text(user.name))
          ).toList(),
        );
      },
    );
  }
}
Best Practices
Use Lazy Watchers when you only need notifications
Watch Specific Queries instead of entire collections
Cancel Subscriptions when widgets are disposed
Avoid Heavy Operations in watcher callbacks
Use fireImmediately for initial UI state
Watchers are efficient and lightweight. Use them freely to create reactive UIs!

Next StepsRelationships
Model related data with embedded objects and explicit IDs

Copy Markdown
Open
Relationships
Isar Plus v4 removed runtime link primitives such as IsarLink and IsarLinks. The compiler now accepts only two annotations—@collection and @embedded—when analyzing your models, as enforced in packages/isar_plus/lib/src/generator/isar_analyzer.dart. If a property uses an unsupported type, the analyzer literally throws the "Unsupported type. Please add @embedded to the type..." error you can see in that file. This page documents the supported patterns that are implemented in the source tree today.

Embed Related Data
Large schemas in the repository, such as the Twitter fixture under packages/isar_plus_test/lib/src/twitter/tweet.dart, embed their related entities directly. The Tweet collection nests the User, Entities, and other DTOs inline, eliminating the need for separate collections:

packages/isar_plus_test/lib/src/twitter/tweet.dart

@collection
class Tweet {
  Tweet();
  @Id()
  late String idStr;
  User? user;              // @embedded in user.dart
  Entities? entities;      // @embedded in entities.dart
  Entities? extendedEntities;
  CurrentUserRetweet? currentUserRetweet; // @embedded below
}
@embedded
class CurrentUserRetweet {
  CurrentUserRetweet();
  String? idStr;
}
Because User, Entities, and the nested DTOs are all annotated with @embedded, they inherit the parent document lifecycle. No extra queries are required; reads and writes stay localized to the owning Tweet record.

Embed Lists for 1:n Data
For one-to-many data that never needs to be queried independently, the codebase relies on embedded lists. The package index example in examples/pub/lib/models/package.dart keeps dependency metadata alongside each package:

examples/pub/lib/models/package.dart

@collection
class Package {
  Package({
    required this.name,
    required this.version,
    required this.dependencies,
    required this.devDependencies,
    required this.published,
    required this.isLatest,
  });
  final String name;
  final String version;
  final bool isLatest;
  final List<Dependency> dependencies;      // @embedded
  final List<Dependency> devDependencies;   // @embedded
}
@embedded
class Dependency {
  Dependency({this.name = 'unknown', this.constraint = 'any'});
  final String name;
  final String constraint;
}
This pattern mirrors the analyzer rules—embedded classes cannot define indexes or their own IDs, but they can be stored in lists to represent repeated children inside a single parent document.

Manual References via IDs
When two records must point at each other without embedding (for example, a tweet replying to another tweet), the repository uses plain ID fields. The Twitter fixture exposes inReplyToStatusIdStr, quotedStatusIdStr, and similar properties on the Tweet class, letting you resolve related records with a query:

packages/isar_plus_test/lib/src/twitter/tweet.dart

class Tweet {
  // ...
  String? inReplyToStatusIdStr;  // points to another Tweet.idStr
  String? quotedStatusIdStr;     // same idea
  String? inReplyToUserIdStr;    // references an embedded User id
}
You can follow the same approach in your app: store the foreign key explicitly (int or String), create helper methods that run where().where().fieldEqualTo(...), and keep both updates inside a single write transaction to ensure referential consistency.

Migration Reference
Legacy IsarLink/IsarLinks code only lives in the Migrate from Isar v3 guide. That chapter walks through flattening every link into either an embedded structure or a manual ID field before copying your data into an Isar Plus database.

Last Update 12/18/2025Create, Read, Update, Delete
Master CRUD operations with Isar Plus

Copy Markdown
Open
Create, Read, Update, Delete
Learn how to manipulate your Isar collections with CRUD operations.

Opening Isar
Before you can do anything, you need an Isar instance. Each instance requires a directory with write permission.

main.dart

import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';
void main() async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = Isar.open(
    schemas: [RecipeSchema, UserSchema],
    directory: dir.path,
  );
}
You can open multiple instances with different names using the name parameter.

Configuration Options
Config	Description
name	Open multiple instances with distinct names. Default: "default"
directory	Storage location. Use Isar.sqliteInMemory for in-memory database
maxSizeMib	Maximum size in MiB. Default: 2048
relaxedDurability	Trade durability for performance
Default Config
Custom Config
In-Memory

final isar = Isar.open(schemas: [UserSchema]);
Create (Insert)
Create an Object

final user = User()
  ..name = 'Jane Doe'
  ..age = 28
  ..email = 'jane@example.com';
Insert with Write Transaction

await isar.writeAsync((isar) async {
  isar.users.put(user);
});
Use collection.autoIncrement() to get an auto-incrementing ID when creating objects.

Bulk Insert

final users = [
  User()..name = 'Alice'..age = 25,
  User()..name = 'Bob'..age = 30,
  User()..name = 'Charlie'..age = 35,
];
await isar.writeAsync((isar) async {
  isar.users.putAll(users);
});
Always use write transactions for data modifications!

Read (Query)
Get by ID

final user = await isar.users.get(1);
if (user != null) {
  print('Found: ${user.name}');
}
Get Multiple by IDs

final users = await isar.users.getAll([1, 2, 3]);
Get All

final allUsers = await isar.users.where().findAllAsync();
Find First

final firstUser = await isar.users.where().findFirstAsync();
Count

final count = await isar.users.countAsync();
print('Total users: $count');
Update
Update Object
Update Fields
Conditional Update

// Get the object
final user = await isar.users.get(1);
if (user != null) {
  // Modify it
  user.name = 'Updated Name';
  user.age = 30;
  
  // Save changes
  await isar.writeAsync((isar) async {
    isar.users.put(user);
  });
}
The put method acts as upsert - it inserts if the ID doesn't exist, updates if it does.

Delete
Delete by ID

await isar.writeAsync((isar) async {
  final success = isar.users.delete(1);
  print('Deleted: $success');
});
Delete Multiple by IDs

await isar.writeAsync((isar) async {
  final count = isar.users.deleteAll([1, 2, 3]);
  print('Deleted $count users');
});
Delete Object

await isar.writeAsync((isar) async {
  final user = await isar.users.get(1);
  if (user != null) {
    isar.users.delete(user.id);
  }
});
Delete All

await isar.writeAsync((isar) async {
  isar.users.clear();
});
Be careful with clear() - it deletes all records in the collection!

Delete with Filter

await isar.writeAsync((isar) async {
  final deletedCount = isar.users
    .where()
    .ageLessThan(18)
    .deleteAll();
  print('Deleted $deletedCount users');
});
Transactions
All write operations must be wrapped in a transaction:


await isar.writeAsync((isar) async {
  // Create
  final user = User()..name = 'Test';
  isar.users.put(user);
  
  // Update
  user.name = 'Updated';
  isar.users.put(user);
  
  // Delete
  isar.users.delete(user.id);
  
  // All operations are atomic
});
If an error occurs, all changes in the transaction are rolled back automatically.

Read Transactions
For better performance with multiple reads:


final results = await isar.readAsync((isar) async {
  final users = isar.users.where().findAll();
  final count = isar.users.count();
  return {'users': users, 'count': count};
});
Best Practices
Use Bulk Operations


// ✅ Good - Single transaction
await isar.writeAsync((isar) async {
  isar.users.putAll(manyUsers);
});
// ❌ Bad - Multiple transactions
for (var user in manyUsers) {
  await isar.writeAsync((isar) async {
    isar.users.put(user);
  });
}
Minimize Transaction Scope


// ✅ Good
final data = prepareData();
await isar.writeAsync((isar) async {
  isar.users.putAll(data);
});
// ❌ Bad
await isar.writeAsync((isar) async {
  final data = prepareData(); // Heavy operation in transaction
  isar.users.putAll(data);
});
Check Before Delete


await isar.writeAsync((isar) async {
  final exists = await isar.users.get(id) != null;
  if (exists) {
    isar.users.delete(id);
  }
});
Error Handling

try {
  await isar.writeAsync((isar) async {
    isar.users.put(user);
  });
} catch (e) {
  print('Error: $e');
  // Transaction is automatically rolled back
}
Next StepsQueries
Build powerful and efficient queries with Isar Plus

Copy Markdown
Open
Queries
Querying is how you find records that match certain conditions. Learn how to build powerful queries and optimize them with indexes.

Queries are executed on the database, not in Dart, making them incredibly fast!

Overview
There are two different methods of filtering your records. Both start with .where() but work differently under the hood:

Filters - Easy to use, work on any property (scans all records)
Where clauses - More powerful, require indexes (extremely fast)
The API is unified: you always start with .where(). If you use a condition on an indexed property, it automatically becomes a fast "Where clause". If you use a condition on a non-indexed property, it becomes a "Filter".

Filters
Filters evaluate an expression for every object in the collection. If the expression resolves to true, the object is included in the results.

Example Model

@collection
class Shoe {
  Id? id;
  int? size;
  late String model;
  late bool isUnisex;
}
Query Conditions
Equality
Comparison
Range
Null Check

// Find size 46 shoes
final result = await isar.shoes.where()
  .sizeEqualTo(46)
  .findAllAsync();
Available Conditions
Condition	Description
.equalTo(value)	Matches values equal to specified value
.between(lower, upper)	Matches values between lower and upper
.greaterThan(bound)	Matches values greater than bound
.lessThan(bound)	Matches values less than bound
.isNull()	Matches null values
.isNotNull()	Matches non-null values
.length()	Query based on list/string length
Logical Operators
Combine multiple conditions using logical operators:


// AND operator (implicit)
final result = await isar.shoes.where()
  .sizeEqualTo(46)
  .and() // Optional
  .isUnisexEqualTo(true)
  .findAllAsync();
// Equivalent to: size == 46 && isUnisex == true
AND
OR
NOT
GROUP

final result = await isar.shoes.where()
  .sizeEqualTo(46)
  .and()
  .isUnisexEqualTo(true)
  .findAllAsync();
String Conditions
Strings have additional powerful query conditions:


@collection
class Product {
  Id? id;
  late String name;
}
StartsWith
Contains
EndsWith
Matches

final products = await isar.products.where()
  .nameStartsWith('iPhone')
  .findAllAsync();
// Case insensitive
final products2 = await isar.products.where()
  .nameStartsWith('iphone', caseSensitive: false)
  .findAllAsync();
All string operations have an optional caseSensitive parameter that defaults to true.

Query Modifiers
Build dynamic queries based on conditions:

Optional Queries

Future<List<Shoe>> findShoes(int? sizeFilter) {
  return isar.shoes.where()
    .optional(
      sizeFilter != null,
      (q) => q.sizeEqualTo(sizeFilter!),
    )
    .findAllAsync();
}
AnyOf Modifier

// Find shoes with size 38, 40, or 42
final shoes = await isar.shoes.where()
  .anyOf(
    [38, 40, 42],
    (q, int size) => q.sizeEqualTo(size)
  )
  .findAllAsync();
// Equivalent to:
final shoes2 = await isar.shoes.where()
  .sizeEqualTo(38)
  .or()
  .sizeEqualTo(40)
  .or()
  .sizeEqualTo(42)
  .findAllAsync();
AllOf Modifier

final shoes = await isar.shoes.where()
  .allOf(
    ['Nike', 'Adidas'],
    (q, brand) => q.modelContains(brand)
  )
  .findAllAsync();
Advanced: Custom Queries
For complex scenarios where you need to build queries dynamically at runtime, you can use buildQuery. This is useful for creating custom query languages or dynamic filtering UIs.


// Manually construct a Filter
final filter = AndGroup([
  EqualCondition(property: 1, value: 46), // property 1 is 'size'
  GreaterCondition(property: 2, value: 100), // property 2 is 'price'
]);
final query = isar.shoes.buildQuery(
  filter: filter,
  sortBy: [
    SortProperty(property: 1, sort: Sort.desc), // Sort by size desc
  ],
);
final results = await query.findAllAsync();
Using buildQuery requires intimate knowledge of your schema's property indices. It is recommended to use the generated .where() API whenever possible.

List Queries
Query based on list properties:


@collection
class Tweet {
  Id? id;
  String? text;
  List<String> hashtags = [];
}
Length
Contains
Empty

// Tweets with many hashtags
final tweets = await isar.tweets.where()
  .hashtagsLengthGreaterThan(5)
  .findAllAsync();
Embedded Objects
Query nested embedded objects efficiently:


@collection
class Car {
  Id? id;
  Brand? brand;
}
@embedded
class Brand {
  String? name;
  String? country;
}

// Find BMW cars from Germany
final germanCars = await isar.cars.where()
  .brand((q) => q
    .nameEqualTo('BMW')
    .and()
    .countryEqualTo('Germany')
  )
  .findAllAsync();
Always group nested queries for better performance!

Link Queries
Query based on linked objects:


@collection
class Teacher {
  Id? id;
  late String subject;
}
@collection
class Student {
  Id? id;
  late String name;
  final teachers = IsarLinks<Teacher>();
}

// Find students with math or English teacher
final students = await isar.students.where()
  .teachers((q) => q
    .subjectEqualTo('Math')
    .or()
    .subjectEqualTo('English')
  )
  .findAllAsync();
// Query by link count
final studentsWithManyTeachers = await isar.students.where()
  .teachersLengthGreaterThan(3)
  .findAllAsync();
Link queries can be expensive. Consider using embedded objects for better performance.

Where Clauses
Where clauses use indexes for ultra-fast queries:


@collection
class Product {
  Id? id;
  
  @Index()
  late String name;
  
  @Index()
  late int price;
}

// Use index for fast query
final products = await isar.products
  .where()
  .nameEqualTo('iPhone')
  .findAllAsync();
// Combine with filters
final expensiveIPhones = await isar.products
  .where()
  .nameEqualTo('iPhone')
  .where()
  .priceGreaterThan(1000)
  .findAllAsync();
Where clauses are much faster than filters but require indexes.

Query Operations
Find Operations
findAll
findFirst
count
isEmpty

final allShoes = await isar.shoes
  .where()
  .sizeGreaterThan(40)
  .findAllAsync();
Delete Operations

// Delete matching objects
await isar.writeAsync((isar) async {
  final count = isar.shoes
    .where()
    .sizeLessThan(35)
    .deleteAll();
  print('Deleted $count shoes');
});
Sorting
Sort results by any property:


// Ascending
final sorted = await isar.shoes
  .where()
  .sortBySize()
  .findAllAsync();
// Descending
final sortedDesc = await isar.shoes
  .where()
  .sortBySizeDesc()
  .findAllAsync();
// Multiple sorts
final multiSort = await isar.shoes
  .where()
  .sortBySize()
  .thenByModel()
  .findAllAsync();
Sorting without indexes is expensive for large datasets. Use indexed where clauses for sorting when possible.

Limit & Offset

// Get first 10 results
final first10 = await isar.shoes
  .where()
  .limit(10)
  .findAllAsync();
// Skip first 20, get next 10
final paginated = await isar.shoes
  .where()
  .offset(20)
  .limit(10)
  .findAllAsync();
Distinct

// Get unique sizes
final uniqueSizes = await isar.shoes
  .where()
  .distinctBySize()
  .findAllAsync();
Best Practices
Use Where Clauses with Indexes


// ✅ Fast - uses index (price is indexed)
await isar.products.where().priceEqualTo(500).findAllAsync();
// ❌ Slow - scans all records (name is not indexed)
await isar.products.where().nameEqualTo('iPhone').findAllAsync();
Combine Where and Filter


// ✅ Optimal - index + filter
await isar.products
  .where()
  .nameEqualTo('iPhone')
  .where()
  .priceGreaterThan(500)
  .findAllAsync();
Group Nested Queries


// ✅ Efficient
.brand((q) => q.nameEqualTo('BMW').and().countryEqualTo('Germany'))
// ❌ Inefficient
.brand((q) => q.nameEqualTo('BMW'))
.and()
.brand((q) => q.countryEqualTo('Germany'))
Next Steps