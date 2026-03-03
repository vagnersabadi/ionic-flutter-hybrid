import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { FlutterRouterPlugin } from '../../plugins/flutter-router/flutter-router.plugin';

@Component({
  selector: 'app-about',
  templateUrl: './about.page.html',
  styleUrls: ['./about.page.scss']
})
export class AboutPage {
  migrationStatus = [
    { page: 'Home', status: 'ionic', label: 'Em uso (Ionic)' },
    { page: 'About', status: 'ionic', label: 'Em uso (Ionic)' },
    { page: 'Flutter Home', status: 'flutter', label: 'Migrado (Flutter)' },
    { page: 'Flutter Detail', status: 'flutter', label: 'Migrado (Flutter)' },
  ];

  constructor(private router: Router) {}

  goBack() {
    this.router.navigate(['/home']);
  }

  async openFlutterDetail() {
    await FlutterRouterPlugin.navigateTo({
      route: '/flutter-detail',
      params: { source: 'about-page' }
    });
  }
}
