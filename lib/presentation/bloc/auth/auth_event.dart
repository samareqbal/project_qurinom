part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email, password, role;
  const LoginRequested(this.email, this.password, this.role);
  @override
  List<Object?> get props => [email, password, role];
}

class LogoutRequested extends AuthEvent {}
