import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_event.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_state.dart';

class AppNavBloc extends Bloc<AppNavEvent, AppNavState> {
  AppNavBloc() : super(const AppNavState()) {
    on<AppNavIndexChanged>(onAppNavIndexChanged);
  }

  Future<void> onAppNavIndexChanged(AppNavIndexChanged event, Emitter<AppNavState> emit) async {
    emit(state.copyWith(index: event.index));
  }
}
