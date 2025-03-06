import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/domain/repositories/social_repository.dart';

part 'monument_checkout_event.dart';
part 'monument_checkout_state.dart';


class MonumentCheckoutBloc 
    extends Bloc<MonumentCheckoutEvent, MonumentCheckoutState> {
  final SocialRepository _socialRepository;
  
  MonumentCheckoutBloc(this._socialRepository)
      : super(MonumentCheckoutInitial()) {
    on<RequestMonumentCheckout>(_onRequestCheckout);
    on<ConfirmMonumentCheckout>(_onConfirmCheckout);
    on<CheckIfMonumentIsCheckedOut>(_onCheckCheckoutStatus);
  }

  Future<void> _onRequestCheckout(
    RequestMonumentCheckout event, 
    Emitter<MonumentCheckoutState> emit
  ) async {
    try {
      // Check if the monument is currently checked in
      bool isCheckedIn = await _socialRepository.checkInStatus(
        monumentId: event.monument.id
      );

      if (!isCheckedIn) {
        emit(MonumentCheckoutFailure(
          message: "You are not checked in to this monument"
        ));
        return;
      }

      // Emit a state indicating checkout is ready to be confirmed
      emit(MonumentCheckoutRequested(monument: event.monument));
    } catch (e) {
      emit(MonumentCheckoutFailure(message: e.toString()));
    }
  }

  Future<void> _onConfirmCheckout(
    ConfirmMonumentCheckout event, 
    Emitter<MonumentCheckoutState> emit
  ) async {
    try {
      emit(MonumentCheckoutLoading());

      // Perform checkout
      bool checkoutSuccess = await _socialRepository.monumentCheckOut(
        monumentId: event.monument.id
      );

      if (checkoutSuccess) {
        // This state will only be emitted after a new successful checkout action
        emit(MonumentCheckedOut());
      } else {
        emit(MonumentCheckoutFailure(
          message: "Failed to check out of the monument"
        ));
      }
    } catch (e) {
      emit(MonumentCheckoutFailure(message: e.toString()));
    }
  }

  Future<void> _onCheckCheckoutStatus(
    CheckIfMonumentIsCheckedOut event, 
    Emitter<MonumentCheckoutState> emit
  ) async {
    try {
      emit(MonumentCheckoutLoading());

      // Check checkout status 
      bool isCheckedIn = await _socialRepository.checkInStatus(
        monumentId: event.monument.id
      );

      if (isCheckedIn) {
        emit(MonumentNotCheckedOut());
      } else {
        // Use a different state for monuments already checked out
        // versus monuments that were just checked out by user action
        emit(MonumentAlreadyCheckedOut());
      }
    } catch (e) {
      emit(MonumentCheckoutFailure(message: e.toString()));
    }
  }
}