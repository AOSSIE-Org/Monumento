part of 'monument_checkin_bloc.dart';

sealed class MonumentCheckinEvent extends Equatable {
  const MonumentCheckinEvent();

  @override
  List<Object> get props => [];
}

final class CheckinMonument extends MonumentCheckinEvent {
  final MonumentEntity monument;

  const CheckinMonument({required this.monument});

  @override
  List<Object> get props => [monument];
}

final class CheckIfMonumentIsCheckedIn extends MonumentCheckinEvent {
  final MonumentEntity monument;

  const CheckIfMonumentIsCheckedIn({required this.monument});

  @override
  List<Object> get props => [monument];
}
