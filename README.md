# Ionic 7 + Flutter Hybrid

Projeto hibrido que permite a **migracao gradual do Ionic 7 para Flutter**,
compartilhando as pastas android/ e ios/ entre os dois frameworks.

---

## Estrutura do Projeto

    ionic-flutter-hybrid/
    |-- ionic-app/                       Host principal (Ionic 7 + Capacitor)
    |   |-- src/
    |   |   |-- app/                     AppModule + Routing Angular
    |   |   |-- pages/
    |   |   |   |-- home/               Pagina 1 (Ionic)
    |   |   |   +-- about/              Pagina 2 (Ionic)
    |   |   +-- plugins/flutter-router/ Plugin de rota customizado
    |   |       |-- flutter-router.plugin.ts  registerPlugin Capacitor
    |   |       |-- definitions.ts            Interfaces TypeScript
    |   |       +-- flutter-router.web.ts     Fallback browser (dev)
    |   |-- android-plugin/
    |   |   |-- FlutterRouterPlugin.kt   Implementacao Android (Kotlin)
    |   |   |-- MainActivity.kt          Registro do plugin
    |   |   |-- settings.gradle.patch    Integra flutter_module no build
    |   |   +-- build.gradle.patch       Adiciona dependencia :flutter
    |   +-- ios-plugin/
    |       |-- FlutterRouterPlugin.swift Implementacao iOS (Swift)
    |       +-- Podfile.patch             Integracao via podhelper.rb
    |
    |-- flutter_module/                  Flutter Add-to-App (modulo)
    |   +-- lib/
    |       |-- main.dart               GoRouter + MethodChannel listener
    |       +-- pages/
    |           |-- flutter_home.dart   Tela Flutter 1
    |           +-- flutter_detail.dart Tela Flutter 2
    |
    +-- docs/
        +-- SETUP.md                    Guia completo passo a passo

---

## Conceito Principal

| Camada      | Tecnologia          | Papel                              |
| ----------- | ------------------- | ---------------------------------- |
| Host nativo | Ionic 7 + Capacitor | Gera o APK/IPA, controla o ciclo   |
| Web layer   | Angular + Ionic UI  | Paginas sendo mantidas ou migradas |
| Flutter     | Add-to-App Module   | Paginas ja migradas para Flutter   |
| Bridge      | FlutterRouterPlugin | Navegacao bidirecional             |

O Flutter e criado com --template=module (nao e um app standalone),
entao nao gera suas proprias pastas nativas. Ele e compilado como
.aar no Android e framework pod no iOS, dentro das pastas do Ionic.

---

## Fluxo de Navegacao

    [Pagina Ionic]
          |
          | FlutterRouterPlugin.navigateTo({ route: "/flutter-home" })
          v
    [FlutterRouterPlugin.kt / .swift]
          |
          | Android -> FlutterActivity com initialRoute
          | iOS     -> FlutterViewController apresentado modalmente
          v
    [Flutter App -- GoRouter navega para a rota]
          |
          | MethodChannel.invokeMethod("goBack", { returnData })
          v
    [FlutterRouterPlugin resolve() a PluginCall]
          |
          v
    [Ionic -- Promise resolvida, app retorna ao estado anterior]

---

## Como Usar o Plugin de Navegacao

### Ionic para Flutter

    import { FlutterRouterPlugin } from "../../plugins/flutter-router/flutter-router.plugin";

    const result = await FlutterRouterPlugin.navigateTo({
      route: "/flutter-home",
      params: { userId: "123", message: "Ola do Ionic!" }
    });
    console.log(result.completed); // true se voltou normalmente
    console.log(result.data);      // dados retornados pelo Flutter

### Flutter para Ionic (voltar)

    const channel = MethodChannel("com.example.hybrid/flutter_router");
    await channel.invokeMethod("goBack", {
      "returnedFrom": "flutter-home",
      "selectedItem": "produto-42",
    });

---

## Pre-requisitos

- Node.js 18+ -- npm install -g @ionic/cli @capacitor/cli
- Flutter SDK 3.x no PATH -- flutter doctor
- Android Studio com Android SDK 33+
- Xcode 15+ (para builds iOS)

---

## Setup Rapido

    # 1. Criar o projeto Ionic 7
    ionic start meu-app blank --type=angular --capacitor
    cd meu-app
    ionic capacitor add android
    ionic capacitor add ios

    # 2. Criar o Flutter Module
    flutter create --template=module flutter_module

    # 3. Copiar os arquivos deste repo (ver docs/SETUP.md)
    #    e mesclar os patches nos arquivos Gradle
    #    (nao usar apply from para arquivos .patch)

    # 4. Build Android
    ionic build && npx cap sync android
    cd android && ./gradlew assembleDebug

    # 5. Build iOS
    ionic build && npx cap sync ios
    cd ios && pod install
    npx cap open ios

Veja docs/SETUP.md para o guia completo com todos os patches.

---

## Por que as Pastas Nativas Sao Compartilhadas?

O Flutter em modo Add-to-App nao gera android/ e ios/ proprias.
Ele e empacotado como:

- Android: biblioteca .aar incluida via settings.gradle
- iOS: CocoaPod incluido via podhelper.rb no Podfile

As pastas nativas pertencem ao Ionic/Capacitor e o Flutter Engine
e embutido dentro delas -- um unico APK/IPA para os dois frameworks.

---

## Estrategia de Migracao Gradual

    Sprint 1:  Ionic 100% -> Flutter  0%    Setup inicial do hibrido
    Sprint 2:  Ionic  75% -> Flutter 25%    Migrar telas de detalhe
    Sprint 3:  Ionic  50% -> Flutter 50%    Migrar fluxos principais
    Sprint N:  Ionic   0% -> Flutter 100%   Remover Capacitor/Ionic

A cada sprint, substitua paginas Ionic por Flutter adicionando novas
rotas no GoRouter e atualizando as chamadas navigateTo() existentes.

---

## Performance -- Engine Pre-aquecido (Android)

Para navegacao instantanea sem delay na primeira abertura:

    // Application.kt
    class MyApplication : FlutterApplication() {
        override fun onCreate() {
            super.onCreate()
            val engine = FlutterEngine(this)
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )
            FlutterEngineCache.getInstance().put("main_engine", engine)
        }
    }

    // No FlutterRouterPlugin.kt, substitua withNewEngine() por:
    FlutterActivity.withCachedEngine("main_engine").build(activity)

---

## Licenca

MIT
