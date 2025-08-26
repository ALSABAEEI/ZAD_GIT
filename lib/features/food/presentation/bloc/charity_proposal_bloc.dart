import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_charity_proposals_usecase.dart';
import '../../domain/usecases/add_charity_proposal_usecase.dart';
import '../../domain/entities/charity_proposal_entity.dart';

// Events
abstract class CharityProposalEvent {}

class LoadCharityProposals extends CharityProposalEvent {}

class AddCharityProposal extends CharityProposalEvent {
  final CharityProposalEntity proposal;
  AddCharityProposal(this.proposal);
}

// States
abstract class CharityProposalState {}

class CharityProposalInitial extends CharityProposalState {}

class CharityProposalLoading extends CharityProposalState {}

class CharityProposalLoaded extends CharityProposalState {
  final List<CharityProposalEntity> proposals;
  CharityProposalLoaded(this.proposals);
}

class CharityProposalError extends CharityProposalState {
  final String message;
  CharityProposalError(this.message);
}

class CharityProposalAdded extends CharityProposalState {}

class CharityProposalBloc
    extends Bloc<CharityProposalEvent, CharityProposalState> {
  final GetCharityProposalsUseCase getCharityProposalsUseCase;
  final AddCharityProposalUseCase addCharityProposalUseCase;

  CharityProposalBloc({
    required this.getCharityProposalsUseCase,
    required this.addCharityProposalUseCase,
  }) : super(CharityProposalInitial()) {
    on<LoadCharityProposals>(_onLoadCharityProposals);
    on<AddCharityProposal>(_onAddCharityProposal);
  }

  Future<void> _onLoadCharityProposals(
    LoadCharityProposals event,
    Emitter<CharityProposalState> emit,
  ) async {
    emit(CharityProposalLoading());
    try {
      final proposals = await getCharityProposalsUseCase();
      emit(CharityProposalLoaded(proposals));
    } catch (e) {
      emit(CharityProposalError(e.toString()));
    }
  }

  Future<void> _onAddCharityProposal(
    AddCharityProposal event,
    Emitter<CharityProposalState> emit,
  ) async {
    try {
      await addCharityProposalUseCase(event.proposal);
      emit(CharityProposalAdded());
      // Reload proposals after adding
      add(LoadCharityProposals());
    } catch (e) {
      emit(CharityProposalError(e.toString()));
    }
  }
}
