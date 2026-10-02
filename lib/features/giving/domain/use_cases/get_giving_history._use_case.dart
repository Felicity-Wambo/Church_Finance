import 'package:church_finance/features/giving/data/repositories/giving_repositories.dart';

import '../../data/models/giving_model.dart';

class GetGivingHistoryUseCase {
  final GivingRepository _repository;

  GetGivingHistoryUseCase(this._repository);

  Future<List<GivingModel>> execute() async {
    return _repository.getGivingHistory();
  }
}