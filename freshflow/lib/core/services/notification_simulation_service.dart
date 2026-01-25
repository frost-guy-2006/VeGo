class NotificationSimulationService {
  static String? getContextualNudge() {
    final hour = DateTime.now().hour;

    // Simulate "Smart Nudges"
    if (hour >= 6 && hour < 11) {
      return "Good Morning! ☀️ Need fresh milk or eggs?";
    } else if (hour >= 11 && hour < 14) {
      return "Lunch time! 🥗 How about a fresh salad?"; // e.g. Spinach/Carrot
    } else if (hour >= 14 && hour < 18) {
      return "Mid-day slump? ☕ Grab a snack!";
    } else if (hour >= 18 && hour < 22) {
      return "Dinner prepping? 🥘 Get your veggies in 10 mins!";
    } else {
      return "Late night cravings? 🌙 We are still open!";
    }
  }
}
