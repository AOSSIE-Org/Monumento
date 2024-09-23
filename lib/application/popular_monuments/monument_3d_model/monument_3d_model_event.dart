part of 'monument_3d_model_bloc.dart';

sealed class MonumentModelEvent extends Equatable {
  const MonumentModelEvent();

  @override
  List<Object?> get props => [];
}

class ViewMonument3DModel extends MonumentModelEvent {
  final String monumentName;

  const ViewMonument3DModel({required this.monumentName});

  @override
  List<Object?> get props => [monumentName];
  
}
