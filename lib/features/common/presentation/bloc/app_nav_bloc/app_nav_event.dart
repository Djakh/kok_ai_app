abstract class AppNavEvent {
  const AppNavEvent();
}

class AppNavIndexChanged extends AppNavEvent {
  const AppNavIndexChanged({required this.index});

  final int index;
}
