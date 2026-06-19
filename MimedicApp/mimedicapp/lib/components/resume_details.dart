import 'package:flutter/material.dart';

class ResumeRow {
  final String label;
  final String value;
  ResumeRow(this.label, this.value);
}

class ResumeDetailsCard extends StatelessWidget {
  final String title;
  final List<ResumeRow> rows;
  final VoidCallback? onClose;

  const ResumeDetailsCard({
    super.key,
    required this.title,
    required this.rows,
    this.onClose,
  });

  void _safeClose(BuildContext context) {
    onClose?.call();
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isWide ? 520 : MediaQuery.of(context).size.width - 32,
        ),
        child: Material(
          color: Colors.white,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 6),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF2C1E4A),
                    ),
                  ),
                ),
                const Divider(height: 8),
                const SizedBox(height: 8),

                ...rows.map((r) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              r.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C1E4A),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              r.value,
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
