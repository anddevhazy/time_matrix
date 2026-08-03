import 'failures.dart';

/// Maps caught exceptions to a domain [Failure], keeping user-facing
/// error copy centralized instead of scattered across data sources.
class FailureMapper {
  const FailureMapper._();

  static Failure fromException(Object error) {
    if (error is FormatException) {
      return const CacheFailure('Stored task data is corrupted.');
    }
    return UnexpectedFailure(error.toString());
  }
}
