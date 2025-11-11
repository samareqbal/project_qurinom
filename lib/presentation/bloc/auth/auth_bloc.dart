import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;
  AuthBloc(this.repo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final resp = await repo.login(e.email, e.password, e.role);
      print(resp);
      emit(AuthSuccess(resp));
    } catch (ex) {
      emit(AuthFailure(ex.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    await repo.logout();
    emit(AuthLoggedOut());
  }
}
