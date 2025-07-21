import '../../models/member.dart';

class AuthState {
  final Member? member;
  AuthState({
    this.member,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState && other.member == member;
  }

  @override
  int get hashCode => member.hashCode;
}

class AuthLoggedIn extends AuthState {
  final Member member;
  AuthLoggedIn(this.member) : super(member: member);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthLoggedIn && other.member == member;
  }

  @override
  int get hashCode => member.hashCode;
}

class AuthGuestLoggedIn extends AuthState {
  AuthGuestLoggedIn() : super(member: null);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthGuestLoggedIn;
  }

  @override
  int get hashCode => 0;
}

class AuthLoading extends AuthState {
  AuthLoading() : super(member: null);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthLoading;
  }

  @override
  int get hashCode => 0;
}
