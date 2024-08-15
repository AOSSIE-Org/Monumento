part of 'monument_checkin_bloc.dart';

sealed class MonumentCheckinState extends Equatable {
  const MonumentCheckinState();

  @override
  List<Object> get props => [];
}

final class MonumentCheckinInitial extends MonumentCheckinState {}

final class MonumentCheckinLoading extends MonumentCheckinState {}

final class MonumentCheckinSuccess extends MonumentCheckinState {}

final class MonumentCheckinFailure extends MonumentCheckinState {
  final String message;

  const MonumentCheckinFailure({required this.message});

  @override
  List<Object> get props => [message];
}

final class MonumentCheckedIn extends MonumentCheckinState {}

final class MonumentNotCheckedIn extends MonumentCheckinState {}
