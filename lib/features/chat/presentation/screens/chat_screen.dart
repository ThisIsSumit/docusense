import 'package:docusense/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/models/chat_models.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? documentId;
  const ChatScreen({super.key, this.documentId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  ChatNotifier get _notifier =>
      ref.read(chatNotifierProvider(documentId: widget.documentId).notifier);

  void _send() {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    _ctrl.clear();
    _notifier.sendMessage(q);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(
        chatNotifierProvider(documentId: widget.documentId));

    // Auto-scroll when new content arrives
    ref.listen(
      chatNotifierProvider(documentId: widget.documentId)
          .select((s) => s.messages.length),
      (_, __) => _scrollToBottom(),
    );

    return Scaffold(
      backgroundColor: AppColors.void1,
      appBar: _ChatAppBar(
        documentId: widget.documentId,
        messageCount: chatState.messages
            .where((m) => m.role == MessageRole.user)
            .length,
        onClear: () => _notifier.clearMessages(),
      ),
      body: Column(
        children: [
          // Scope indicator
          if (widget.documentId != null)
            _ScopeBar(documentId: widget.documentId!),

          // Messages
          Expanded(
            child: chatState.messages.isEmpty
                ? _EmptyState(onSuggestion: (s) {
                    _ctrl.text = s;
                    _send();
                  })
                : _MessageList(
                    messages: chatState.messages,
                    scrollCtrl: _scrollCtrl,
                  ),
          ),

          // Input
          _InputBar(
            ctrl: _ctrl,
            focusNode: _focusNode,
            isStreaming: chatState.isStreaming,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BAR
// ─────────────────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? documentId;
  final int messageCount;
  final VoidCallback onClear;
  const _ChatAppBar({
    required this.documentId,
    required this.messageCount,
    required this.onClear,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.void2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => context.pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            documentId != null ? 'Document chat' : 'Ask DocuSense',
            style: AppTextStyles.headingSM,
          ),
          if (messageCount > 0)
            Text(
              '$messageCount ${messageCount == 1 ? 'question' : 'questions'}',
              style: AppTextStyles.monoSM,
            ),
        ],
      ),
      actions: [
        if (messageCount > 0)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18),
            onPressed: onClear,
            tooltip: 'Clear chat',
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
        child: Container(height: 0.5, color: AppColors.wireDim),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCOPE BAR
// ─────────────────────────────────────────────────────────────────────────────

class _ScopeBar extends ConsumerWidget {
  final String documentId;
  const _ScopeBar({required this.documentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.signalTrace,
        border: Border(
          bottom: BorderSide(color: AppColors.wireDim, width: 0.5),
        ),
      ),
      child: Row(
        children: [
           Icon(Icons.lock_outline_rounded,
              size: 12, color: AppColors.signal),
          const SizedBox(width: 6),
          Text(
            'Scoped to document — results from this file only',
            style: AppTextStyles.monoSM,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go(AppRoutes.chat),
            child: Text('Search all →',
                style: AppTextStyles.monoSM
                    .copyWith(color: AppColors.signal)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE LIST
// ─────────────────────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollCtrl;
  const _MessageList({
    required this.messages,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final isUser = msg.role == MessageRole.user;
        return isUser
            ? _UserBubble(msg: msg, index: i)
            : _AssistantBubble(msg: msg, index: i);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USER BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  final ChatMessage msg;
  final int index;
  const _UserBubble({required this.msg, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.signalTrace,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(3),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(
                    color: AppColors.signal.withOpacity(0.2),
                    width: 0.5),
              ),
              child: Text(
                msg.content,
                style: AppTextStyles.bodyMD
                    .copyWith(color: AppColors.ink0),
              ),
            ),
          ),
        ],
      ).animate()
          .fadeIn(delay: Duration(milliseconds: 30 * (index % 8)))
          .slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ASSISTANT BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _AssistantBubble extends StatelessWidget {
  final ChatMessage msg;
  final int index;
  const _AssistantBubble({required this.msg, required this.index});

  @override
  Widget build(BuildContext context) {
    final isStreaming = msg.status == MessageStatus.streaming;
    final isError = msg.status == MessageStatus.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar row
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.signalTrace,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: AppColors.signal.withOpacity(0.3),
                      width: 0.5),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.signal,
                  size: 13,
                ),
              ),
              const SizedBox(width: 8),
              Text('DocuSense', style: AppTextStyles.labelLG
                  .copyWith(color: AppColors.signal)),
              const Spacer(),
              if (msg.tokensUsed != null)
                Text('${msg.tokensUsed} tok · ${msg.latencyMs}ms',
                    style: AppTextStyles.monoSM),
            ],
          ),
          const SizedBox(height: 8),

          // Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface0,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border.all(
                color: isError
                    ? AppColors.red.withOpacity(0.3)
                    : AppColors.wire,
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streaming indicator
                if (isStreaming && msg.content.isEmpty)
                  _ThinkingDots()
                else
                  _MessageText(
                    text: msg.content,
                    isStreaming: isStreaming,
                    isError: isError,
                  ),

                // Sources
                if (msg.sources.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    height: 0.5,
                    color: AppColors.wireDim,
                  ),
                  const SizedBox(height: 12),
                  Text('SOURCES',
                      style: AppTextStyles.labelMD
                          .copyWith(color: AppColors.ink2)),
                  const SizedBox(height: 8),
                  ...msg.sources.asMap().entries.map((e) =>
                      _SourceChip(
                        index: e.key + 1,
                        citation: e.value,
                      )),
                ],
              ],
            ),
          ),
        ],
      ).animate()
          .fadeIn(delay: Duration(milliseconds: 30 * (index % 8)))
          .slideX(begin: -0.04, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

class _MessageText extends StatelessWidget {
  final String text;
  final bool isStreaming;
  final bool isError;
  const _MessageText({
    required this.text,
    required this.isStreaming,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.bodyMD.copyWith(
              color: isError ? AppColors.red : AppColors.ink0,
              height: 1.65,
            ),
          ),
        ),
        if (isStreaming) ...[
          const SizedBox(width: 3),
          _Cursor(),
        ],
      ],
    );
  }
}

class _Cursor extends StatefulWidget {
  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Opacity(
      opacity: _ctrl.value,
      child: Container(
        width: 2,
        height: 14,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: AppColors.signal,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    ),
  );
}

class _ThinkingDots extends StatefulWidget {
  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final phase = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
        final opacity = 0.2 +
            (phase < 0.5 ? phase * 1.6 : (1 - phase) * 1.6).clamp(0.0, 0.8);
        return Container(
          margin: const EdgeInsets.only(right: 4),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.signal.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      }),
    ),
  );
}

class _SourceChip extends StatelessWidget {
  final int index;
  final SourceCitation citation;
  const _SourceChip({required this.index, required this.citation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.void3,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.wire, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.signalTrace,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTextStyles.monoSM
                    .copyWith(color: AppColors.signal, fontSize: 9),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  citation.documentTitle,
                  style: AppTextStyles.bodyMD
                      .copyWith(color: AppColors.ink0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (citation.pageNumber != null)
                  Text(
                    'p.${citation.pageNumber}  ·  '
                    '${(citation.similarity * 100).toStringAsFixed(0)}% match',
                    style: AppTextStyles.monoSM,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INPUT BAR
// ─────────────────────────────────────────────────────────────────────────────

class _InputBar extends StatefulWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final bool isStreaming;
  final VoidCallback onSend;
  const _InputBar({
    required this.ctrl,
    required this.focusNode,
    required this.isStreaming,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final has = widget.ctrl.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.void2,
        border: Border(
            top: BorderSide(color: AppColors.wireDim, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.void3,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: widget.focusNode.hasFocus
                        ? AppColors.signal.withOpacity(0.4)
                        : AppColors.wire,
                    width: 0.5),
              ),
              child: TextField(
                controller: widget.ctrl,
                focusNode: widget.focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: AppTextStyles.bodyMD
                    .copyWith(color: AppColors.ink0),
                cursorColor: AppColors.signal,
                decoration: InputDecoration(
                  hintText: widget.isStreaming
                      ? 'Streaming response...'
                      : 'Ask a question...',
                  hintStyle: AppTextStyles.bodyMD
                      .copyWith(color: AppColors.ink3),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send / stop button
          GestureDetector(
            onTap: widget.isStreaming ? null : widget.onSend,
            child: AnimatedContainer(
              duration: AppConstants.microDuration,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.isStreaming
                    ? AppColors.amberTrace
                    : (_hasText
                        ? AppColors.signal
                        : AppColors.surface1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isStreaming
                      ? AppColors.amber.withOpacity(0.4)
                      : (_hasText
                          ? Colors.transparent
                          : AppColors.wire),
                  width: 0.5,
                ),
              ),
              child: widget.isStreaming
                  ? const _StreamingIndicator()
                  : Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: _hasText
                          ? AppColors.void0
                          : AppColors.ink3,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamingIndicator extends StatefulWidget {
  const _StreamingIndicator();

  @override
  State<_StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<_StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: 14 + _ctrl.value * 4,
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.amber,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final void Function(String) onSuggestion;
  const _EmptyState({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Summarise the key findings',
      'What are the main risks mentioned?',
      'List all dates and deadlines',
      'Who are the key stakeholders?',
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.signalTrace,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.signal.withOpacity(0.2), width: 0.5),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: AppColors.signal, size: 24),
          ),
          const SizedBox(height: 16),
          Text('Ask anything', style: AppTextStyles.headingMD),
          const SizedBox(height: 6),
          Text('Powered by Claude + semantic search',
              style: AppTextStyles.bodyMD),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: suggestions
                .map((s) => _SuggestionChip(
                      label: s,
                      onTap: () => onSuggestion(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.wire, width: 0.5),
      ),
      child: Text(label,
          style: AppTextStyles.bodyMD
              .copyWith(color: AppColors.ink0)),
    ),
  );
}
