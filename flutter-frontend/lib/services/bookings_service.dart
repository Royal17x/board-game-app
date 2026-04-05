import 'dart:convert';
import 'package:board_game_app/models/booking.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://192.168.0.26:8080';

class BookingsService {
  Future<List<Booking>> fetchBookings(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings?user_id=$userId'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Booking.fromJson(e)).toList();
    }
    throw Exception('Не удалось загрузить бронирования');
  }

  Future<Booking> createBooking({
    required int userId,
    required int gameId,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'game_id': gameId}),
    );
    if (response.statusCode == 201) {
      return Booking.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 409) {
      throw Exception('Игра уже забронирована');
    }
    throw Exception('Ошибка при бронировании');
  }

  Future<void> cancelBooking({
    required int userId,
    required int bookingId,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/bookings/$bookingId?user_id=$userId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка при отмене бронирования');
    }
  }
}

final bookingsService = BookingsService();
