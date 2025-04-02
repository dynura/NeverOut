// password_strength_indicator.dart

import 'package:flutter/material.dart';
import 'package:neverout/features/user_auth/presentation/widgets/app_theme.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check the strength of the password
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // Calculate the strength score (0-4)
    int strength = 0;
    if (hasMinLength) strength++;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialChars) strength++;

    // Determine colors based on strength
    Color strengthColor = Colors.grey;
    String strengthText = 'No password';

    if (password.isNotEmpty) {
      if (strength <= 2) {
        strengthColor = Colors.red;
        strengthText = 'Weak';
      } else if (strength <= 3) {
        strengthColor = Colors.orange;
        strengthText = 'Medium';
      } else if (strength <= 4) {
        strengthColor = Colors.blue;
        strengthText = 'Strong';
      } else {
        strengthColor = Colors.green;
        strengthText = 'Very Strong';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Password strength bar
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: strength >= 1 ? strengthColor : Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Container(
                height: 5,
                color: strength >= 2 ? strengthColor : Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Container(
                height: 5,
                color: strength >= 3 ? strengthColor : Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Container(
                height: 5,
                color: strength >= 4 ? strengthColor : Colors.grey.shade300,
              ),
            ),
            const SizedBox(width: 2),
            Expanded(
              flex: 1,
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: strength >= 5 ? strengthColor : Colors.grey.shade300,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Strength text
        if (password.isNotEmpty)
          Row(
            children: [
              Text(
                strengthText,
                style: AppTheme.bodySmall(color: strengthColor),
              ),
              const Spacer(),
              Text(
                '${strength * 20}%',
                style: AppTheme.bodySmall(color: AppTheme.secondColor),
              ),
            ],
          ),
          
        // Password requirements
        const SizedBox(height: 8),
        if (password.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRequirement(hasMinLength, 'At least 8 characters'),
              _buildRequirement(hasUppercase, 'At least 1 uppercase letter'),
              _buildRequirement(hasLowercase, 'At least 1 lowercase letter'),
              _buildRequirement(hasDigits, 'At least 1 number'),
              _buildRequirement(hasSpecialChars, 'At least 1 special character'),
            ],
          ),
      ],
    );
  }

  Widget _buildRequirement(bool isMet, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.remove_circle_outline,
            color: isMet ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}