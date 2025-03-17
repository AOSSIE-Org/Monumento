part of 'monument_checkout_bloc.dart';

sealed class MonumentCheckoutEvent extends Equatable {
  const MonumentCheckoutEvent();

  @override
  List<Object> get props => [];
}

final class RequestMonumentCheckout extends MonumentCheckoutEvent {
  final MonumentEntity monument;

  const RequestMonumentCheckout({required this.monument});

  @override
  List<Object> get props => [monument];
}

final class ConfirmMonumentCheckout extends MonumentCheckoutEvent {
  final MonumentEntity monument;

  const ConfirmMonumentCheckout({required this.monument});

  @override
  List<Object> get props => [monument];
}

final class CheckIfMonumentIsCheckedOut extends MonumentCheckoutEvent {
  final MonumentEntity monument;

  const CheckIfMonumentIsCheckedOut({required this.monument});

  @override
  List<Object> get props => [monument];
}