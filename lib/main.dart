
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const IsolateDemoApp());
}

// Tác vụ tính toán nặng dùng chung cho cả hai phương pháp.
// Hàm top-level để có thể truyền vào compute().
int heavyCalculation(int iterations) {
  int result = 0;

  for (int i = 0; i < iterations; i++) {
    result = (result + ((i * 31) ^ (i >> 3))) & 0x7fffffff;
  }

  return result;
}

class IsolateDemoApp extends StatelessWidget {
  const IsolateDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Isolate Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const IsolateDemoPage(),
    );
  }
}

class IsolateDemoPage extends StatefulWidget {
  const IsolateDemoPage({super.key});

  @override
  State<IsolateDemoPage> createState() => _IsolateDemoPageState();
}

class _IsolateDemoPageState extends State<IsolateDemoPage>
    with TickerProviderStateMixin {
  static const int iterations = 100000000;

  late final AnimationController mainAnimation;
  late final AnimationController computeAnimation;

  bool isRunning = false;

  String mainStatus = 'Sẵn sàng';
  String computeStatus = 'Sẵn sàng';

  int? mainResult;
  int? computeResult;

  int? mainTime;
  int? computeTime;

  @override
  void initState() {
    super.initState();

    // Animation khu vực Main Thread.
    mainAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Animation khu vực compute().
    computeAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    mainAnimation.dispose();
    computeAnimation.dispose();
    super.dispose();
  }

  // Cách 1: Chạy trực tiếp trên UI isolate.
  Future<void> runMainThread() async {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      mainStatus = 'Đang tính toán...';
      mainResult = null;
      mainTime = null;
    });

    // Cho giao diện cập nhật trạng thái trước khi tính.
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final stopwatch = Stopwatch()..start();

    // CỐ Ý chặn UI isolate để minh họa hiện tượng khựng.
    final result = heavyCalculation(iterations);

    stopwatch.stop();

    if (!mounted) return;

    setState(() {
      isRunning = false;
      mainStatus = 'Hoàn thành';
      mainResult = result;
      mainTime = stopwatch.elapsedMilliseconds;
    });
  }

  // Cách 2: Chạy trong Isolate bằng compute().
  Future<void> runWithCompute() async {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      computeStatus = 'Đang tính trong Isolate...';
      computeResult = null;
      computeTime = null;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    final stopwatch = Stopwatch()..start();

    try {
      final result = await compute<int, int>(
        heavyCalculation,
        iterations,
        debugLabel: 'heavyCalculation',
      );

      stopwatch.stop();

      if (!mounted) return;

      setState(() {
        isRunning = false;
        computeStatus = 'Hoàn thành';
        computeResult = result;
        computeTime = stopwatch.elapsedMilliseconds;
      });
    } catch (error) {
      stopwatch.stop();

      if (!mounted) return;

      setState(() {
        isRunning = false;
        computeStatus = 'Có lỗi xảy ra';
      });

      debugPrint('compute() error: $error');
    }
  }

  // Widget dùng chung để tạo mỗi khu vực demo.
  Widget buildDemoPanel({
    required String title,
    required String description,
    required Color color,
    required AnimationController animation,
    required String status,
    required int? result,
    required int? elapsedMs,
    required VoidCallback onPressed,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 24),

            // Animation xoay liên tục.
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: animation.value * 2 * math.pi,
                  child: child,
                );
              },
              child: Icon(
                Icons.sync,
                size: 76,
                color: color,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Thời gian: ${elapsedMs == null ? "--" : "$elapsedMs ms"}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              'Kết quả: ${result ?? "--"}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            FilledButton(
              onPressed: isRunning ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text(
                isRunning ? 'Đang chạy...' : 'Chạy tác vụ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Isolate Demo'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                const Text(
                  'So sánh Main Thread và compute()',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Cùng thực hiện $iterations vòng lặp',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 20),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final mainPanel = buildDemoPanel(
                      title: '1. Main Thread',
                      description:
                          'Tính toán trực tiếp trên luồng giao diện',
                      color: Colors.red.shade700,
                      animation: mainAnimation,
                      status: mainStatus,
                      result: mainResult,
                      elapsedMs: mainTime,
                      onPressed: runMainThread,
                    );

                    final computePanel = buildDemoPanel(
                      title: '2. compute()',
                      description:
                          'Tính toán trong Isolate riêng',
                      color: Colors.green.shade700,
                      animation: computeAnimation,
                      status: computeStatus,
                      result: computeResult,
                      elapsedMs: computeTime,
                      onPressed: runWithCompute,
                    );

                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          mainPanel,
                          computePanel,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: mainPanel),
                        Expanded(child: computePanel),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
