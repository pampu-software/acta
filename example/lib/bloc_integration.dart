import 'package:acta/acta.dart';
import 'package:bloc/bloc.dart';

/// A [BlocObserver] implemented in the app side that reports errors to Acta.
/// This demonstrates how to integrate Acta with Bloc without requiring
/// Acta to depend on the bloc package.
class ActaBlocObserver extends BlocObserver {
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    ActaJournal.report(
      event: ErrorEvent(
        message: 'Bloc error in ${bloc.runtimeType}',
        exception: error,
        stackTrace: stackTrace,
        severity: Severity.critical, // Using critical as error level
        metadata: {
          'bloc': bloc.runtimeType.toString(),
        },
      ),
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    ActaJournal.addBreadcrumb(
      'Bloc change in ${bloc.runtimeType}',
      data: {
        'bloc': bloc.runtimeType.toString(),
        'currentState': change.currentState.toString(),
        'nextState': change.nextState.toString(),
      },
    );
  }
}
