import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppErrorHandler {
  static String getMessage(Object error) {
    if (error is AuthException) {
      // Supabase specific Auth errors
      if (error.message.contains("Invalid login credentials")) {
        return "Incorrect email or password. Please try again.";
      }
      if (error.message.contains("User already registered")) {
        return "This email is already in use. Try logging in.";
      }
      return error.message; // Fallback to Supabase's message (usually readable)
    } 
    
    if (error is SocketException) {
      return "No internet connection. Please check your network.";
    }

    if (error is FormatException) {
      return "Invalid data format received.";
    }

    // Default cleanup for generic Dart exceptions
    String msg = error.toString();
    if (msg.startsWith("Exception: ")) {
      msg = msg.replaceAll("Exception: ", "");
    }
    return msg;
  }
}