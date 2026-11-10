import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../scorecard/scorecard_controller.dart';
import 'ai_caddie_controller.dart';
import 'widgets/caddie_chat_bubble.dart';
import 'widgets/caddie_shortcut_chips.dart';

class AiGolfCaddieView extends StatefulWidget {
  const AiGolfCaddieView({super.key});

  @override
  State<AiGolfCaddieView> createState() => _AiGolfCaddieViewState();
}

class _AiGolfCaddieViewState extends State<AiGolfCaddieView> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(AiCaddieController controller) {
    final text = _inputController.text.trim();
    if (text.isEmpty || controller.isStreaming) return;

    _inputController.clear();
    controller.sendUserPrompt(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildChatPane(BuildContext context, AiCaddieController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Message list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              return CaddieChatBubble(message: controller.messages[index]);
            },
          ),
        ),
        // Streaming indicator
        if (controller.isStreaming) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.streamingStatusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        // Quick Shortcuts
        CaddieShortcutChips(
          isDisabled: controller.isStreaming,
          onSelectPrompt: (prompt) {
            controller.sendUserPrompt(prompt);
            _scrollToBottom();
          },
        ),
        // Bottom Input Bar
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(controller),
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Ask Caddie for hole strategy, club, or wind...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: controller.isStreaming
                      ? null
                      : () => _sendMessage(controller),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeInfoPane(
    BuildContext context,
    AiCaddieController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final hole = controller.currentHole;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hole ${hole.holeNumber} Strategy Cockpit',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${controller.course.name} • ${hole.yardageForTee(controller.teeBox)} YDS • Par ${hole.par}',
            style: TextStyle(fontSize: 11, color: colorScheme.secondary),
          ),
          const Divider(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atmospheric & Hazard Vectors',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Wind: ${hole.windDirection}\nElevation: ${hole.elevationChangeFeet >= 0 ? "+${hole.elevationChangeFeet}" : hole.elevationChangeFeet} ft\nHazards: ${hole.hazardsDescription}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => controller.clearConversation(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(
              'Reset Caddie Session',
              style: TextStyle(fontSize: 11),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              side: BorderSide(color: colorScheme.outlineVariant),
              minimumSize: const Size.fromHeight(36),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = sl<AiCaddieController>();
    final scorecardController = sl<ScorecardController>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    controller.syncHoleContext(
      scorecardController.course,
      scorecardController.currentHoleIndex,
      scorecardController.activeScorecard.teeBox,
    );

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: isLandscape
              ? Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildLandscapeInfoPane(context, controller),
                    ),
                    VerticalDivider(
                      width: 1,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildChatPane(context, controller),
                    ),
                  ],
                )
              : _buildChatPane(context, controller),
        );
      },
    );
  }
}
