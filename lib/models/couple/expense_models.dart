import 'package:dio/dio.dart';

class ExpensePaymentMethodOption {
  const ExpensePaymentMethodOption({required this.value, required this.label});

  final String value;
  final String label;
}

const List<ExpensePaymentMethodOption> expensePaymentMethodOptions =
    <ExpensePaymentMethodOption>[
      ExpensePaymentMethodOption(value: 'cash', label: 'Cash'),
      ExpensePaymentMethodOption(value: 'debit_card', label: 'Debit Card'),
      ExpensePaymentMethodOption(value: 'credit_card', label: 'Credit Card'),
      ExpensePaymentMethodOption(
        value: 'bank_transfer',
        label: 'Bank Transfer',
      ),
    ];

class ExpenseDraft {
  const ExpenseDraft({
    required this.budgetCategoryId,
    required this.expenseName,
    required this.amount,
    required this.datePaid,
    required this.description,
    required this.paymentMethod,
    this.receiptPath,
  });

  final dynamic budgetCategoryId;
  final String expenseName;
  final double amount;
  final DateTime datePaid;
  final String description;
  final String paymentMethod;
  final String? receiptPath;

  Map<String, dynamic> toMap() {
    return toMapWithPaymentMethod(includePaymentMethod: true);
  }

  Map<String, dynamic> toMapWithPaymentMethod({
    required bool includePaymentMethod,
  }) {
    final payload = <String, dynamic>{
      'budget_category_id': budgetCategoryId,
      'expense_name': expenseName,
      'amount': amount,
      'date_paid': _formatDate(datePaid),
      'description': description,
    };

    if (includePaymentMethod) {
      payload['payment_method'] = normalizeExpensePaymentMethod(paymentMethod);
    }

    return payload;
  }

  Future<FormData> toFormData({bool includePaymentMethod = true}) async {
    final payload = toMapWithPaymentMethod(
      includePaymentMethod: includePaymentMethod,
    );

    if (receiptPath != null && receiptPath!.trim().isNotEmpty) {
      payload['receipt'] = await MultipartFile.fromFile(
        receiptPath!,
        filename: _fileName(receiptPath!),
      );
    }

    return FormData.fromMap(payload);
  }

  ExpenseDraft copyWith({
    dynamic budgetCategoryId,
    String? expenseName,
    double? amount,
    DateTime? datePaid,
    String? description,
    String? paymentMethod,
    String? receiptPath,
  }) {
    return ExpenseDraft(
      budgetCategoryId: budgetCategoryId ?? this.budgetCategoryId,
      expenseName: expenseName ?? this.expenseName,
      amount: amount ?? this.amount,
      datePaid: datePaid ?? this.datePaid,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptPath: receiptPath ?? this.receiptPath,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _fileName(String path) {
    return path.split(RegExp(r'[\\/]+')).last;
  }
}

String normalizeExpensePaymentMethod(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(
    RegExp(r'[\s-]+'),
    '_',
  );

  switch (normalized) {
    case 'cash':
      return 'cash';
    case 'debit_card':
      return 'debit_card';
    case 'credit_card':
      return 'credit_card';
    case 'bank_transfer':
      return 'bank_transfer';
    default:
      return normalized;
  }
}

String displayExpensePaymentMethod(String value) {
  final normalized = normalizeExpensePaymentMethod(value);

  if (normalized.isEmpty) {
    return 'Manual Entry';
  }

  for (final option in expensePaymentMethodOptions) {
    if (option.value == normalized) {
      return option.label;
    }
  }

  return normalized;
}
