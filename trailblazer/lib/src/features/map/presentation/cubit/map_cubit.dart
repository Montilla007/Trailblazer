import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_location.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit(this._getCurrentLocation) : super(const MapState());

  final GetCurrentLocation _getCurrentLocation;

  Future<void> loadCurrentLocation() async {
    emit(const MapState(status: MapStatus.loadingLocation));

    try {
      final location = await _getCurrentLocation();

      emit(MapState(
        status: MapStatus.ready,
        location: location,
      ));
    } catch (error) {
      emit(MapState(
        status: MapStatus.locationError,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}