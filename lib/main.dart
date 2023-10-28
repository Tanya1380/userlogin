import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class User {
  final String name;
  final String email;
  final String source;

  User(this.name, this.email, this.source);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Input(),
        '/list': (context) => ListScreen(),
      },
    );
  }
}

class Input extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<Input> {
  final TextEditingController nameC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  String source = 'Google';
  List<User> users = [];

  void addUser() {
    String name = nameC.text;
    String email = emailC.text;

    if (name.isNotEmpty && email.isNotEmpty) {
      User newUser = User(name, email, source);
      setState(() {
        users.add(newUser);
        nameC.clear();
        emailC.clear();
      });
    }
  }

  void navigateToListScreen() {
    Navigator.pushNamed(context, '/list', arguments: users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade400,
        title: const Text('Input Screen'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: nameC,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: emailC,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ),
          DropdownButton<String>(
            value: source,
            items: <String>['Facebook', 'Instagram', 'Organic', 'Friend', 'Google']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                source = newValue!;
              });
            },
          ),
          ElevatedButton(
            onPressed: () {
              addUser();
            },
            child: const Text('Add User'),
          ),
          ElevatedButton(
            onPressed: () {
              navigateToListScreen();
            },
            child: const Text('View User List'),
          ),
        ],
      ),
    );
  }
}

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<User> users = [];
  String filter = 'All';
  String search = '';

  void updateFilter(String newFilter) {
    setState(() {
      filter = newFilter;
    });
  }

  void updateSearch(String newSearch) {
    setState(() {
      search = newSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<User> userList = ModalRoute.of(context)!.settings.arguments as List<User>;

    if (userList != null) {
      users = userList;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade400,
        title: const Text('List Screen'),
        actions: [
          FilterDropdown(filter: filter, onFilterChange: updateFilter),
        ],
      ),
      body: Column(
        children: [
          SearchField(search: search, onSearchChange: updateSearch),
          Expanded(
            child: UserListView(users: users, filter: filter, search: search),
          ),
        ],
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String filter;
  final Function onFilterChange;

  FilterDropdown({required this.filter, required this.onFilterChange});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: filter,
      items: <String>['All', 'Facebook', 'Instagram', 'Organic', 'Friend', 'Google']
          .map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        onFilterChange(newValue!);
      },
    );
  }
}

class SearchField extends StatelessWidget {
  final String search;
  final Function onSearchChange;

  SearchField({required this.search, required this.onSearchChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
    child: TextField(
    onChanged: (text) {
    onSearchChange(text);
    },
    decoration: const InputDecoration(
    hintText: 'Search by Name or Email',
    ),
    ));
  }
}


class UserListView extends StatelessWidget {
  final List<User> users;
  final String filter;
  final String search;

  UserListView({required this.users, required this.filter, required this.search});

  List<User> getFilteredAndSearchedUsers() {
    return users.where((user) {
      return (filter == 'All' || user.source == filter) &&
          (search.isEmpty ||
              user.name.toLowerCase().contains(search.toLowerCase()) ||
              user.email.toLowerCase().contains(search.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = getFilteredAndSearchedUsers();

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text(user.email),
          trailing: Text(user.source),
        );
      },
    );
  }
}
