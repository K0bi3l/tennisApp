class UsersListShuffler {
  void shuffle(List<(String, String)> users) {
    (String, String) helper1;
    (String, String) helper2;
    helper1 = users[users.length - 2];
    for (int i = users.length - 3; i >= 0; i--) {
      helper2 = helper1;
      helper1 = users[i];
      users[i] = helper2;
    }
    users[users.length - 2] = helper1;
  }
}
