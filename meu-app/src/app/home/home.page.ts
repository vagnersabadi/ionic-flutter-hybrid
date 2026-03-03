import { Component } from '@angular/core';
import { IonHeader, IonToolbar, IonTitle, IonContent, IonButton } from '@ionic/angular/standalone';
import { FlutterRouterPlugin } from '../../plugins/flutter-router/flutter-router.plugin';

@Component({
  selector: 'app-home',
  templateUrl: './home.page.html',
  styleUrls: ['./home.page.scss'],
  imports: [IonHeader, IonToolbar, IonTitle, IonContent, IonButton],
})
export class HomePage {
  async openFlutterPage() {
    await FlutterRouterPlugin.navigateTo({
      route: '/flutter-home',
      params: {
        from: 'ionic-home',
      },
    });
  }
}
