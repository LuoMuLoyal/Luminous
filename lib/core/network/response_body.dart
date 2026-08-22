/// Extracts a non-null payload from a generated-client response.
///
/// Generated API methods expose the endpoint resource directly in
/// `Response.data`; this guard keeps an absent response body descriptive.
T requireData<T>(T? data, {String? operation}) {
  if (data == null) {
    final context = operation == null ? '' : '（$operation）';
    throw StateError('API 返回空响应体$context');
  }
  return data;
}
