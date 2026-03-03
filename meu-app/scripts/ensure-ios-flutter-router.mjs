import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const configPath = resolve(process.cwd(), 'ios/App/App/capacitor.config.json');
const pluginClass = 'FlutterRouterPlugin';

const raw = readFileSync(configPath, 'utf8');
const config = JSON.parse(raw);

if (!Array.isArray(config.packageClassList)) {
  config.packageClassList = [];
}

if (!config.packageClassList.includes(pluginClass)) {
  config.packageClassList.unshift(pluginClass);
  writeFileSync(configPath, `${JSON.stringify(config, null, '\t')}\n`, 'utf8');
  console.log(`[hybrid] Added ${pluginClass} to ios/App/App/capacitor.config.json`);
} else {
  console.log(`[hybrid] ${pluginClass} already present in ios/App/App/capacitor.config.json`);
}
