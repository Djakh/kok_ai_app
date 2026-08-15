import 'package:get_it/get_it.dart';
import 'package:kok_ai_app/core/network/api_client.dart';
import 'package:kok_ai_app/core/network/auth_token_store.dart';
import 'package:kok_ai_app/core/network/system_api_service.dart';
import 'package:kok_ai_app/features/auth/data/services/auth_api_service.dart';
import 'package:kok_ai_app/features/common/presentation/bloc/app_nav_bloc/app_nav_bloc.dart';
import 'package:kok_ai_app/features/notifications/data/services/notification_api_service.dart';
import 'package:kok_ai_app/features/profile/data/services/profile_api_service.dart';
import 'package:kok_ai_app/features/social/data/services/social_api_service.dart';
import 'package:kok_ai_app/features/social/data/services/social_post_draft_store.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_api_service.dart';
import 'package:kok_ai_app/features/tree/data/services/tree_registration_draft_store.dart';
import 'package:kok_ai_app/features/upload/data/services/upload_api_service.dart';
import 'package:kok_ai_app/features/user/data/services/user_api_service.dart';
import 'package:kok_ai_app/core/network/api_config.dart';
import 'package:kok_ai_app/features/tree_registration/data/repositories/api_tree_repository.dart';
import 'package:kok_ai_app/features/tree_registration/data/repositories/fixture_tree_repository.dart';
import 'package:kok_ai_app/features/tree_registration/data/services/registration_draft_persistence.dart';
import 'package:kok_ai_app/features/tree_registration/domain/repositories/tree_repository.dart';
import 'package:kok_ai_app/features/tree_registration/presentation/controller/tree_registration_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<AppNavBloc>(() => AppNavBloc());
  sl.registerLazySingleton<AuthTokenStore>(() => AuthTokenStore());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(tokenStore: sl()));
  sl.registerLazySingleton<SystemApiService>(
    () => SystemApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiClient: sl(), tokenStore: sl()),
  );
  sl.registerLazySingleton<UserApiService>(
    () => UserApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<ProfileApiService>(
    () => ProfileApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<NotificationApiService>(
    () => NotificationApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<UploadApiService>(
    () => UploadApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<TreeApiService>(
    () => TreeApiService(apiClient: sl()),
  );
  sl.registerLazySingleton<SocialApiService>(
    () => SocialApiService(apiClient: sl(), uploadApiService: sl()),
  );
  sl.registerLazySingleton<TreeRegistrationDraftStore>(
    () => TreeRegistrationDraftStore(),
  );
  sl.registerLazySingleton<SocialPostDraftStore>(() => SocialPostDraftStore());
  sl.registerLazySingleton<RegistrationDraftPersistence>(
    RegistrationDraftPersistence.new,
  );
  sl.registerLazySingleton<TreeRepository>(
    () => ApiConfig.useFixtures
        ? FixtureTreeRepository()
        : ApiTreeRepository(apiClient: sl()),
  );
  sl.registerFactory<TreeRegistrationCubit>(
    () => TreeRegistrationCubit(repository: sl(), persistence: sl()),
  );
}
