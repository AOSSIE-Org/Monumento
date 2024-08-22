part of 'monument_3d_model_bloc.dart';

sealed class MonumentModelState extends Equatable {
  const MonumentModelState();

  @override
  List<Object> get props => [];
}

class MonumentInitial extends MonumentModelState {
  @override
  List<Object> get props => [];
}

class LoadingMonumentModel extends MonumentModelState {
  @override
  List<Object> get props => [];
}

class LoadingMonumentModelSuccess extends MonumentModelState {
  final MonumentEntity monumentModel;

  const LoadingMonumentModelSuccess({required this.monumentModel});
  @override
  List<Object> get props => [];
}

class MonumentModelLoadFailed extends MonumentModelState {
  final String message;

  const MonumentModelLoadFailed({required this.message});
  @override
  List<Object> get props => [message];
}

