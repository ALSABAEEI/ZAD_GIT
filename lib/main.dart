import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Auth feature
import 'features/auth/data/datasources/wathq_remote_datasource.dart';
import 'features/auth/data/repositories/wathq_repository_impl.dart';
import 'features/auth/domain/usecases/validate_crn_usecase.dart';
import 'features/auth/presentation/bloc/registration_bloc.dart';
import 'features/auth/presentation/pages/registration_page.dart';

// Food feature
import 'features/food/data/repositories/food_repository_impl.dart';
import 'features/food/data/repositories/charity_proposal_repository_impl.dart';
import 'features/food/data/repositories/reservation_repository_impl.dart';
import 'features/food/data/repositories/request_repository_impl.dart';
import 'features/food/domain/usecases/get_food_items_usecase.dart';
import 'features/food/domain/usecases/get_food_items_with_restaurant_names_usecase.dart';
import 'features/food/domain/usecases/add_food_item_usecase.dart';
import 'features/food/domain/usecases/get_charity_proposals_usecase.dart';
import 'features/food/domain/usecases/add_charity_proposal_usecase.dart';
import 'features/food/domain/usecases/get_reservations_usecase.dart';
import 'features/food/domain/usecases/create_reservation_usecase.dart';
import 'features/food/domain/usecases/check_reservation_usecase.dart';
import 'features/food/domain/usecases/cancel_reservation_usecase.dart';
import 'features/food/domain/usecases/get_food_item_from_reservation_usecase.dart';
import 'features/food/domain/usecases/get_requests_usecase.dart';
import 'features/food/domain/usecases/get_requests_by_restaurant_usecase.dart';
import 'features/food/domain/usecases/create_request_usecase.dart';
import 'features/food/domain/usecases/update_request_status_usecase.dart';
import 'features/food/domain/usecases/get_restaurant_food_items_usecase.dart';
import 'features/food/domain/usecases/get_charity_programs_usecase.dart';
import 'features/food/domain/usecases/update_proposal_status_usecase.dart';
import 'features/food/domain/usecases/delete_charity_proposal_usecase.dart';
import 'features/food/domain/usecases/delete_food_item_usecase.dart';

// Chat feature
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/domain/usecases/create_chat_room_usecase.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';

// Chat feature
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/get_chat_rooms_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
import 'features/chat/domain/usecases/create_chat_room_usecase.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/food/presentation/bloc/food_bloc.dart';
import 'features/food/presentation/bloc/charity_proposal_bloc.dart';
import 'features/food/presentation/bloc/reservation_bloc.dart';
import 'features/food/presentation/bloc/request_bloc.dart';
import 'features/food/presentation/bloc/restaurant_food_bloc.dart';
import 'features/food/presentation/bloc/charity_programs_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e, stack) {
    print('Firebase init error: $e\n$stack');
    runApp(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Startup error, see console'))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Firebase
        RepositoryProvider<FirebaseFirestore>(
          create: (_) => FirebaseFirestore.instance,
        ),

        // Auth feature
        RepositoryProvider(create: (_) => WathqRemoteDatasource()),
        RepositoryProvider(
          create: (context) =>
              WathqRepositoryImpl(context.read<WathqRemoteDatasource>()),
        ),
        RepositoryProvider(
          create: (context) =>
              ValidateCrnUseCase(context.read<WathqRepositoryImpl>()),
        ),

        // Food feature
        RepositoryProvider(
          create: (context) =>
              FoodRepositoryImpl(context.read<FirebaseFirestore>()),
        ),
        RepositoryProvider(
          create: (context) =>
              CharityProposalRepositoryImpl(context.read<FirebaseFirestore>()),
        ),
        RepositoryProvider(create: (context) => ReservationRepositoryImpl()),
        RepositoryProvider(create: (context) => RequestRepositoryImpl()),
        RepositoryProvider(
          create: (context) =>
              GetFoodItemsUseCase(context.read<FoodRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) => GetFoodItemsWithRestaurantNamesUseCase(
            context.read<FoodRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              AddFoodItemUseCase(context.read<FoodRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) => GetCharityProposalsUseCase(
            context.read<CharityProposalRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => AddCharityProposalUseCase(
            context.read<CharityProposalRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              GetReservationsUseCase(context.read<ReservationRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) => CreateReservationUseCase(
            context.read<ReservationRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => CheckReservationUseCase(
            context.read<ReservationRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => CancelReservationUseCase(
            context.read<ReservationRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => GetFoodItemFromReservationUseCase(
            context.read<FoodRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              GetRequestsUseCase(context.read<RequestRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) => GetRequestsByRestaurantUseCase(
            context.read<RequestRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              CreateRequestUseCase(context.read<RequestRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) =>
              UpdateRequestStatusUseCase(context.read<RequestRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) =>
              GetRestaurantFoodItemsUseCase(context.read<FoodRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) => GetCharityProgramsUseCase(
            context.read<CharityProposalRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => UpdateProposalStatusUseCase(
            context.read<CharityProposalRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => DeleteCharityProposalUseCase(
            context.read<CharityProposalRepositoryImpl>(),
          ),
        ),
        RepositoryProvider(
          create: (context) =>
              DeleteFoodItemUseCase(context.read<FoodRepositoryImpl>()),
        ),
        // Chat feature
        RepositoryProvider(
          create: (context) =>
              ChatRepositoryImpl(context.read<FirebaseFirestore>()),
        ),
        RepositoryProvider(
          create: (context) =>
              GetChatRoomsUseCase(context.read<ChatRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) =>
              SendMessageUseCase(context.read<ChatRepositoryImpl>()),
        ),
        RepositoryProvider(
          create: (context) =>
              CreateChatRoomUseCase(context.read<ChatRepositoryImpl>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Auth BLoC
          BlocProvider(
            create: (context) =>
                RegistrationBloc(context.read<ValidateCrnUseCase>()),
          ),

          // Food BLoCs
          BlocProvider(
            create: (context) => FoodBloc(
              getFoodItemsUseCase: context.read<GetFoodItemsUseCase>(),
              getFoodItemsWithRestaurantNamesUseCase: context
                  .read<GetFoodItemsWithRestaurantNamesUseCase>(),
              addFoodItemUseCase: context.read<AddFoodItemUseCase>(),
            ),
          ),
          BlocProvider(
            create: (context) => CharityProposalBloc(
              getCharityProposalsUseCase: context
                  .read<GetCharityProposalsUseCase>(),
              addCharityProposalUseCase: context
                  .read<AddCharityProposalUseCase>(),
            ),
          ),
          BlocProvider(
            create: (context) => ReservationBloc(
              getReservationsUseCase: context.read<GetReservationsUseCase>(),
              createReservationUseCase: context
                  .read<CreateReservationUseCase>(),
              checkReservationUseCase: context.read<CheckReservationUseCase>(),
              cancelReservationUseCase: context
                  .read<CancelReservationUseCase>(),
            ),
          ),
          BlocProvider(
            create: (context) => RequestBloc(
              getRequestsUseCase: context.read<GetRequestsUseCase>(),
              getRequestsByRestaurantUseCase: context
                  .read<GetRequestsByRestaurantUseCase>(),
              createRequestUseCase: context.read<CreateRequestUseCase>(),
              updateRequestStatusUseCase: context
                  .read<UpdateRequestStatusUseCase>(),
            ),
          ),
          BlocProvider(
            create: (context) => RestaurantFoodBloc(
              getRestaurantFoodItemsUseCase: context
                  .read<GetRestaurantFoodItemsUseCase>(),
              deleteFoodItemUseCase: context.read<DeleteFoodItemUseCase>(),
            ),
          ),
          BlocProvider(
            create: (context) => CharityProgramsBloc(
              getCharityProgramsUseCase: context
                  .read<GetCharityProgramsUseCase>(),
              deleteCharityProposalUseCase: context
                  .read<DeleteCharityProposalUseCase>(),
            ),
          ),
          // Chat BLoC
          BlocProvider(
            create: (context) => ChatBloc(
              getChatRoomsUseCase: context.read<GetChatRoomsUseCase>(),
              sendMessageUseCase: context.read<SendMessageUseCase>(),
              createChatRoomUseCase: context.read<CreateChatRoomUseCase>(),
              chatRepository: context.read<ChatRepositoryImpl>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'ZAD: Food Redistribution Management System',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 203, 113, 28),
            ),
          ),
          home: const RegistrationPage(),
        ),
      ),
    );
  }
}
