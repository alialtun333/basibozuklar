import 'package:flutter/material.dart';

import '../services/app_data.dart';
import '../services/helpers.dart';

// ============================================================
// ENVANTER EKRANI
// ============================================================
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});
  @override
  Widget build(BuildContext c) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.amber,
      title: const Text(
        'ENVANTER',
        style: TextStyle(
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inventoryList.length,
      itemBuilder: (c, i) {
        final e = inventoryList[i];
        final zimmetli = e.owner != '-';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Icon(
                zimmetli ? Icons.person : Icons.warehouse,
                color: zimmetli ? Colors.red : Colors.green,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      e.category,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: zimmetli
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  zimmetli ? 'Zimmetli' : 'Depoda',
                  style: TextStyle(
                    color: zimmetli ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

// ============================================================
// ZİMMET GEÇMİŞİ EKRANI
// ============================================================
class ZimmetLogScreen extends StatefulWidget {
  const ZimmetLogScreen({super.key});
  @override
  State<ZimmetLogScreen> createState() => _ZLS();
}

class _ZLS extends State<ZimmetLogScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext c) {
    final filtered = _filter == 'all'
        ? zimmetLogs
        : zimmetLogs
              .where(
                (l) => l.action.toLowerCase().contains(_filter.toLowerCase()),
              )
              .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
        title: const Text(
          'ZİMMET GEÇMİŞİ',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: const Color(0xFF121212),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                _filterBtn('all', 'Tümü'),
                const SizedBox(width: 6),
                _filterBtn('zimmetlendi', 'Zimmet'),
                const SizedBox(width: 6),
                _filterBtn('iade', 'İade'),
              ],
            ),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, color: Colors.white38, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'Henüz zimmet işlemi yok.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (c, i) {
                final l = filtered[i];
                final isZimmet = l.action.toLowerCase().contains('zimmet');
                final col = isZimmet ? Colors.red : Colors.green;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: col.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: col.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isZimmet ? Icons.arrow_upward : Icons.arrow_downward,
                          color: col,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l.itemName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: col.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l.action,
                                    style: TextStyle(
                                      color: col,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.white38,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l.userName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Admin: ${l.adminName}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  fmtDT(l.timestamp),
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _filterBtn(String val, String label) => Expanded(
    child: InkWell(
      onTap: () => setState(() => _filter = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _filter == val ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _filter == val ? Colors.amber : Colors.white24,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: _filter == val ? Colors.black : Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}
