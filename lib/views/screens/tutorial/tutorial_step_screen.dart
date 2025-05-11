import 'package:flutter/material.dart';
import '../../../models/tutorial_step.dart';
import '../../../core/mixins/sound_mixin.dart';

class TutorialStepScreen extends StatefulWidget {
  final TutorialSection section;
  final int initialStep;

  const TutorialStepScreen({
    Key? key,
    required this.section,
    required this.initialStep,
  }) : super(key: key);

  @override
  State<TutorialStepScreen> createState() => _TutorialStepScreenState();
}

class _TutorialStepScreenState extends State<TutorialStepScreen> with SoundMixin {
  late PageController _pageController;
  late int _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _pageController = PageController(initialPage: _currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    if (_currentStep < widget.section.steps.length - 1) {
      playButtonSound(context);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      playButtonSound(context);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.title),
        backgroundColor: widget.section.color,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),
          // Step content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.section.steps.length,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemBuilder: (context, index) {
                final step = widget.section.steps[index];
                return _buildStepContent(step);
              },
            ),
          ),
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: widget.section.color.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.section.steps.length,
          (index) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentStep == index
                  ? widget.section.color
                  : Colors.grey.shade300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(TutorialStep step) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Step title
            Text(
              step.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Step image (placeholder or actual image)
            _buildImagePlaceholder(step),
            const SizedBox(height: 24),
            // Step description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Step icon
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: step.color,
                    child: Icon(
                      step.icon,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Step description
                  Text(
                    step.description,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(TutorialStep step) {
    // Check if image exists, otherwise show a placeholder
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: step.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: step.color,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            step.icon,
            size: 60,
            color: step.color,
          ),
          const SizedBox(height: 8),
          Text(
            step.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: step.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: _currentStep > 0 ? _goToPreviousStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.section.color,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),
          // Step counter
          Text(
            '${_currentStep + 1}/${widget.section.steps.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Next button
          ElevatedButton.icon(
            onPressed: _currentStep < widget.section.steps.length - 1
                ? _goToNextStep
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.section.color,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            label: const Text('Next'),
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }
}
