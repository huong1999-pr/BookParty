import 'package:chopper/chopper.dart';

typedef T JsonFactory<T>(Map<String, dynamic> json);

class JsonSerializableConverter extends JsonConverter {
  final Map<Type, JsonFactory> factories;

  JsonSerializableConverter(this.factories);

  T _decodeMap<T, InnerType>(Map<String, dynamic> values) {
    /// Get jsonFactory using Type parameters
    /// if not found or invalid, throw error or return null

    final jsonFactory = factories[T];
    if (jsonFactory == null || jsonFactory is! JsonFactory<T>) {
      /// throw serializer not found error;
      return null;
    }

    return jsonFactory(values);
  }

  List<SubType> _decodeList<ParentType, SubType>(List values) => values
      .where((v) => v != null)
      .map<SubType>((v) => _decode<ParentType, SubType>(v))
      .toList();

  dynamic _decode<BodyType, InnerType>(entity) {
    if (entity is Iterable) return _decodeList<BodyType, InnerType>(entity);

    if (entity is Map) return _decodeMap<BodyType, InnerType>(entity);

    return entity;
  }

  @override
  Response<BodyType> convertResponse<BodyType, InnerType>(Response response) {
    // use [JsonConverter] to decode json
    final jsonRes = super.convertResponse(response);
    var body = _decode<BodyType, InnerType>(jsonRes.body);
    return jsonRes.copyWith(body: body);
  }

  @override
  // all objects should implements toJson method
  Request convertRequest(Request request) => super.convertRequest(request);

//  Response convertError<ResultType, Item>(Response response) {
//    // use [JsonConverter] to decode json
//    final jsonRes = super.convertError(response);
//
//    return jsonRes.replace<ResourceError>(
//      body: ResourceError.fromJsonFactory(jsonRes.body),
//    );
//  }
}
