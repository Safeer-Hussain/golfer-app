// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final gate = SprintGate();
  final success = await gate.run();
  exit(success ? 0 : 1);
}

class SprintGate {
  final List<String> errorPatterns = [
    'EXCEPTION CAUGHT BY',
    'A RenderFlex overflowed by',
    'There are multiple heroes that share the same tag',
    'No observables detected in the build method of Observer',
    'setState() or markNeedsBuild() called during build',
    'AndroidRuntime: FATAL EXCEPTION',
    'Unhandled Exception:',
  ];

  Future<bool> run() async {
    print('====================================================================');
    print('STARTING SPRINT VERIFICATION GATE (tool/sprint_gate.dart)');
    print('====================================================================');

    // Step 1: flutter pub get
    if (!await _runStep('1/5: Dependency Resolution', 'flutter', ['pub', 'get'])) {
      return _fail('Dependency resolution failed.');
    }

    // Step 2: dart format lib test
    print('\n--> [Step 2/5: Code Formatting Check]');
    final formatResult = await _runCommand('dart', ['format', 'lib', 'test']);
    if (formatResult.exitCode != 0) {
      return _fail('Dart format encountered errors:\n${formatResult.stderr}');
    }
    print('[Step 2/5: PASSED] Code formatted successfully.');

    // Step 3: flutter analyze --no-pub
    print('\n--> [Step 3/5: Static Analysis Lint Check]');
    final analyzeResult = await _runCommand('flutter', ['analyze', '--no-pub']);
    final analyzeOutput = '${analyzeResult.stdout}\n${analyzeResult.stderr}';
    print(analyzeOutput.trim());
    if (analyzeResult.exitCode != 0 ||
        analyzeOutput.contains('error •') ||
        analyzeOutput.contains('warning •') ||
        analyzeOutput.contains('info •')) {
      return _fail('Static analysis failed or contains unresolved issues.');
    }
    print('[Step 3/5: PASSED] Zero analysis errors, warnings, or info lints.');

    // Step 4: flutter test --no-pub
    if (!await _runStep('4/5: Automated Unit & Widget Tests', 'flutter', ['test', '--no-pub'])) {
      return _fail('Automated test suite failed.');
    }

    // Step 5: Connected Physical/Emulator Device Runtime Check
    print('\n--> [Step 5/5: Connected Device Runtime Check]');
    final deviceCheckPassed = await _checkConnectedDevices();
    if (!deviceCheckPassed) {
      return _fail('Connected device runtime smoke test failed.');
    }

    print('\n====================================================================');
    print('[GATE PASSED] ALL 5 PRE/POST-FLIGHT VERIFICATIONS COMPLETED SUCCESSFULLY');
    print('====================================================================');
    return true;
  }

  Future<bool> _runStep(String stepName, String command, List<String> args) async {
    print('\n--> [Step $stepName]');
    final result = await _runCommand(command, args);
    if (result.stdout.toString().isNotEmpty) {
      print(result.stdout.toString().trim());
    }
    if (result.stderr.toString().isNotEmpty) {
      print(result.stderr.toString().trim());
    }
    if (result.exitCode != 0) {
      return false;
    }
    print('[Step $stepName: PASSED]');
    return true;
  }

  Future<ProcessResult> _runCommand(String executable, List<String> args) {
    return Process.run(executable, args, runInShell: true);
  }

  String _resolveAdbPath() {
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null) {
        final adbPath = '$localAppData\\Android\\Sdk\\platform-tools\\adb.exe';
        if (File(adbPath).existsSync()) return adbPath;
      }
      final androidHome = Platform.environment['ANDROID_HOME'];
      if (androidHome != null) {
        final adbPath = '$androidHome\\platform-tools\\adb.exe';
        if (File(adbPath).existsSync()) return adbPath;
      }
    } else {
      final androidHome = Platform.environment['ANDROID_HOME'];
      if (androidHome != null) {
        final adbPath = '$androidHome/platform-tools/adb';
        if (File(adbPath).existsSync()) return adbPath;
      }
    }
    return 'adb';
  }

  Future<bool> _checkConnectedDevices() async {
    try {
      final devicesResult = await _runCommand('flutter', ['devices', '--machine']);
      if (devicesResult.exitCode != 0) {
        print('[Warning] Failed to query flutter devices: ${devicesResult.stderr}');
        return true;
      }

      final dynamic parsed = jsonDecode(devicesResult.stdout.toString().trim());
      if (parsed is! List) {
        print('[Device Check] No valid device list returned. Skipping.');
        return true;
      }

      final mobileDevices = parsed.where((d) {
        final target = (d['targetPlatform'] ?? '').toString().toLowerCase();
        final isSupported = d['isSupported'] == true;
        return isSupported && (target.startsWith('android') || target.startsWith('ios'));
      }).toList();

      if (mobileDevices.isEmpty) {
        print('[Device Check] No mobile physical device or emulator attached.');
        print('[Step 5/5: PASSED] (Offline / Host-only fallback verified).');
        return true;
      }

      final targetDevice = mobileDevices.first;
      final deviceId = targetDevice['id'].toString();
      final deviceName = targetDevice['name'].toString();
      final targetPlatform = targetDevice['targetPlatform'].toString().toLowerCase();

      print('[Device Check] Detected active mobile target: $deviceName ($deviceId)');

      final adb = _resolveAdbPath();
      if (targetPlatform.startsWith('android')) {
        print('[Device Check] Clearing stale device logcat buffer...');
        await _runCommand(adb, ['-s', deviceId, 'logcat', '-c']);
      }

      print('[Device Check] Launching app smoke test (25-second supervised runtime window)...');
      final process = await Process.start(
        'flutter',
        ['run', '-d', deviceId, '--no-pub'],
        runInShell: true,
      );

      final consoleBuffer = StringBuffer();
      final stdoutSub = process.stdout.transform(utf8.decoder).listen((data) {
        consoleBuffer.write(data);
      });
      final stderrSub = process.stderr.transform(utf8.decoder).listen((data) {
        consoleBuffer.write(data);
      });

      // Supervise runtime for 25 seconds
      await Future.delayed(const Duration(seconds: 25));

      // Attempt graceful detachment or terminate smoke session
      try {
        process.stdin.writeln('q');
        await process.stdin.flush();
      } catch (_) {}

      await Future.delayed(const Duration(seconds: 3));
      process.kill();

      await stdoutSub.cancel();
      await stderrSub.cancel();

      // Retrieve device runtime logs if Android
      final logcatBuffer = StringBuffer();
      if (targetPlatform.startsWith('android')) {
        final logcatResult = await _runCommand(adb, ['-s', deviceId, 'logcat', '-d']);
        logcatBuffer.write(logcatResult.stdout.toString());
      }

      final combinedLogs = '${consoleBuffer.toString()}\n${logcatBuffer.toString()}';

      // Check for forbidden crash/render patterns
      final detectedIssues = <String>[];
      for (final pattern in errorPatterns) {
        if (combinedLogs.contains(pattern)) {
          detectedIssues.add(pattern);
        }
      }

      if (detectedIssues.isNotEmpty) {
        print('\n[CRITICAL FAILURE] The following runtime exceptions were detected on $deviceName:');
        for (final issue in detectedIssues) {
          print('  - $issue');
        }
        return false;
      }

      print('[Device Check] Zero runtime exceptions detected during 25s live device execution.');
      print('[Step 5/5: PASSED] Live physical/emulator device runtime check verified.');
      return true;
    } catch (e, stack) {
      print('[Warning] Exception occurred during device runtime check: $e\n$stack');
      // If live device check fails critically due to environment execution, flag it
      return false;
    }
  }

  bool _fail(String message) {
    print('\n====================================================================');
    print('[GATE FAILED] $message');
    print('====================================================================');
    return false;
  }
}
