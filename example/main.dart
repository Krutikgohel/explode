import 'package:flutter/material.dart';
import 'package:explode/explode.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explode Advanced Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const BlastHomePage(),
    );
  }
}

class BlastHomePage extends StatefulWidget {
  const BlastHomePage({super.key});

  @override
  State<BlastHomePage> createState() => _BlastHomePageState();
}

class _BlastHomePageState extends State<BlastHomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = const [
    ShapesDemoPage(),
    DurationDemoPage(),
    ParticleCustomizationPage(),
    ComplexUIDemoPage(),
    ExplodeAreaDemoPage(),
  ];

  final List<String> _titles = [
    "Particle Shapes",
    "Animation Duration",
    "Particle Customization",
    "Complex UI",
    "Explode Area",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_currentPage]), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _pages,
            ),
          ),
          _buildPageIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color:
                _currentPage == index
                    ? Theme.of(context).primaryColor
                    : Colors.grey[400],
          ),
        );
      }),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Widget for consistent presentation
// -----------------------------------------------------------------------------
class DemoItem extends StatelessWidget {
  final String label;
  final Widget child;
  final ExplodeController controller;
  final VoidCallback onReset;

  const DemoItem({
    super.key,
    required this.label,
    required this.child,
    required this.controller,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Stack(
          alignment: Alignment.center,
          children: [
            // Placeholder area to keep layout stable when blasted
            const SizedBox(width: 120, height: 120),
            GestureDetector(onTap: () => controller.explode(), child: child),
          ],
        ),
        // TextButton.icon(
        //   onPressed: onReset,
        //   icon: const Icon(Icons.refresh, size: 16),
        //   label: const Text("Reset"),
        // ),
      ],
    );
  }
}

abstract class BaseDemoPage extends StatefulWidget {
  const BaseDemoPage({super.key});
}

abstract class BaseDemoPageState<T extends BaseDemoPage> extends State<T> {
  // Helper to build the page layout
  Widget buildPageLayout({
    required List<Widget> children,
    required VoidCallback onResetAll,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
        child: Column(
          children: [
            ...children.map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 30), child: c),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onResetAll,
              icon: const Icon(Icons.restore),
              label: const Text("Reset All"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Page 1: Shapes
// -----------------------------------------------------------------------------
class ShapesDemoPage extends BaseDemoPage {
  const ShapesDemoPage({super.key});

  @override
  State<ShapesDemoPage> createState() => _ShapesDemoPageState();
}

class _ShapesDemoPageState extends BaseDemoPageState<ShapesDemoPage> {
  final ExplodeController _circleCtrl = ExplodeController();
  final ExplodeController _rectCtrl = ExplodeController();
  final ExplodeController _triCtrl = ExplodeController();

  @override
  Widget build(BuildContext context) {
    return buildPageLayout(
      onResetAll: () {
        _circleCtrl.reset();
        _rectCtrl.reset();
        _triCtrl.reset();
      },
      children: [
        DemoItem(
          label: "Circle Particles (Default)",
          controller: _circleCtrl,
          onReset: _circleCtrl.reset,
          child: Explode(
            controller: _circleCtrl,
            shape: ExplodeParticleShape.circle,
            child: _buildBox(Colors.blue, Icons.circle),
          ),
        ),
        DemoItem(
          label: "Rectangle Particles",
          controller: _rectCtrl,
          onReset: _rectCtrl.reset,
          child: Explode(
            controller: _rectCtrl,
            shape: ExplodeParticleShape.rectangle,
            child: _buildBox(Colors.orange, Icons.crop_square),
          ),
        ),
        DemoItem(
          label: "Triangle Particles",
          controller: _triCtrl,
          onReset: _triCtrl.reset,
          child: Explode(
            controller: _triCtrl,
            shape: ExplodeParticleShape.triangle,
            child: _buildBox(Colors.green, Icons.change_history),
          ),
        ),
      ],
    );
  }

  Widget _buildBox(Color color, IconData icon) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
      child: Icon(icon, color: Colors.white, size: 50),
    );
  }
}

// -----------------------------------------------------------------------------
// Page 2: Duration
// -----------------------------------------------------------------------------
class DurationDemoPage extends BaseDemoPage {
  const DurationDemoPage({super.key});

  @override
  State<DurationDemoPage> createState() => _DurationDemoPageState();
}

class _DurationDemoPageState extends BaseDemoPageState<DurationDemoPage> {
  final ExplodeController _fastCtrl = ExplodeController();
  final ExplodeController _normalCtrl = ExplodeController();
  final ExplodeController _slowCtrl = ExplodeController();

  @override
  Widget build(BuildContext context) {
    return buildPageLayout(
      onResetAll: () {
        _fastCtrl.reset();
        _normalCtrl.reset();
        _slowCtrl.reset();
      },
      children: [
        DemoItem(
          label: "Fast (1 Second)",
          controller: _fastCtrl,
          onReset: _fastCtrl.reset,
          child: Explode(
            controller: _fastCtrl,
            duration: const Duration(seconds: 1),
            child: _buildCard("Fast", Colors.redAccent),
          ),
        ),
        DemoItem(
          label: "Normal (1.5s)",
          controller: _normalCtrl,
          onReset: _normalCtrl.reset,
          child: Explode(
            controller: _normalCtrl,
            duration: const Duration(milliseconds: 1500),
            child: _buildCard("Normal", Colors.purpleAccent),
          ),
        ),
        DemoItem(
          label: "Slow (3s)",
          controller: _slowCtrl,
          onReset: _slowCtrl.reset,
          child: Explode(
            controller: _slowCtrl,
            duration: const Duration(seconds: 3),
            child: _buildCard("Slow", Colors.teal),
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCard(String text, Color color) {
    return Card(
      color: color,
      child: SizedBox(
        width: 120,
        height: 80,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Page 3: Particle Customization (Size & Count)
// -----------------------------------------------------------------------------
class ParticleCustomizationPage extends BaseDemoPage {
  const ParticleCustomizationPage({super.key});

  @override
  State<ParticleCustomizationPage> createState() =>
      _ParticleCustomizationPageState();
}

class _ParticleCustomizationPageState
    extends BaseDemoPageState<ParticleCustomizationPage> {
  final ExplodeController _smallCtrl = ExplodeController();
  final ExplodeController _largeCtrl = ExplodeController();
  final ExplodeController _countCtrl = ExplodeController();

  @override
  Widget build(BuildContext context) {
    return buildPageLayout(
      onResetAll: () {
        _smallCtrl.reset();
        _largeCtrl.reset();
        _countCtrl.reset();
      },
      children: [
        DemoItem(
          label: "Small Particles (Size: 2)",
          controller: _smallCtrl,
          onReset: _smallCtrl.reset,
          child: Explode(
            controller: _smallCtrl,
            particleSize: 2,
            child: _buildCircle(Colors.indigo, "Small"),
          ),
        ),
        DemoItem(
          label: "Large Particles (Size: 10)",
          controller: _largeCtrl,
          onReset: _largeCtrl.reset,
          child: Explode(
            controller: _largeCtrl,
            particleSize: 10,
            child: _buildCircle(Colors.amber, "Large"),
          ),
        ),
        DemoItem(
          label: "Exact Count (50 particles)",
          controller: _countCtrl,
          onReset: _countCtrl.reset,
          child: Explode(
            controller: _countCtrl,
            particleCount: 50,
            particleSize: 8, // Make them visible
            child: _buildCircle(Colors.cyan, "Fixed Count"),
          ),
        ),
      ],
    );
  }

  Widget _buildCircle(Color color, String text) {
    return CircleAvatar(
      radius: 40,
      backgroundColor: color,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Page 4: Complex UI
// -----------------------------------------------------------------------------
class ComplexUIDemoPage extends BaseDemoPage {
  const ComplexUIDemoPage({super.key});

  @override
  State<ComplexUIDemoPage> createState() => _ComplexUIDemoPageState();
}

class _ComplexUIDemoPageState extends BaseDemoPageState<ComplexUIDemoPage> {
  final ExplodeController _profileCtrl = ExplodeController();
  final ExplodeController _buttonCtrl = ExplodeController();

  @override
  Widget build(BuildContext context) {
    return buildPageLayout(
      onResetAll: () {
        _profileCtrl.reset();
        _buttonCtrl.reset();
      },
      children: [
        DemoItem(
          label: "Profile Card",
          controller: _profileCtrl,
          onReset: _profileCtrl.reset,
          child: Explode(
            controller: _profileCtrl,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=12',
                      ),
                      radius: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "John Doe",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Text(
                            "Software Engineer",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        DemoItem(
          label: "Action Button",
          controller: _buttonCtrl,
          onReset: _buttonCtrl.reset,
          child: Explode(
            controller: _buttonCtrl,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pink, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "Delete Account",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Page 5: Explode Area
// -----------------------------------------------------------------------------
class ExplodeAreaDemoPage extends BaseDemoPage {
  const ExplodeAreaDemoPage({super.key});

  @override
  State<ExplodeAreaDemoPage> createState() => _ExplodeAreaDemoPageState();
}

class _ExplodeAreaDemoPageState extends BaseDemoPageState<ExplodeAreaDemoPage> {
  final ExplodeController _smallAreaCtrl = ExplodeController();
  final ExplodeController _largeAreaCtrl = ExplodeController();

  @override
  Widget build(BuildContext context) {
    return buildPageLayout(
      onResetAll: () {
        _smallAreaCtrl.reset();
        _largeAreaCtrl.reset();
      },
      children: [
        DemoItem(
          label: "Small Explode Area (100x100)",
          controller: _smallAreaCtrl,
          onReset: _smallAreaCtrl.reset,
          child: Explode(
            controller: _smallAreaCtrl,
            explodeArea: const Size(100, 100),
            child: _buildAreaBox(
              "Small (100x100)",
              Icons.zoom_in_map,
              Colors.teal,
            ),
          ),
        ),
        SizedBox(height: 100),
        DemoItem(
          label: "Large Explode Area (600x600)",
          controller: _largeAreaCtrl,
          onReset: _largeAreaCtrl.reset,
          child: Explode(
            controller: _largeAreaCtrl,
            explodeArea: const Size(600, 600),
            child: _buildAreaBox(
              "Large (600x600)",
              Icons.zoom_out_map,
              Colors.indigo,
            ),
          ),
        ),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildAreaBox(String label, IconData icon, Color color) {
    return Container(
      width: 110,
      height: 90,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
