import 'package:get/get.dart';

class MainShellController extends GetxController {
  final currentIndex = 0.obs;
  final Set<int> _visited = {0};

  bool hasVisited(int index) => _visited.contains(index);

  void goTo(int index) {
    _visited.add(index);
    currentIndex.value = index;
  }
}
