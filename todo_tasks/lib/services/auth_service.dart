import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:todo_tasks/constants.dart';
import 'package:todo_tasks/utils.dart';

abstract class IAuthService {
  Future<User> createUser({required String email, required String password});
  Future<Session> createEmailSession(
      {required String email, required String password});
  signInWithProvider({required OAuthProvider provider});
  signOut();
  Future<Preferences> getUserPreferences();
  updatePreferences({required String bio});
}

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthService extends ChangeNotifier implements IAuthService {
  Client client = Client();
  late final Account account;

  late User _currentUser;

  AuthStatus _status = AuthStatus.uninitialized;

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser.name;
  String? get email => _currentUser.email;
  String? get userid => _currentUser.$id;

  // Constructor
  AuthService() {
    init();
    loadUser();
  }

  // Initialize the Appwrite client
  init() {
    client
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned();
    account = Account(client);
  }

  loadUser() async {
    try {
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      printOnlyInDebug("auth error:$e");
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<User> createUser(
      {required String email, required String password}) async {
    notifyListeners();

    try {
      final user = await account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: 'New User');
      return user;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Session> createEmailSession(
      {required String email, required String password}) async {
    notifyListeners();

    try {
      final session = await account.createEmailPasswordSession(
          email: email, password: password);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  @override
  signInWithProvider({required OAuthProvider provider}) async {
    try {
      final session = await account.createOAuth2Session(provider: provider);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  @override
  signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Preferences> getUserPreferences() async {
    return await account.getPrefs();
  }

  @override
  updatePreferences({required String bio}) async {
    return account.updatePrefs(prefs: {'bio': bio});
  }
}
