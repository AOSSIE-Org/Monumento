import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monumento/domain/entities/monument_entity.dart';
import 'package:monumento/domain/repositories/monument_repository.dart';

part 'monument_3d_model_event.dart';
part 'monument_3d_model_state.dart';

class Monument3dModelBloc extends Bloc<MonumentModelEvent, MonumentModelState> {
  final MonumentRepository _monumentRepository;
  Monument3dModelBloc(this._monumentRepository) : super(MonumentInitial()) {
    on<ViewMonument3DModel>(_mapViewMonument3DModelToState);
  }

  _mapViewMonument3DModelToState(
      ViewMonument3DModel event, Emitter<MonumentModelState> emit) async {
    try {
      emit(LoadingMonumentModel());
      final monumentModel = await _monumentRepository.getMonumentModelByName(
          monumentName: event.monumentName);
      emit(LoadingMonumentModelSuccess(monumentModel: monumentModel!.toEntity()));
    } catch (e) {
      emit(MonumentModelLoadFailed(message: e.toString()));
    }
  }
}
