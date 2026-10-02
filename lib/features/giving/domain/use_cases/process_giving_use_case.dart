import 'package:church_finance/features/giving/data/models/giving_model.dart';
import 'package:church_finance/features/giving/data/repositories/giving_repositories.dart';

class ProcessGivingUseCase {
  final GivingRepository _givingRepository;

  ProcessGivingUseCase(this._givingRepository);

  Future<GivingModel> execute({
    required double amount,
    required String category,
    String? memberName,
    String? phoneNumber,
    String? church,
    bool isRecurring = false,
  }) async {
    return await _givingRepository.processGiving(
      amount: amount,
      category: category,
      memberName: memberName,
      phoneNumber: phoneNumber,
      church: church,
      isRecurring: isRecurring,
    );
  }
}
