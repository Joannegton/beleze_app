sealed class Result<F, S> {
  const Result();

  bool get isSuccess => this is Success<F, S>;
  bool get isFailure => this is Err<F, S>;

  S get value => (this as Success<F, S>).data;
  F get error => (this as Err<F, S>).failure;

  T fold<T>(T Function(F failure) onFailure, T Function(S success) onSuccess) {
    return switch (this) {
      Success<F, S> s => onSuccess(s.data),
      Err<F, S> f => onFailure(f.failure),
    };
  }
}

final class Success<F, S> extends Result<F, S> {
  final S data;
  const Success(this.data);
}

final class Err<F, S> extends Result<F, S> {
  final F failure;
  const Err(this.failure);
}

Result<F, S> ok<F, S>(S data) => Success(data);
Result<F, S> err<F, S>(F failure) => Err(failure);
