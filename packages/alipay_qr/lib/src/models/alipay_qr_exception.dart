class AlipayQrException implements Exception {
  final String message;
  final String? code;
  final String? subCode;
  final String? subMessage;

  const AlipayQrException(
    this.message, {
    this.code,
    this.subCode,
    this.subMessage,
  });

  @override
  String toString() {
    final details = [
      if (code != null) 'code=$code',
      if (subCode != null) 'subCode=$subCode',
      if (subMessage != null) 'subMessage=$subMessage',
    ];
    if (details.isEmpty) return message;
    return '$message (${details.join(', ')})';
  }
}
