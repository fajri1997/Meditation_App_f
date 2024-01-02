// import 'package:dio/dio.dart';
// import 'package:meditation_app/models/tip.dart';

// class TodoService {
//   final String serverUrl = "https://coded-meditation.eapi.joincoded.com";
//   final Dio _dio = Dio();

//   Future<List<Todo>> getTodosListApi() async {
//     try {
//       final responseValue = await _dio.get(serverUrl);
//       if (responseValue.statusCode == 200) {
//         final TodoModel todoModel = TodoModel.fromJson(responseValue.data);
//         return todoModel.data;
//       }
//       return [];
//     } catch (e) {
//       throw e.toString();
//     }
//   }

//   createTodoApi(String todoName, bool? isComplete) async {
//     try {
//       final Response response = await _dio.post(
//         serverUrl,
//         data: {
//           "todoName": todoName,
//           "isComplete": isComplete,
//         },
//       );
//       return response.data;
//     } catch (e) {
//       throw e.toString();
//     }
//   }

//   updateTodoApi(String id, bool? isComplete) async {
//     try {
//       final response = await _dio.put(
//         "$serverUrl/$id",
//         data: {
//           "isComplete": isComplete,
//         },
//       );

//       return response.data;
//     } catch (e) {
//       throw e.toString();
//     }
//   }
// }
