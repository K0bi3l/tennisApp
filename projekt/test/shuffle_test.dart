import 'package:flutter_test/flutter_test.dart';
import 'package:projekt/users_list_shuffler.dart';

void main() {
  test('test pojedynczego shufflowania zawodników w turnieju', () {
    UsersListShuffler shuffler = UsersListShuffler();

    List<(String, String)> users = [
      ('John', 'John'),
      ('Mary', 'Mary'),
      ('Michael', 'Michael'),
      ('Tomasz', 'Tomasz')
    ];
    List<(String, String)> newUsers = List.from(users);

    shuffler.shuffle(newUsers);

    expect(newUsers.first == users.first, isFalse);
  });

  test('test całego koła shufflowania', () {
    UsersListShuffler shuffler = UsersListShuffler();
    List<(String, String)> users = [
      ('John', 'John'),
      ('Mary', 'Mary'),
      ('Michael', 'Michael'),
      ('Tomasz', 'Tomasz')
    ];
    List<(String, String)> newUsers = List.from(users);
    bool flag = true;
    for (int i = 0; i < users.length - 1; i++) {
      shuffler.shuffle(newUsers);
    }

    for (int i = 0; i < users.length; i++) {
      if (newUsers[i] != users[i]) {
        flag = false;
        break;
      }
    }

    expect(flag, true);
  });
}
