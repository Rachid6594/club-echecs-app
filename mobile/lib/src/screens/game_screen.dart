import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Echiquier')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _ClockPanel(),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: 64,
              itemBuilder: (context, index) {
                final row = index ~/ 8;
                final col = index % 8;
                final dark = (row + col).isOdd;
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF1F5F9),
                  ),
                  child: Center(
                    child: Text(
                      _pieceAt(index),
                      style: TextStyle(
                        fontSize: 22,
                        color: dark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showDrawDialog(context),
                  child: const Text('Proposer nul'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => _showResignDialog(context),
                  child: const Text('Abandonner'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _pieceAt(int index) {
    const pieces = {
      0: '♜',
      1: '♞',
      2: '♝',
      3: '♛',
      4: '♚',
      5: '♝',
      6: '♞',
      7: '♜',
      8: '♟',
      9: '♟',
      10: '♟',
      11: '♟',
      12: '♟',
      13: '♟',
      14: '♟',
      15: '♟',
      48: '♙',
      49: '♙',
      50: '♙',
      51: '♙',
      52: '♙',
      53: '♙',
      54: '♙',
      55: '♙',
      56: '♖',
      57: '♘',
      58: '♗',
      59: '♕',
      60: '♔',
      61: '♗',
      62: '♘',
      63: '♖',
    };
    return pieces[index] ?? '';
  }

  static void _showDrawDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Proposition de nul'),
        content: const Text(
          'Envoyer une proposition de nul a votre adversaire ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  static void _showResignDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Abandon'),
        content: const Text('Confirmer abandonner cette partie ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Oui'),
          ),
        ],
      ),
    );
  }
}

class _ClockPanel extends StatelessWidget {
  const _ClockPanel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _ClockCard(label: 'Blancs', time: '05:00'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _ClockCard(label: 'Noirs', time: '05:00'),
        ),
      ],
    );
  }
}

class _ClockCard extends StatelessWidget {
  const _ClockCard({required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Text(label),
            Text(
              time,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
