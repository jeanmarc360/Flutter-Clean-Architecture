# flutter_provider

Projet Flutter de démonstration d'une architecture **Clean Architecture** avec **Riverpod** comme système de gestion d'état et d'injection de dépendances.

---

## Stack technique

| Librairie | Rôle |
|---|---|
| `flutter_riverpod` + `riverpod_annotation` | Gestion d'état & injection de dépendances |
| `riverpod_generator` | Génération de code pour les providers |
| `dio` | Client HTTP |
| `retrofit` | Génération de code pour les appels API typés |
| `freezed` | Classes immuables & unions |
| `json_serializable` | Sérialisation JSON |

---

## Architecture

Le projet suit les principes de la **Clean Architecture** organisée par **feature**. Chaque feature est divisée en 3 couches indépendantes.

```
lib/
├── core/
│   ├── failure/         # Classes d'erreur abstraites
│   └── network/         # Configuration Dio (provider global)
│
├── features/
│   └── auth/
│       ├── domain/      # Couche métier (aucune dépendance externe)
│       ├── data/        # Couche données (implémentations concrètes)
│       └── presentation/ # Couche UI (widgets, controllers, états)
│
└── main.dart
```

---

## Les 3 couches

### 1. Domain (couche métier)

La couche la plus interne, **sans aucune dépendance** vers Flutter ou les librairies tierces.

```
domain/
├── entities/
│   └── user.dart           # Entité pure User (id, name, token)
├── repositories/
│   └── auth_repository.dart # Interface abstraite du repository
└── usecases/
    └── login_usecase.dart   # Cas d'usage : appelle le repository via l'interface
```

### 2. Data (couche données)

Implémente les contrats définis par le domaine. Communique avec l'extérieur (API, base de données).

```
data/
├── api/
│   └── auth_api.dart              # Client Retrofit (@POST /login)
├── datasources/
│   └── auth_remote_datasource.dart # Orchestre les appels API
├── models/
│   └── user_model.dart            # DTO Freezed + fromJson/toJson
├── mappers/
│   └── user_mapper.dart           # Extension UserModel → User (entité)
└── repositories/
    └── auth_repository_impl.dart  # Implémentation concrète d'AuthRepository
```

### 3. Presentation (couche UI)

Contient les widgets et la logique de présentation. Ne connaît pas la couche data.

```
presentation/
├── pages/
│   └── login_page.dart        # ConsumerWidget qui observe AuthController
├── controller/
│   └── auth_controller.dart   # Notifier Riverpod : orchestrate les use cases
└── state/
    └── auth_state.dart        # État immuable (Freezed) : isLoading, user, error
```

---

## Flux de données

```
LoginPage
  └─► AuthController.login(email, password)
        └─► LoginUseCase.call(email, password)
              └─► AuthRepository (interface)
                    └─► AuthRepositoryImpl.login(email, password)
                          └─► AuthRemoteDataSource.login(email, password)
                                └─► AuthApi.login(body)   ← Retrofit / Dio
                                      └─► POST /login

                          UserModel ──[UserMapper]──► User (entité)
        AuthController met à jour AuthState (user / error / isLoading)
  LoginPage se reconstruit via ref.watch(authControllerProvider)
```

---

## Injection de dépendances avec Riverpod

Toutes les dépendances sont câblées via des providers générés (`@riverpod`). La chaîne complète est :

```
dioProvider
  └─► authApiProvider
        └─► authRemoteDataSourceProvider
              └─► authRepositoryProvider
                    └─► loginUseCaseProvider
                          └─► authControllerProvider
```

Chaque provider déclare explicitement ses dépendances via `ref.watch(...)`, ce qui rend le graphe de dépendances entièrement traçable et testable.

---

## Génération de code

Après toute modification des fichiers annotés (`@riverpod`, `@freezed`, `@RestApi`, `@JsonSerializable`) :

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Lancer l'application

```bash
flutter pub get
flutter run
```
