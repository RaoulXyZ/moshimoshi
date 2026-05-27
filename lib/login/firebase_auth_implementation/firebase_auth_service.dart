import '../../utility/local_user.dart';

class _StubUser {
  _StubUser(this.uid);
  final String uid;
}

typedef AuthResult = ({_StubUser? user, String? error});

class FirebaseAuthService {
  Future<AuthResult> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final uid = LocalUser.ensureUid();

    return (user: _StubUser(uid), error: null);
  }

  Future<AuthResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final uid = LocalUser.ensureUid();

    return (user: _StubUser(uid), error: null);
  }
}
