# Architecture — Flutter Clean Architecture

Ce projet suit la **Clean Architecture** organisée par **feature**. Chaque feature est découpée en trois couches isolées : `data`, `domain`, `presentation`.

```
lib/
├── core/
│   ├── error/                       # Result, Failure, ExceptionMapper
│   ├── local/                       # BaseLocalDatasource, HiveService
│   └── network/                     # Dio, BaseHttpInterceptor, HttpInterceptor, safeApiCall
├── features/
│   └── auth/
│       ├── data/                    # Couche données (API, modèles, datasources, repository)
│       ├── domain/                  # Couche métier (entités, use cases, contrats)
│       └── presentation/            # Couche UI (screens, controllers, état)
└── hive_registrar.g.dart            # Adapters Hive générés automatiquement
```

---

## Flux de données

```
UI (Screen)
  └── Controller (Riverpod)
        └── Use Case
              └── Repository (interface)
                    └── RepositoryImpl
                          ├── RemoteDataSource → API (Retrofit + Dio)
                          └── LocalDataSource  → Hive (chiffré AES)
```

La règle fondamentale : **les dépendances pointent toujours vers le domaine**, jamais vers l'extérieur.

---

## Couche `domain` — Le cœur métier

> Ne dépend de rien d'autre. Pure Dart, aucun import Flutter ou package externe.

### Entités

Objets métier purs. Ils représentent ce que l'application manipule.

```
lib/features/auth/domain/entities/auth_token.dart
```

```dart
class AuthToken {
  final String idToken;
  final String accessToken;
  final String refreshToken;
  final String refreshTokenExpireTime;
  final String accessTokenExpireTime;
}
```

- Pas de `fromJson` / `toJson` — ce n'est pas leur rôle.
- Pas d'annotation de framework.
- Ils changent uniquement si la **règle métier** change.

### Repository (interface)

Contrat que la couche `data` doit respecter. Le domaine décide de ce dont il a besoin, sans savoir comment c'est implémenté.

```
lib/features/auth/domain/repositories/auth_repository.dart
```

```dart
abstract class AuthRepository {
  Future<Result<AuthToken>> login(String email, String password);
}
```

### Use Cases

Chaque use case = une seule action utilisateur. Ils orchestrent les appels au repository et appliquent les règles métier.

```
lib/features/auth/domain/usecases/login_usecase.dart
```

```dart
@riverpod
LoginUseCase loginUseCase(Ref ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Result<AuthToken>> login(String email, String password) {
    return repository.login(email, password);
  }
}
```

**Ce qui va dans le use case (et non dans le controller) :**

- Validation métier (ex : format email, longueur mot de passe)
- Orchestration de plusieurs repositories dans l'ordre
- Règles de transformation ou de mise en cache
- Toute logique réutilisable par plusieurs écrans

---

## Couche `data` — L'accès aux données

> Implémente les contrats du domaine. Connait les APIs, les modèles JSON, le stockage.

### Models

Miroir des entités, mais conçus pour la sérialisation JSON (`json_annotation`) **et** le stockage Hive (`hive_ce`). Le mapping vers l'entité est porté par le modèle lui-même via `toEntity()`.

```
lib/features/auth/data/models/auth_token_model.dart
```

```dart
@JsonSerializable()
@HiveType(typeId: 0)
class AuthTokenModel {
  @HiveField(0) final String idToken;
  @HiveField(1) final String accessToken;
  // ...

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  AuthToken toEntity() => AuthToken(
    idToken: idToken,
    accessToken: accessToken,
    // ...
  );
}
```

Différence avec l'entité :

|              | Entité (`AuthToken`)          | Modèle (`AuthTokenModel`)           |
|--------------|-------------------------------|-------------------------------------|
| Rôle         | Représenter le concept métier | Sérialiser JSON + persister en Hive |
| Dépendances  | Aucune                        | `json_annotation`, `hive_ce`        |
| Utilisé par  | Use cases, domain             | DataSource, Repository              |
| Mapping      | —                             | `.toEntity()` intégré               |

### API (Retrofit)

Définit les endpoints HTTP. Retrofit génère l'implémentation via `build_runner`.

```
lib/features/auth/data/api/auth_api.dart
```

```dart
@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {required String baseUrl}) = _AuthApi;

  @POST('/login')
  Future<AuthTokenModel> login(@Body() Map<String, dynamic> body);
}
```

### DataSources

**RemoteDataSource** — Couche entre l'API et le repository. Prépare les appels réseau.

```
lib/features/auth/data/datasources/auth_remote_datasource.dart
```

```dart
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.watch(authApiProvider));

class AuthRemoteDataSource {
  final AuthApi api;

  Future<AuthTokenModel> login(String email, String password) {
    return api.login({'email': email, 'password': password});
  }
}
```

**LocalDataSource** — Stockage local chiffré via Hive. Étend `BaseLocalDatasource<AuthTokenModel>`.

```
lib/features/auth/data/datasources/auth_local_datasource.dart
```

```dart
@riverpod
AuthLocalDataSource authLocalDataSource(Ref ref) => AuthLocalDataSource();

class AuthLocalDataSource extends BaseLocalDatasource<AuthTokenModel> {
  static const boxName = 'auth_tokens';

  @override String get keyBox => boxName;
  @override bool get isSecure => true;   // chiffrement AES activé

  Future<void> saveToken(AuthTokenModel model) => save(model);
  Future<AuthTokenModel?> getToken() => get();
  Future<void> clearToken() => save(null);
}
```

### Repository Implementation

Implémente le contrat du domaine. Orchestre RemoteDataSource + LocalDataSource + mapping.

```
lib/features/auth/data/repositories/auth_repository_impl.dart
```

```dart
@riverpod
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
  ref.watch(authRemoteDataSourceProvider),
  ref.watch(authLocalDataSourceProvider),
);

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  @override
  Future<Result<AuthToken>> login(String email, String password) =>
      safeApiCall(() async {
        final model = await remote.login(email, password);
        await local.saveToken(model);   // persistance locale
        return model.toEntity();        // mapping → entité
      });
}
```

---

## Couche `presentation` — L'interface utilisateur

> Ne connait que les use cases. Ne sait pas d'où viennent les données.

### State (Freezed)

Représente l'état immutable de l'UI à un instant T.

```
lib/features/auth/presentation/state/auth_state.dart
```

```dart
@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    AuthToken? authToken,
    String? error,
  }) = _AuthState;
}
```

### Controller (Riverpod)

Reçoit les actions utilisateur, appelle le use case, met à jour l'état. **Ne contient pas de logique métier.**

```
lib/features/auth/presentation/controller/auth_controller.dart
```

```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await ref.read(loginUseCaseProvider).login(email, password);
    state = result.isSuccess
        ? state.copyWith(isLoading: false, authToken: result.data)
        : state.copyWith(isLoading: false, error: result.error?.message);
  }

  void logout() {
    state = const AuthState();
  }
}
```

### Screen (Widget)

Lit l'état via `ref.watch`, envoie les actions via `ref.read(...notifier)`. Aucune logique.

```
lib/features/auth/presentation/screens/screen_login.dart
```

```dart
class ScreenLogin extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    return state.isLoading
        ? CircularProgressIndicator()
        : ElevatedButton(
            onPressed: () => ref
                .read(authControllerProvider.notifier)
                .login('demo@mail.com', '123456'),
            child: Text('Login'),
          );
  }
}
```

---

## Core — Utilitaires partagés

### Gestion des erreurs (`core/error/`)

**`Result<T>`** — type de retour de tous les use cases et repositories. Remplace les exceptions par des valeurs explicites.

```dart
// Succès
return Success(authToken);

// Échec
return Err(UnauthorizedFailure());

// Consommation
if (result.isSuccess) { use(result.data!); }
else { show(result.error!.message); }
```

**`Failure`** — classe scellée (`sealed class`) des erreurs possibles :

| Failure               | Cas                            |
| --------------------- | ------------------------------ |
| `NetworkFailure`      | Pas de connexion internet      |
| `TimeoutFailure`      | Délai dépassé                  |
| `UnauthorizedFailure` | 401 — token expiré ou invalide |
| `NotFoundFailure`     | 404 — ressource absente        |
| `ValidationFailure`   | 400 / 422 — erreurs de champs  |
| `ServerFailure`       | 5xx — erreur serveur           |
| `UnexpectedFailure`   | Erreur inconnue                |

**`ExceptionMapper`** — convertit toute exception (`DioException`, `SocketException`, etc.) en `Failure` appropriée.

**`safeApiCall`** — wrapper qui intercepte toute exception et la convertit en `Err(Failure)`.

```dart
Future<Result<T>> safeApiCall<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } catch (e) {
    return Err(ExceptionMapper.map(e));
  }
}
```

### Stockage local (`core/local/`)

**`HiveService`** — initialise Hive et enregistre les adapters générés au démarrage de l'app.

```dart
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapters();   // adapters générés dans hive_registrar.g.dart
  }
}
```

**`BaseLocalDatasource<E>`** — classe abstraite générique pour tout stockage Hive. Gère l'ouverture de box (plain ou chiffrée AES), la clé de chiffrement stockée dans `FlutterSecureStorage`, et la récupération automatique en cas de corruption.

```dart
abstract class BaseLocalDatasource<E> {
  String get keyBox;
  bool get isSecure;   // true → chiffrement AES via FlutterSecureStorage

  Future<void> save(E? model);
  Future<E?> get();
  Future<void> deleteBox();
}
```

### Réseau (`core/network/`)

- **`HttpInterceptor`** — ajoute les headers communs (Content-Type, Authorization). Étend `BaseHttpInterceptor`.
- **`BaseHttpInterceptor`** — logs formatés des requêtes, réponses et erreurs en debug.
- **`AuthApi`** (Retrofit) — définit les endpoints, génère le code HTTP via `build_runner`.

---

## Règles de dépendances

```
presentation  →  domain  ←  data
                   ↑
                 core
```

- `presentation` importe `domain` (use cases, entités)
- `data` importe `domain` (implémente les repositories)
- `domain` n'importe **rien** des deux autres couches
- `core` peut être importé par toutes les couches

---

## Commandes utiles

```bash
# Regénérer le code (Riverpod, Retrofit, Freezed, JsonSerializable, Hive)
dart run build_runner build --delete-conflicting-outputs

# Watcher (regénère automatiquement à chaque sauvegarde)
dart run build_runner watch --delete-conflicting-outputs
```
