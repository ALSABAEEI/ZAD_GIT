import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/usecases/get_requests_usecase.dart';
import '../../domain/usecases/get_requests_by_restaurant_usecase.dart';
import '../../domain/usecases/create_request_usecase.dart';
import '../../domain/usecases/update_request_status_usecase.dart';

// Events
abstract class RequestEvent {}

class LoadRequests extends RequestEvent {
  final String charityId;
  LoadRequests(this.charityId);
}

class LoadRequestsByRestaurant extends RequestEvent {
  final String restaurantId;
  LoadRequestsByRestaurant(this.restaurantId);
}

class CreateRequest extends RequestEvent {
  final RequestEntity request;
  CreateRequest(this.request);
}

class UpdateRequestStatus extends RequestEvent {
  final String requestId;
  final String status;
  UpdateRequestStatus(this.requestId, this.status);
}

// States
abstract class RequestState {}

class RequestInitial extends RequestState {}

class RequestLoading extends RequestState {}

class RequestsLoaded extends RequestState {
  final List<RequestEntity> requests;
  RequestsLoaded(this.requests);
}

class RequestCreated extends RequestState {
  final RequestEntity request;
  RequestCreated(this.request);
}

class RequestStatusUpdated extends RequestState {
  final String requestId;
  final String status;
  RequestStatusUpdated(this.requestId, this.status);
}

class RequestError extends RequestState {
  final String message;
  RequestError(this.message);
}

// BLoC
class RequestBloc extends Bloc<RequestEvent, RequestState> {
  final GetRequestsUseCase getRequestsUseCase;
  final GetRequestsByRestaurantUseCase getRequestsByRestaurantUseCase;
  final CreateRequestUseCase createRequestUseCase;
  final UpdateRequestStatusUseCase updateRequestStatusUseCase;

  RequestBloc({
    required this.getRequestsUseCase,
    required this.getRequestsByRestaurantUseCase,
    required this.createRequestUseCase,
    required this.updateRequestStatusUseCase,
  }) : super(RequestInitial()) {
    on<LoadRequests>(_onLoadRequests);
    on<LoadRequestsByRestaurant>(_onLoadRequestsByRestaurant);
    on<CreateRequest>(_onCreateRequest);
    on<UpdateRequestStatus>(_onUpdateRequestStatus);
  }

  Future<void> _onLoadRequests(
    LoadRequests event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());
    try {
      final requests = await getRequestsUseCase(event.charityId);
      emit(RequestsLoaded(requests));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }

  Future<void> _onLoadRequestsByRestaurant(
    LoadRequestsByRestaurant event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());
    try {
      final requests = await getRequestsByRestaurantUseCase(event.restaurantId);
      emit(RequestsLoaded(requests));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }

  Future<void> _onCreateRequest(
    CreateRequest event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());
    try {
      print('REQUEST BLOC: Creating request ${event.request.id}');
      await createRequestUseCase(event.request);
      print('REQUEST BLOC: Request created successfully');
      emit(RequestCreated(event.request));
      // After creation, emit a RequestsLoaded for the charity to refresh their list if listening
      try {
        final requests = await getRequestsUseCase(event.request.charityId);
        emit(RequestsLoaded(requests));
      } catch (_) {}
    } catch (e) {
      print('REQUEST BLOC: Error creating request: $e');
      emit(RequestError(e.toString()));
    }
  }

  Future<void> _onUpdateRequestStatus(
    UpdateRequestStatus event,
    Emitter<RequestState> emit,
  ) async {
    emit(RequestLoading());
    try {
      await updateRequestStatusUseCase(event.requestId, event.status);
      emit(RequestStatusUpdated(event.requestId, event.status));
    } catch (e) {
      emit(RequestError(e.toString()));
    }
  }
}
