class TreeRegisterResult {
  const TreeRegisterResult({required this.treeId});

  final String treeId;

  factory TreeRegisterResult.fromJson(Map<String, dynamic> json) =>
      TreeRegisterResult(treeId: '${json['id'] ?? json['tree_id'] ?? ''}');
}
