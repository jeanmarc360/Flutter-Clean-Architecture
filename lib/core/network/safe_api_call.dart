import '../error/exception_mapper.dart';
import '../error/result.dart';

Future<Result<T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } catch (e) {
    return Err(ExceptionMapper.map(e));
  }
}
