# App

Generated with flutter_blueprint using **Riverpod 2.x** state management.

## Getting Started

```bash
# Install dependencies
flutter pub get

# Generate Riverpod providers (run after modifying providers)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Riverpod 2.x Features

- ✅ **Notifier pattern** - Modern replacement for StateNotifier
- ✅ **AsyncNotifier** - Built-in async state with loading/error handling
- ✅ **Code generation** - Type-safe providers with @riverpod annotation
- ✅ **GoRouter integration** - Declarative, type-safe routing
- ✅ **Compile-time safety** - No runtime provider lookup errors
- ✅ **riverpod_lint** - Specialized lint rules for best practices

## Project Structure

```
lib/
├── main.dart                          # App entry point with ProviderScope
├── app/
│   └── app.dart                       # MaterialApp.router with Riverpod
├── core/
│   ├── providers/                     # Global providers
│   │   └── app_providers.dart         # App-wide providers (@Riverpod)
│   ├── routing/
│   │   └── app_router.dart            # GoRouter with Riverpod
│   └── ...                            # Theme, API, Storage, Utils
└── features/
    └── home/
        └── presentation/
            ├── providers/
            │   └── home_provider.dart  # Feature providers (@riverpod)
            ├── pages/
            └── widgets/
```

## Provider Patterns

### Sync State (Notifier)
```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
}
```

### Async Data (AsyncNotifier)
```dart
@riverpod
class Items extends _$Items {
  @override
  Future<List<Item>> build() async {
    return await api.fetchItems();
  }
  
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => api.fetchItems());
  }
}
```

### Family Providers (Parameterized)
```dart
@riverpod
Future<User> userDetail(UserDetailRef ref, {required String id}) async {
  return ref.read(apiClientProvider).getUser(id);
}

// Usage: ref.watch(userDetailProvider(id: '123'))
```

## Configuration

- **State Management**: riverpod
- **Platform**: mobile

