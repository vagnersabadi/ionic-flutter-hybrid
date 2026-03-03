# SETUP.md - Guia de Configuracao

## Pre-requisitos

- Node.js 18+ | npm install -g @ionic/cli @capacitor/cli
- Flutter SDK 3.x no PATH
- Android Studio + SDK (Android 33+)
- Xcode 15+ (iOS)

## PASSO 1 - Criar Projeto Ionic 7

ionic start meu-app blank --type=angular --capacitor
cd meu-app
ionic capacitor add android
ionic capacitor add ios

## PASSO 2 - Criar Flutter Module

flutter create --template=module flutter_module

## PASSO 3 - Integrar no Android

a) Copie FlutterRouterPlugin.kt para:
android/app/src/main/java/com/example/ionicflutterhybrid/plugins/

b) Copie MainActivity.kt para:
android/app/src/main/java/com/example/ionicflutterhybrid/

c) Aplique settings.gradle.patch ao android/settings.gradle

Observacao importante: "aplicar patch" aqui significa mesclar o conteudo do patch no arquivo,

Trecho final esperado em android/settings.gradle:

- manter `apply from: 'capacitor.settings.gradle'`
- adicionar:
  setBinding(new Binding([gradle: this]))
  apply from: '../flutter_module/.android/include_flutter.groovy'

d) Aplique build.gradle.patch ao android/app/build.gradle

Adicione a dependencia abaixo dentro de `dependencies {}` em android/app/build.gradle:
implementation project(':flutter')

## PASSO 4 - Integrar no iOS

a) Copie FlutterRouterPlugin.swift para ios/App/App/

b) Aplique Podfile.patch ao ios/App/Podfile

c) cd ios && pod install

## PASSO 5 - Build Android

ionic build
npx cap sync android
cd android && ./gradlew assembleDebug

## PASSO 6 - Build iOS

ionic build
npx cap sync ios
npx cap open ios

## Fluxo de Navegacao

Ionic Page
--> FlutterRouterPlugin.navigateTo({ route: '/flutter-home' })
--> FlutterActivity (Android) / FlutterViewController (iOS)
--> Flutter GoRouter navega para rota
--> MethodChannel.invokeMethod('goBack')
--> Ionic Promise resolvida, app volta

## Performance - Engine Pre-aquecido (Android recomendado)

No Application.onCreate():
val engine = FlutterEngine(this)
engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
FlutterEngineCache.getInstance().put("main_engine", engine)

No plugin, use withCachedEngine("main_engine") para navegacao instantanea.
