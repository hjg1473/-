import 'package:block_english/services/super_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuperGroupCreateScreen extends ConsumerStatefulWidget {
  const SuperGroupCreateScreen({super.key});

  @override
  ConsumerState<SuperGroupCreateScreen> createState() =>
      _SuperGroupCreateScreenState();
}

class _SuperGroupCreateScreenState
    extends ConsumerState<SuperGroupCreateScreen> {
  @override
  Widget build(BuildContext context) {
    String groupName = '';

    void onCreateGroup() async {
      // Create group
      if (groupName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('그룹명을 입력해주세요'),
          ),
        );
        return;
      }

      final result =
          await ref.watch(superServiceProvider).postCreateGroup(groupName);
      debugPrint('result: $result');

      result.fold((failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('실패.. ${failure.detail}'),
            ),
          );
        }
      }, (success) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/super_main_screen',
            (Route<dynamic> route) => false,
          );
        }
      });
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('그룹 생성'),
          backgroundColor: Colors.white,
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  ' 학습 그룹명',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                TextField(
                  onChanged: (value) => groupName = value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: '학습 그룹명을 입력해주세요',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 17),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(width: 0, style: BorderStyle.none),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: onCreateGroup,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    '생성하기',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            )));
  }
}
