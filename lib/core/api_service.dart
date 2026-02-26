import 'package:dio/dio.dart';

import '../features/tasks/data/task_model.dart';

class ApiService {
  // 1. The Base URL is the "Address" of the server.
  // Using a getter makes it easy to change later.
  final String _baseUrl = 'https://69a0186a3188b0b1d537bbac.mockapi.io/tasks';

  // 2. Dio is the library that actually sends the internet requests.
  final Dio _dio = Dio();

  // 3. This function fetches (Gets) the tasks from the server.
  Future<Response> getTasks() async {
    try {
      // We "await" because the internet takes time to respond.
      final response = await _dio.get('$_baseUrl/tasks');
      return response;
    } on DioException catch (e) {
      // 4. Error Handling: If the internet fails, we catch the error here.
      throw _handleError(e);
    }
  }

  // 5. A private helper to make error messages user-friendly.
  String _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return "Check your internet connection.";
    }
    return "Something went wrong. Please try again.";
  }

  // This tells the server to delete a specific task by its ID
  Future<void> deleteTask(String id) async {
    try {
      // we use the DELETE method here
      await _dio.delete('$_baseUrl/tasks/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 1. CREATE: Sending a new task to the server
  // 1. CREATE: Sending a new task to the server
  Future<void> createTask(Task task) async {
    try {
      // we use 'post' to send the data
      await _dio.post(_baseUrl, data: {
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'dueDate': task.dueDate,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 2. EDIT: Updating an existing task
  Future<void> updateTask(Task task) async {
    try {
      // we use 'put' and add the ID to the URL to update that specific task
      await _dio.put('$_baseUrl/${task.id}', data: {
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'dueDate': task.dueDate,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}