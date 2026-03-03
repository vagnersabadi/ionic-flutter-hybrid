# Ionic + Flutter Hybrid (meu-app)

Projeto híbrido com navegação bidirecional entre Ionic (Capacitor) e Flutter Add-to-App.

## Estado atual

- App principal: `meu-app`
- Flutter module integrado: `meu-app/flutter_module`
- Fluxo implementado: Ionic -> Flutter -> Ionic (Android e iOS)
- Plugin custom: `FlutterRouter` (TypeScript + Kotlin + Swift)

## Estrutura relevante

    meu-app/
    |-- src/plugins/flutter-router/      Bridge TypeScript do Capacitor
    |-- src/app/home/                    Botao para abrir tela Flutter
    |-- flutter_module/lib/main.dart     Tela Flutter + retorno via MethodChannel
    |-- android/app/src/main/java/...    Plugin Android + Activity Flutter
    +-- ios/App/App/                     Plugin iOS + AppDelegate

## Fluxo de navegação

1. Ionic chama `FlutterRouter.navigateTo({ route, params })`
2. Plugin nativo abre a tela Flutter
3. Flutter chama `MethodChannel("com.example.hybrid/flutter_router").invokeMethod("goBack", data)`
4. Plugin fecha Flutter e resolve a Promise no Ionic com `data`

## Uso no Ionic

    import { FlutterRouterPlugin } from '../plugins/flutter-router/flutter-router.plugin';

    const result = await FlutterRouterPlugin.navigateTo({
      route: '/flutter-home',
      params: { source: 'ionic' }
    });

    console.log(result.completed);
    console.log(result.data);

## Scripts (meu-app/package.json)

- `npm run cap:sync:android:flutter`
  - build web, sync Android e gera `assembleDebug` (usa Java 22)
- `npm run cap:sync:ios:flutter`
  - build web, sync iOS, re-injeta plugin iOS custom e executa `pod install`
- `npm run cap:sync:all:flutter`
  - executa Android + iOS em sequência

## Pré-requisitos

- Node.js 18+
- Flutter SDK 3.x
- Android Studio (SDK Android)
- Xcode 15+
- CocoaPods (`pod`)
- Java 22 para build Android local

## Build rápido

    cd meu-app

    # Android
    npm run cap:sync:android:flutter

    # iOS
    npm run cap:sync:ios:flutter
    cd ios/App
    xcodebuild -workspace App.xcworkspace -scheme App -configuration Debug -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build

Mais detalhes em `docs/SETUP.md`.
