library rx_future;

import 'package:async/async.dart';
import 'package:get/get.dart';

/// determine what to happen one more the one call are triggered.
enum MultipleCallsBehavior {
  /// always abort new calls and keep the state of old one
  abortNew,

  /// always abort old call and start a new one.
  abortOld
}

/// This class is a subtype of RX, you could use it to observe future state
/// loading, error and result.
/// use .observe() method to trigger the state
class RxFuture<T> extends Rx<_FutureState<T>> {
  // @attrs
  /// store the previous result of the future.
  late T lastResult;

  CancelableOperation<T>? _cancelableOperation;

  // @constructors
  RxFuture(this.lastResult) : super(_FutureState(lastResult));

  // @getters
  /// The result of future.
  T get result => value.value;

  /// Error object threw by the future.
  Object? get error => value.error;

  /// Whether state is loading or not.
  bool get loading => value.isLoading;

  /// Whether this state has error or not.
  bool get hasError => value.hasError;

  /// Whether this state is stable so it is not loading and there is no error.
  bool get isStable => !loading && error != null;

  // @methods
  /// the main function for RxFuture which used to trigger the state
  /// [callback] The future to be called that return type is [T].
  ///
  /// [onSuccess] Triggered when future done, take parameter as the last value of type [T].
  ///
  /// [onError] Triggered when future throw error, take parameter of type [Object] as an error.
  ///
  /// [onCancel] Triggered when the future canceled, by using cancel() method.
  ///
  /// [onMultipleCalls] Triggered when this function called more than once.
  ///
  /// [multipleCallsBehavior] Determine what happen when this function called more than once, default value is abortNew.
  ///
  /// ``` dart
  /// RxFuture<int> observable = RxFuture<int>(0);
  ///
  /// observable.observe(
  ///   (previousValue) async {
  ///     // for example you could use the previous value to determine the new value.
  ///     return await someFuture(previousValue);
  ///   },
  ///   onSuccess: (res) {
  ///     // when future done.
  ///     print(res); // the result of this future.
  ///   },
  ///   onError: (error) {
  ///     print(error); // error threw by the future.
  ///   },
  ///   onCancel: () {
  ///     print("future canceled");
  ///   }
  /// );
  /// ```
  Future<void> observe(
    Future<T> Function(T?) callback, {
    void Function(T)? onSuccess,
    void Function(Object)? onError,
    void Function()? onMultipleCalls,
    void Function()? onCancel,
    MultipleCallsBehavior multipleCallsBehavior =
        MultipleCallsBehavior.abortNew,
  }) async {
    if (loading) {
      onMultipleCalls?.call();
      if (multipleCallsBehavior == MultipleCallsBehavior.abortNew) return;
      _cancelableOperation?.cancel();
    }

    _cancelableOperation = CancelableOperation<T>.fromFuture(
      callback(result),
      onCancel: () {
        onCancel?.call();
        _setError(null);
        _setLoading(false);
      },
    );

    try {
      _setLoading(true);
      _setError(null);

      T? res = await _cancelableOperation?.value;

      if (res != null) {
        lastResult = result;
        _setResult(res);
      }

      onSuccess?.call(result);
    } catch (e) {
      _setError(e);

      onError?.call(e);
    } finally {
      _setLoading(false);
    }
  }

  /// used to cancel the current future that running,
  /// it want throw any exception when no future is running.
  ///
  /// this would trigger onCancel hook
  void cancel() {
    _cancelableOperation?.cancel();
  }

  //@setters
  void _setLoading(bool v) {
    update((val) {
      val!.setLoading(v);
    });
  }

  void _setError(Object? v) {
    update((val) {
      val!.setError(v);
    });
  }

  void _setResult(T v) {
    update((val) {
      val!.value = v;
    });
  }
}

class _FutureState<T> {
  // @attrs
  bool _isLoading = false;

  Object? _error;

  T value;

  // @constructors
  _FutureState(this.value);

  // @getters
  bool get isLoading => _isLoading;

  bool get hasError => error != null;

  bool get hasValue => value != null;

  Object? get error => _error;

  // @setters
  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(Object? e) {
    _error = e;
  }
}
