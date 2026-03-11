import 'package:get_it/get_it.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/features/auth/data/services/auth_api_service.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_bloc.dart';
import 'package:kok_ai_app/features/profile/data/services/profile_api_service.dart';
import 'package:kok_ai_app/features/social/data/services/social_api_service.dart';
import 'package:kok_ai_app/features/social/data/services/social_post_draft_store.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_api_service.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_registration_draft_store.dart';
import 'package:kok_ai_app/features/upload/data/services/upload_api_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<AppNavBloc>(() => AppNavBloc());
  sl.registerLazySingleton<AuthTokenStore>(() => AuthTokenStore());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(tokenStore: sl()));
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiClient: sl(), tokenStore: sl()),
  );
  sl.registerLazySingleton<ProfileApiService>(
    () => ProfileApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<UploadApiService>(
    () => UploadApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<TreeApiService>(
    () => TreeApiService(apiClient: sl(), uploadApiService: sl()),
  );
  sl.registerLazySingleton<SocialApiService>(
    () => SocialApiService(apiClient: sl(), uploadApiService: sl()),
  );
  sl.registerLazySingleton<TreeRegistrationDraftStore>(
    () => TreeRegistrationDraftStore(),
  );
  sl.registerLazySingleton<SocialPostDraftStore>(() => SocialPostDraftStore());
}
