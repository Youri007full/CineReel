import 'dart:async';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:transparent_image/transparent_image.dart';

class MyHttpOverrides extends HttpOverrides {
  // Returns a mock HTTP client that responds with an image to all requests.
  @override
  HttpClient createHttpClient(SecurityContext context) {
    final MockHttpClient client = new MockHttpClient();
    final MockHttpClientRequest request = new MockHttpClientRequest();
    final MockHttpClientResponse response = new MockHttpClientResponse();
    final MockHttpHeaders headers = new MockHttpHeaders();

    when(client.getUrl(any)).thenAnswer((_) => new Future<HttpClientRequest>.value(request));

    when(request.headers).thenReturn(headers);

    when(request.close()).thenAnswer((_) => new Future<HttpClientResponse>.value(response));

    when(response.contentLength).thenReturn(kTransparentImage.length);

    when(response.statusCode).thenReturn(HttpStatus.OK);

    when(response.listen(any)).thenAnswer((Invocation invocation) {
      final void Function(List<int>) onData = invocation.positionalArguments[0];
      final void Function() onDone = invocation.namedArguments[#onDone];
      final void Function(Object, [StackTrace]) onError = invocation.namedArguments[#onError];
      final bool cancelOnError = invocation.namedArguments[#cancelOnError];
      return new Stream<List<int>>.fromIterable(<List<int>>[kTransparentImage])
          .listen(onData, onDone: onDone, onError: onError, cancelOnError: cancelOnError);
    });
    return client;
  }
}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}
