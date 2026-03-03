import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { FlutterRouterPlugin } from '../../plugins/flutter-router/flutter-router.plugin';

@Component({
  selector: 'app-home',
  templateUrl: './home.page.html',
  styleUrls: ['./home.page.scss']
})
export class HomePage implements OnInit {
  title = 'Home Ionic 7';
  isNative = false;

  constructor(private router: Router) {}

  ngOnInit() {
    this.isNative = typeof window !== 'undefined' &&
      !!(window as any).Capacitor?.isNativePlatform?.();
  }

  goToAbout() {
    this.router.navigate(['/about']);
  }

  async goToFlutterHome() {
    await FlutterRouterPlugin.navigateTo({
      route: '/flutter-home',
      params: { from: 'ionic-home', message: 'Ola do Ionic!' }
    });
  }

  async goToFlutterDetail() {
    await FlutterRouterPlugin.navigateTo({
      route: '/flutter-detail',
      params: { itemId: '42', title: 'Produto Exemplo' }
    });
  }
}
