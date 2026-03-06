class IntentService {
  String detectIntent(String text) {
    text = text.toLowerCase();

    // Navigation
    if (text.contains("go to home") || text.contains("ڈیش بورڈ") || text.contains("ہوم")) {
      return "NAV_HOME";
    }
    if (text.contains("go to cart") || text.contains("ٹوکری") || text.contains("کارٹ")) {
      return "NAV_CART";
    }
    if (text.contains("go to profile") || text.contains("میری پروفائل") || text.contains("پروفائل")) {
      return "NAV_PROFILE";
    }
    if (text.contains("go to orders") || text.contains("آرڈرز")) {
      return "NAV_ORDERS";
    }

    // Actions
    if (text.startsWith("search for") || text.startsWith("find") || text.contains("تلاش کریں")) {
      return "SEARCH";
    }
    if (text.contains("logout") || text.contains("sign out") || text.contains("لاگ آؤٹ")) {
      return "LOGOUT";
    }

    // Existing context specific
    if (text.contains("menu") || text.contains("مینُو")) {
      return "SHOW_MENU";
    } 
    if (text.contains("order") || text.contains("آرڈر")) {
      return "PLACE_ORDER";
    }
    if (text.contains("pay") || text.contains("payment") || text.contains("checkout") || text.contains("ادائیگی")) {
      return "MAKE_PAYMENT";
    }

    return "UNKNOWN";
  }

  String extractSearchQuery(String text) {
    text = text.toLowerCase();
    if (text.startsWith("search for ")) return text.replaceFirst("search for ", "");
    if (text.startsWith("find ")) return text.replaceFirst("find ", "");
    if (text.contains("تلاش کریں")) return text.replaceFirst("تلاش کریں", "").trim();
    return text;
  }
}