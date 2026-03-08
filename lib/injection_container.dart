import 'package:get_it/get_it.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_bloc.dart';
import 'package:kok_ai_app/features/social/data/services/social_post_draft_store.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_registration_draft_store.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<AppNavBloc>(() => AppNavBloc());
  sl.registerLazySingleton<TreeRegistrationDraftStore>(() => TreeRegistrationDraftStore());
  sl.registerLazySingleton<SocialPostDraftStore>(() => SocialPostDraftStore());
}
