import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/validate_crn_usecase.dart';
import '../../domain/entities/cr_info_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class RegistrationEvent {}

class EmailChanged extends RegistrationEvent {
  final String email;
  EmailChanged(this.email);
}

class PasswordChanged extends RegistrationEvent {
  final String password;
  PasswordChanged(this.password);
}

class RoleChanged extends RegistrationEvent {
  final String role;
  RoleChanged(this.role);
}

class CrnChanged extends RegistrationEvent {
  final String crn;
  CrnChanged(this.crn);
}

class TermsAcceptedChanged extends RegistrationEvent {
  final bool accepted;
  TermsAcceptedChanged(this.accepted);
}

class SubmitRegistration extends RegistrationEvent {}

class CheckEligibility extends RegistrationEvent {}

// States
abstract class RegistrationState {}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class RegistrationSuccess extends RegistrationState {}

class RegistrationError extends RegistrationState {
  final String message;
  RegistrationError(this.message);
}

class RegistrationCrnValidated extends RegistrationState {
  final CrInfoEntity info;
  final String status;
  RegistrationCrnValidated(this.info, this.status);
}

class RegistrationEligibilityChecked extends RegistrationState {
  final bool eligible;
  final String message;
  RegistrationEligibilityChecked(this.eligible, this.message);
}

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final ValidateCrnUseCase validateCrnUseCase;

  String email = '';
  String password = '';
  String role = '';
  String crn = '';

  RegistrationBloc(this.validateCrnUseCase) : super(RegistrationInitial()) {
    on<EmailChanged>((event, emit) {
      email = event.email;
      emit(RegistrationInitial());
    });
    on<PasswordChanged>((event, emit) {
      password = event.password;
      emit(RegistrationInitial());
    });
    on<RoleChanged>((event, emit) {
      role = event.role;
      emit(RegistrationInitial());
    });
    on<CrnChanged>((event, emit) {
      crn = event.crn;
      emit(RegistrationInitial());
    });
    on<CheckEligibility>((event, emit) async {
      emit(RegistrationLoading());
      if (crn.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(crn)) {
        emit(
          RegistrationEligibilityChecked(
            false,
            'The national number must be exactly 10 digits.',
          ),
        );
        return;
      }
      try {
        final (info, status) = await validateCrnUseCase(crn, role: role);
        emit(
          RegistrationEligibilityChecked(
            true,
            'Eligible for registration as ' +
                (role == 'Organization' ? 'charity' : 'restaurant'),
          ),
        );
      } catch (e) {
        emit(
          RegistrationEligibilityChecked(
            false,
            e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    });
    on<SubmitRegistration>((event, emit) async {
      emit(RegistrationLoading());
      // Check for duplicate CRN
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('crn', isEqualTo: crn)
          .get();
      if (existing.docs.isNotEmpty) {
        emit(
          RegistrationError(
            'An account with this commercial registration number already exists.',
          ),
        );
        return;
      }
      // Validate CRN input before API call
      if (crn.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(crn)) {
        emit(
          RegistrationError('The national number must be exactly 10 digits.'),
        );
        return;
      }
      try {
        final (info, status) = await validateCrnUseCase(crn, role: role);
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
                'email': email,
                'password': password, // Save password
                'role': role,
                'crn': crn,
                'name': info.name, // Save organization/restaurant name
              });
          print(
            'Firestore write successful for user: ${userCredential.user!.uid}',
          );
          emit(RegistrationSuccess());
        } catch (firestoreError) {
          print('Firestore error: ${firestoreError.toString()}');
          emit(
            RegistrationError('Firestore error: ${firestoreError.toString()}'),
          );
        }
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException: code=${e.code}, message=${e.message}');
        emit(RegistrationError('Firebase error: ${e.code} - ${e.message}'));
      } on Exception catch (e) {
        print('Registration error: ${e.toString()}');
        emit(RegistrationError(e.toString().replaceFirst('Exception: ', '')));
      } catch (e) {
        print('Unknown registration error: ${e.toString()}');
        emit(RegistrationError('Unknown error: ${e.toString()}'));
      }
    });
  }
}
