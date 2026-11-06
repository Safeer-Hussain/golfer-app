import 'package:flutter/material.dart';
import '../ai_caddie_controller.dart';
import 'dispersion_indicator.dart';

class CaddieChatBubble extends StatelessWidget {
  final CaddieChatMessage message;

  const CaddieChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary, width: 1.5),
              ),
              child: Icon(Icons.smart_toy_rounded, size: 18, color: colorScheme.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? colorScheme.primary : colorScheme.surfaceContainer,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser ? colorScheme.primary : colorScheme.outlineVariant,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                    ),
                  ),
                  if (message.recommendation != null)
                    DispersionIndicator(recommendation: message.recommendation!),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, "0")}:${message.timestamp.minute.toString().padLeft(2, "0")}',
                    style: TextStyle(
                      fontSize: 9,
                      color: (isUser ? colorScheme.onPrimary : colorScheme.onSurfaceVariant)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: const AssetImage('assets/images/avatar_safeer.png'),
            ),
          ],
        ],
      ),
    );
  }
}
