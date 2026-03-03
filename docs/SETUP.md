# SETUP.md - Guia de Configuração (estado atual)

Este guia descreve o setup real do projeto `meu-app`, já com plugin custom para navegação Ionic <-> Flutter.

## Pré-requisitos

- Node.js 18+
- Flutter SDK 3.x no PATH
- Android Studio + Android SDK
- Xcode 15+
- CocoaPods
- Java 22 (build Android local)

## Estrutura alvo

- Ionic/Capacitor: `meu-app`
- Flutter module: `meu-app/flutter_module`
- Plugin TS: `meu-app/src/plugins/flutter-router`
- Plugin Android: `meu-app/android/app/src/main/java/io/ionic/starter/plugins`
- Plugin iOS: `meu-app/ios/App/App/FlutterRouterPlugin.swift`

## Fluxo de navegação

1. Ionic chama `navigateTo` no plugin `FlutterRouter`
2. Native abre Flutter (`HybridFlutterActivity` no Android / `FlutterViewController` no iOS)
3. Flutter retorna com `goBack` no MethodChannel `com.example.hybrid/flutter_router`
4. Plugin resolve a Promise no Ionic com o payload de retorno

## Comandos recomendados

Na raiz de `meu-app`:

# Android (build + sync + assembleDebug)

npm run cap:sync:android:flutter

# iOS (build + sync + reinjecao do plugin + pod install)

npm run cap:sync:ios:flutter

# Ambos

npm run cap:sync:all:flutter

## Validação Android

cd meu-app
npm run cap:sync:android:flutter

Saída esperada: `BUILD SUCCESSFUL` no Gradle (`android/app` debug).

## Validação iOS

cd meu-app
npm run cap:sync:ios:flutter
cd ios/App
xcodebuild -workspace App.xcworkspace -scheme App -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build

Saída esperada: build concluído sem erros de compilação.

## Observações importantes

- Após `cap sync ios`, o script `scripts/ensure-ios-flutter-router.mjs` garante reinjeção do `FlutterRouterPlugin` no `capacitor.config.json` iOS.
- Warnings de script `[CP-User] ... Flutter Build ...` no iOS podem aparecer e não bloqueiam o build.
- Se o Android falhar por JDK, confirme que o Java 22 está instalado e acessível via `JAVA_HOME`.
