class ChatbotService {
  static String getResponse(String input) {
    final query = input.toLowerCase().trim();

    if (query == "hi" || query == "hello" || query == "hey" || query == "hii" || query == "hai") {
      return "Hello 👋! How can I assist you today?";
    } else if (query.contains("place order") || query.contains("how to order")) {
      return "To place an order, tap the 'Place Order' section on the dashboard.";
    } else if (query.contains("cancel") && query.contains("order")) {
      return "To cancel your order, go to 'My Orders' and request cancellation or contact support.";
    } else if (query.contains("delivery date") || query.contains("when will") || query.contains("delivered")) {
      return "Delivery usually takes 3-5 business days. Track it in 'My Orders'.";
    } else if (query.contains("bulk order") || query.contains("order in bulk")) {
      return "Yes, bulk ordering is available. Mention your quantity in the order form.";
    } else if (query.contains("order delayed") || query.contains("delayed order") || query.contains("order late") || query.contains("order hasn’t arrived") || query.contains("order not delivered")) {
      return "We’re sorry for the delay. Some orders may be affected by supply chain or weather issues. Please check 'My Orders' for the latest status or contact support.";
    } else if (query.contains("stock") || query.contains("available") || query.contains("quantity")) {
      return "You can check item stock in the 'View Inventory' section.";
    } else if (query.contains("milk") && query.contains("restock")) {
      return "Yes, milk was restocked today morning.";
    } else if (query.contains("where is my product") || query.contains("track my product") || query.contains("product location")) {
      return "You can find your product location under the 'Product Location' section.";
    } else if (query.contains("track order") || query.contains("track delivery")) {
      return "You can track your order in the 'My Orders' section.";
    } else if (query.contains("electronics department") || query.contains("handles electronics")) {
      return "The Electronics department handles gadgets and accessories.";
    } else if (query.contains("weather") && query.contains("affect")) {
      return "Yes, bad weather may delay deliveries. We will notify you if your order is affected.";
    } else if (query.contains("change delivery date")) {
      return "You can edit your order or request a date change via support.";
    } else if (query.contains("weather")) {
      return "Live weather updates are available in the 'Weather' section on your dashboard.";
    } else if (query.contains("helpline") || query.contains("phone number") || query.contains("contact number") || query.contains("call support") || query.contains("customer care")) {
      return "You can call our helpline at 📞 6204640394.";
    } else if (query.contains("contact support") || query.contains("help")) {
      return "You can contact support from the 'Notice' section or email support@example.com.";
    } else if (query.contains("return policy") || query.contains("return item")) {
      return "Returns are allowed within 7 days of delivery.";
    } else if (query.contains("custom request")) {
      return "Use the 'Make a Request' section to submit your custom product request.";
    } else if (query.contains("where is") && query.contains("place order")) {
      return "It's in the dashboard — tap the 'Place Order' card.";
    } else if (query.contains("my orders")) {
      return "You can see all your orders in the 'My Orders' section.";
    } else if (query.contains("notice")) {
      return "All important alerts and updates are in the 'Notice' section.";
    } else if (query.contains("maintenance")) {
      return "The Maintenance section alerts you on product care and breakdowns.";
    } else {
      return "Hmm, I’m not sure how to answer that. You can explore the dashboard or rephrase your question.";
    }
  }
}
