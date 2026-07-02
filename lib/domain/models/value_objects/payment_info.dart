import 'package:flutter/foundation.dart';

/// Transacción de pago individual.
class PaymentTransaction {
  final String transactionId;
  final String provider;
  final double amount;
  final String currency;
  final String status;
  final DateTime transactionDate;

  const PaymentTransaction({
    required this.transactionId,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.status,
    required this.transactionDate,
  });
}

/// Información completa de pago de una reserva.
@immutable
class PaymentInfo {
  final String paymentId;
  final String invoiceNumber;
  final String status; // pending | paid | failed
  final List<PaymentTransaction> transactions;

  const PaymentInfo({
    required this.paymentId,
    required this.invoiceNumber,
    required this.status,
    required this.transactions,
  });

  @override
  bool operator ==(Object other) =>
      other is PaymentInfo && paymentId == other.paymentId;

  @override
  int get hashCode => paymentId.hashCode;
}
