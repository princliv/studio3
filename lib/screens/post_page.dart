import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/pill_input.dart';
import '../widgets/primary_button.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  String _type = 'piece';
  bool _hasMedia = false;
  final _titleController = TextEditingController();
  final _storyController = TextEditingController();
  final _yearController = TextEditingController();
  bool _listForSale = false;
  final _priceController = TextEditingController();
  final _captionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _storyController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.slate500)),
        ),
        title: const Text('New Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _hasMedia ? () {} : null,
            child: Text('Share', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _hasMedia ? AppColors.slate900 : AppColors.slate300)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                _TypeChip(label: 'Piece', active: _type == 'piece', onTap: () => setState(() => _type = 'piece')),
                const SizedBox(width: 8),
                _TypeChip(label: 'Post', active: _type == 'post', onTap: () => setState(() => _type = 'post')),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _hasMedia = !_hasMedia),
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: _hasMedia ? AppColors.slate200 : AppColors.slate100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate300, width: 2, strokeAlign: BorderSide.strokeAlignInside),
                ),
                child: _hasMedia
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.slate200,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TextButton(
                              onPressed: () => setState(() => _hasMedia = false),
                              child: const Text('Change'),
                            ),
                          ),
                        ],
                      )
                    : const Center(
                        child: Text('Tap to add photo or video', style: TextStyle(fontSize: 14, color: AppColors.slate400)),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            if (_type == 'piece') ...[
              PillInput(controller: _titleController, placeholder: 'Title (required)'),
              const SizedBox(height: 16),
              TextField(
                controller: _storyController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Story / Intent (optional)',
                  filled: true,
                  fillColor: AppColors.slate50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              PillInput(controller: _yearController, placeholder: 'Year (optional)'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('List for Sale', style: TextStyle(fontSize: 15, color: AppColors.slate700)),
                  Switch(
                    value: _listForSale,
                    onChanged: (v) => setState(() => _listForSale = v),
                    activeColor: AppColors.slate900,
                  ),
                ],
              ),
              if (_listForSale) ...[
                const SizedBox(height: 16),
                PillInput(controller: _priceController, placeholder: 'Price (\$)'),
              ],
              const SizedBox(height: 16),
              const Text('Tags (up to 10)', style: TextStyle(fontSize: 12, color: AppColors.slate500)),
              const SizedBox(height: 8),
              PillInput(placeholder: 'Add tags...'),
            ],
            if (_type == 'post') ...[
              TextField(
                controller: _captionController,
                maxLines: 4,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: 'Caption',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  counterStyle: const TextStyle(fontSize: 12, color: AppColors.slate400),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  alignment: Alignment.centerLeft,
                  side: const BorderSide(color: AppColors.slate200),
                ),
                child: const Text('Link to a Piece (optional)', style: TextStyle(color: AppColors.slate500)),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.slate900 : AppColors.slate100,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: active ? AppColors.white : AppColors.slate600)),
      ),
    );
  }
}
