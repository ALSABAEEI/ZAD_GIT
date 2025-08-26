import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class LoginEvent {}

class LoginEmailChanged extends LoginEvent {
  final String email;
  LoginEmailChanged(this.email);
}

class LoginPasswordChanged extends LoginEvent {
  final String password;
  LoginPasswordChanged(this.password);
}

class LoginSubmitted extends LoginEvent {}

// States
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String role;
  LoginSuccess(this.role);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  String email = '';
  String password = '';

  LoginBloc() : super(LoginInitial()) {
    on<LoginEmailChanged>((event, emit) => email = event.email);
    on<LoginPasswordChanged>((event, emit) => password = event.password);
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());
      try {
        final userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        if (!userDoc.exists) {
          emit(LoginError('User data not found.'));
          return;
        }
        final role = userDoc.data()?['role'] ?? '';
        emit(LoginSuccess(role));
      } on FirebaseAuthException catch (e) {
        emit(LoginError(e.message ?? 'Login failed'));
      } catch (e) {
        emit(LoginError('Login failed: ${e.toString()}'));
      }
    });
  }
}
