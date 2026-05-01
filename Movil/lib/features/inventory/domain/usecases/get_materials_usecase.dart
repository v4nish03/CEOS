class GetMaterialsUseCase {
  final InventoryRepository _repository;
  GetMaterialsUseCase(this._repository);

  Future<List<MaterialEntity>> execute() async {
    return await _repository.getMateriales();
  }
}