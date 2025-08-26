import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/charity_proposal_entity.dart';
import '../../domain/usecases/get_charity_programs_usecase.dart';
import '../../domain/usecases/delete_charity_proposal_usecase.dart';

// Events
abstract class CharityProgramsEvent extends Equatable {
  const CharityProgramsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCharityPrograms extends CharityProgramsEvent {
  final String charityId;

  const LoadCharityPrograms(this.charityId);

  @override
  List<Object?> get props => [charityId];
}

class DeleteCharityProgram extends CharityProgramsEvent {
  final String programId;

  const DeleteCharityProgram(this.programId);

  @override
  List<Object?> get props => [programId];
}

// States
abstract class CharityProgramsState extends Equatable {
  const CharityProgramsState();

  @override
  List<Object?> get props => [];
}

class CharityProgramsInitial extends CharityProgramsState {}

class CharityProgramsLoading extends CharityProgramsState {}

class CharityProgramsLoaded extends CharityProgramsState {
  final List<CharityProposalEntity> programs;

  const CharityProgramsLoaded(this.programs);

  @override
  List<Object?> get props => [programs];
}

class CharityProgramsError extends CharityProgramsState {
  final String message;

  const CharityProgramsError(this.message);

  @override
  List<Object?> get props => [message];
}

class CharityProgramsDeleting extends CharityProgramsState {
  final String programId;

  const CharityProgramsDeleting(this.programId);

  @override
  List<Object?> get props => [programId];
}

// BLoC
class CharityProgramsBloc
    extends Bloc<CharityProgramsEvent, CharityProgramsState> {
  final GetCharityProgramsUseCase getCharityProgramsUseCase;
  final DeleteCharityProposalUseCase deleteCharityProposalUseCase;

  CharityProgramsBloc({
    required this.getCharityProgramsUseCase,
    required this.deleteCharityProposalUseCase,
  }) : super(CharityProgramsInitial()) {
    on<LoadCharityPrograms>(_onLoadCharityPrograms);
    on<DeleteCharityProgram>(_onDeleteCharityProgram);
  }

  Future<void> _onLoadCharityPrograms(
    LoadCharityPrograms event,
    Emitter<CharityProgramsState> emit,
  ) async {
    emit(CharityProgramsLoading());
    try {
      final programs = await getCharityProgramsUseCase.execute(event.charityId);
      emit(CharityProgramsLoaded(programs));
    } catch (e) {
      emit(CharityProgramsError(e.toString()));
    }
  }

  Future<void> _onDeleteCharityProgram(
    DeleteCharityProgram event,
    Emitter<CharityProgramsState> emit,
  ) async {
    try {
      // Delete from database
      await deleteCharityProposalUseCase.execute(event.programId);

      // Update local state by removing the deleted program
      if (state is CharityProgramsLoaded) {
        final currentState = state as CharityProgramsLoaded;
        final updatedPrograms = currentState.programs
            .where((program) => program.id != event.programId)
            .toList();
        emit(CharityProgramsLoaded(updatedPrograms));
      }
    } catch (e) {
      emit(CharityProgramsError(e.toString()));
    }
  }
}
