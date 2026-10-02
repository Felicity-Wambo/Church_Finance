class ChurchBank {
  final String churchId;
  final String churchName;
  final String bankName;
  final String bankAccount;
  final String bankCode;
  final String branch;

  const ChurchBank({
    required this.churchId,
    required this.churchName,
    required this.bankName,
    required this.bankAccount,
    required this.bankCode,
    required this.branch,
  });
}

class ChurchBankConfig {
  static const List<ChurchBank> churches = [
    ChurchBank(
      churchId: 'church_1',
      churchName: 'Nairobi Central Church',
      bankName: 'KCB Bank',
      bankAccount: '0112345678901',
      bankCode: '011',
      branch: 'Nairobi CBD',
    ),
    ChurchBank(
      churchId: 'church_2',
      churchName: 'Kisumu Church',
      bankName: 'Equity Bank',
      bankAccount: '0123456789012',
      bankCode: '012',
      branch: 'Kisumu',
    ),
    ChurchBank(
      churchId: 'church_3',
      churchName: 'Mombasa Church',
      bankName: 'Cooperative Bank',
      bankAccount: '0134567890123',
      bankCode: '013',
      branch: 'Mombasa',
    ),
    ChurchBank(
      churchId: 'church_4',
      churchName: 'Eldoret Church',
      bankName: 'Absa Bank',
      bankAccount: '0145678901234',
      bankCode: '014',
      branch: 'Eldoret',
    ),
    ChurchBank(
      churchId: 'church_5',
      churchName: 'Kisii Church',
      bankName: 'NCBA',
      bankAccount: '0156789012345',
      bankCode: '015',
      branch: 'International',
    ),
  ];

  static ChurchBank? getChurchByName(String name) {
    try {
      return churches.firstWhere((church) => church.churchName == name);
    } catch (e) {
      return null;
    }
  }

  static ChurchBank? getChurchById(String id) {
    try {
      return churches.firstWhere((church) => church.churchId == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getChurchNames() {
    return churches.map((church) => church.churchName).toList();
  }
}