class Progress {
  final int answered;
  final int total;

  const Progress(this.answered, this.total);

  double get ratio => total == 0 ? 0.0 : answered / total;
}
