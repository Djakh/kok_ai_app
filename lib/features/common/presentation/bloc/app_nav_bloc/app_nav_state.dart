class AppNavState {
  const AppNavState({this.index = 0});

  final int index;

  AppNavState copyWith({int? index}) => AppNavState(index: index ?? this.index);
}
