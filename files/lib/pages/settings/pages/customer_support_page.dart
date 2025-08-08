import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/wp_config.dart';
import '../../../widgets/custom_app_bar.dart';

class CustomerSupportPage extends ConsumerStatefulWidget {
  const CustomerSupportPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CustomerSupportPage> createState() => _CustomerSupportPageState();
}

class _CustomerSupportPageState extends ConsumerState<CustomerSupportPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: "Hello! How can I help you today?",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    _messageController.clear();

    // Simulate bot response
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: _getBotResponse(userMessage),
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    });
  }

  String _getBotResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('booking') || message.contains('reserve')) {
      return "To make a booking, please select your desired hotel and dates. You can also contact our booking support at +1234567890.";
    } else if (message.contains('cancel') || message.contains('refund')) {
      return "For cancellations and refunds, please contact our support team at support@realinn.com or call +1234567890.";
    } else if (message.contains('payment') || message.contains('pay')) {
      return "We accept all major credit cards, PayPal, and bank transfers. All payments are secure and encrypted.";
    } else if (message.contains('wifi') || message.contains('internet')) {
      return "Most of our hotels offer free WiFi. Please check the hotel details for specific information about internet access.";
    } else if (message.contains('parking')) {
      return "Parking availability varies by hotel. Please check the hotel details or contact the specific hotel for parking information.";
    } else {
      return "Thank you for your message. Our support team will get back to you within 24 hours. For urgent matters, please call +1234567890.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 768;

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        showBackButton: true,
        backAndLogoOnly: true,
      ),
      body: Column(
        children: [
          // Quick support options
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Support',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickSupportChip('Booking Help', Icons.calendar_today),
                    _buildQuickSupportChip('Payment Issues', Icons.payment),
                    _buildQuickSupportChip('Cancellation', Icons.cancel),
                    _buildQuickSupportChip('Hotel Info', Icons.hotel),
                    _buildQuickSupportChip('Contact Us', Icons.phone),
                  ],
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView.builder(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
          ),
          
          // Message input
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 16,
                          vertical: isTablet ? 16 : 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: WPConfig.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSupportChip(String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: WPConfig.primaryColor),
      label: Text(
        label,
        style: TextStyle(
          color: WPConfig.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: WPConfig.primaryColor.withOpacity(0.1),
      onPressed: () {
        _messageController.text = label;
        _sendMessage();
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 768;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: isTablet ? 20 : 16,
              backgroundColor: WPConfig.primaryColor,
              child: Icon(
                Icons.support_agent,
                color: Colors.white,
                size: isTablet ? 20 : 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 12 : 10,
              ),
              decoration: BoxDecoration(
                color: message.isUser ? WPConfig.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.grey[600],
                      fontSize: isTablet ? 12 : 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: isTablet ? 20 : 16,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person,
                color: Colors.grey[600],
                size: isTablet ? 20 : 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: WPConfig.primaryColor,
            child: Icon(Icons.support_agent, color: Colors.white, size: 16),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      margin: EdgeInsets.symmetric(horizontal: 2),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
} 