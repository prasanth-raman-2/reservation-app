import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reservation_model.dart';
import '../providers/reservation_provider.dart';
import '../widgets/reservation_card.dart';
import 'reservation_detail_screen.dart';
import 'reservation_form_screen.dart';

/// Screen that displays a list of reservations
class ReservationListScreen extends ConsumerWidget {
  const ReservationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(reservationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: reservationsAsync.when(
        data: (reservations) {
          if (reservations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No Reservations',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tap the + button to create a new reservation',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return ReservationCard(
                reservation: reservation,
                onTap: () => _navigateToDetail(context, reservation),
                onEdit: () => _navigateToEdit(context, reservation),
                onDelete: () => _deleteReservation(context, ref, reservation),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreate(context),
        tooltip: 'Add Reservation',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Navigate to the reservation detail screen
  void _navigateToDetail(BuildContext context, Reservation reservation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReservationDetailScreen(reservation: reservation),
      ),
    );
  }

  /// Navigate to the reservation form screen for editing
  void _navigateToEdit(BuildContext context, Reservation reservation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReservationFormScreen(reservation: reservation),
      ),
    );
  }

  /// Navigate to the reservation form screen for creating
  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ReservationFormScreen(),
      ),
    );
  }

  /// Delete a reservation
  void _deleteReservation(BuildContext context, WidgetRef ref, Reservation reservation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reservation'),
        content: const Text('Are you sure you want to delete this reservation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref
                    .read(reservationNotifierProvider.notifier)
                    .deleteReservation(reservation.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reservation deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
