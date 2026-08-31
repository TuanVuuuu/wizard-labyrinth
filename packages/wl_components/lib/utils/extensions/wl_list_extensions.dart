extension WLListX<T> on List<T> {
  T? tryGet(int index) =>
      (index < 0 || index >= length) ? null : this[index];

  List<T> addBetween(T separator) {
    if (length <= 1) return this;
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

extension WLStringListX on Iterable<String?> {
  String? firstNonEmpty() {
    for (final value in this) {
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }
}
