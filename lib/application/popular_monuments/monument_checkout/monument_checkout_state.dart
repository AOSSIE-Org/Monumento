part of 'monument_checkout_bloc.dart';

sealed class MonumentCheckoutState extends Equatable {
  const MonumentCheckoutState();
  
  @override
  List<Object> get props => [];
}

final class MonumentCheckoutInitial extends MonumentCheckoutState {}

final class MonumentCheckoutLoading extends MonumentCheckoutState {}

final class MonumentCheckoutRequested extends MonumentCheckoutState {
  final MonumentEntity monument;

  const MonumentCheckoutRequested({required this.monument});

  @override
  List<Object> get props => [monument];
}

// This state is emitted only on a successful checkout action
final class MonumentCheckedOut extends MonumentCheckoutState {}

// This state is emitted during the initial load if monument is already checked out
final class MonumentAlreadyCheckedOut extends MonumentCheckoutState {}

final class MonumentNotCheckedOut extends MonumentCheckoutState {}

final class MonumentCheckoutFailure extends MonumentCheckoutState {
  final String message;
  
  const MonumentCheckoutFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}