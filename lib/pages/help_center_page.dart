import 'package:flutter/material.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  String selectedCategory = 'General';

  final List<String> categories = ['General', 'Account', 'Ordering', 'Payment'];

  final Map<String, List<Map<String, dynamic>>> helpTopics = {
    'General': [
      {
        'question': 'How do I create a new account?',
        'answer': '''To create a new account, please follow these simple steps:

1. Open the app and navigate to the login screen.
2. Below the login form, you'll see an option to "Register" Tap on that.
3. You will be prompted to enter your Phone Number, Email and Full Name for your account. Please make sure to use a valid Phone Number.
4. After entering your Phone Number, Email and Full Name, tap on the "Register" button.
5. A code will be sent to your Phone Number provided for verification. Please check your Phone Number.
6. After entering the code in the verification screen to verify your account.
7. Once your account is verified, the app will automatically log you in.
8. You can enter some other personal information or skip it.
9. You are now done creating your account.

If you encounter any issues during the sign-up process, feel free to reach out to our support team for assistance.''',
      },
      {
        'question': 'I forgot my password. How do I reset it?',
        'answer': '''To reset your password:

1. Go to the login screen
2. Click on "Forgot Password?"
3. Enter your registered email address
4. Check your email for a password reset link
5. Click the link and create a new password
6. Use your new password to login

If you don't receive the email, check your spam folder or contact support.''',
      },
      {
        'question':
            'I\'m having trouble logging into my account. How can I resolve this?',
        'answer': '''If you're having trouble logging in, try these steps:

1. Make sure you're entering the correct email and password
2. Check if Caps Lock is on
3. Try resetting your password using "Forgot Password"
4. Clear your browser cache or app data
5. Ensure you have a stable internet connection
6. Try logging in from a different device

If none of these work, contact our support team.''',
      },
    ],
    'Account': [
      {
        'question': 'How do I update my profile information?',
        'answer': '''To update your profile:

1. Go to the Profile page
2. Tap on the field you want to edit (Name, Phone, Email, Location)
3. Enter the new information
4. Save the changes

Your profile will be updated immediately.''',
      },
      {
        'question': 'How do I change my password?',
        'answer': '''To change your password:

1. Go to Profile
2. Tap on "Keamanan" (Security)
3. Select "Ubah Password"
4. Enter your old password
5. Enter your new password
6. Confirm the new password
7. Tap Save

Make sure your new password is strong and secure.''',
      },
    ],
    'Ordering': [
      {
        'question': 'How do I place a new order?',
        'answer': '''To place an order:

1. Browse the menu and select items
2. Add items to cart with desired quantity
3. Review your cart
4. Proceed to checkout
5. Enter delivery address
6. Choose payment method
7. Confirm and place order

You'll receive order confirmation and tracking updates.''',
      },
      {
        'question':
            'I want to cancel an order I\'ve placed. How can I do this?',
        'answer': '''To cancel an order:

1. Go to Orders History
2. Find the Prepared order
3. Tap on the order
4. Select "Cancel Order"
5. Choose cancellation reason
6. Confirm cancellation

Note: Orders can only be cancelled before they are prepared. Once the restaurant starts preparing, cancellation may not be possible.''',
      },
      {
        'question': 'How do I track my order?',
        'answer': '''To track your order:

1. Go to Orders History
2. Select the Prepared order
3. View real-time tracking
4. You'll see order status updates:
   - Order Confirmed
   - Being Prepared
   - Ready for Pickup
   - On the Way
   - Delivered

You'll also receive notifications for each status update.''',
      },
    ],
    'Payment': [
      {
        'question':
            'I\'m experiencing issues with payment. How can I resolve it?',
        'answer': '''If you're having payment issues:

1. Check your payment method details are correct
2. Ensure you have sufficient balance
3. Try a different payment method
4. Check your internet connection
5. Clear app cache and try again
6. Contact your bank if issue persists

Our support team is also available to help.''',
      },
      {
        'question': 'What payment methods are accepted?',
        'answer': '''We accept the following payment methods:

1. Credit/Debit Cards (Visa, Mastercard)
2. PayPal
3. Cash on Delivery
4. Bank Transfer
5. E-wallets (GoPay, OVO, Dana)

Choose your preferred method during checkout.''',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryTabs(),
          Expanded(child: _buildHelpList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Contact Support')));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.phone, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHelpList() {
    final topics = helpTopics[selectedCategory] ?? [];

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        separatorBuilder:
            (context, index) => Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final topic = topics[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            title: Text(
              topic['question'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => HelpDetailPage(
                        question: topic['question'],
                        answer: topic['answer'],
                      ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Help Detail Page
class HelpDetailPage extends StatelessWidget {
  final String question;
  final String answer;

  const HelpDetailPage({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help Center _ Detail',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Help',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Contact Support')));
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.phone, color: Colors.white),
      ),
    );
  }
}
