# spark_chat

适用于讯飞星火大模型 V3.0 的跨平台客户端

## 0. 使用 fvm 配置 flutter 版本

```bash
fvm install
```

## 1. 安装依赖

```bash
fvm flutter pub get
```

## 2. 配置密钥

在根目录创建 `.env` 写入密钥

```bash
# APIKEY & APISECRET from https://console.xfyun.cn/services/bm3
APPID='xxxxxxxx'
APIKEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
APISECRET='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

## 3. 运行

```bash
fvm flutter run
```

## 4. 打包

- 生成 icons

```bash
cd ./macos/Runner/Assets.xcassets
iconutil -c icns AppIcon.iconset -o app_icon.icns
```

- build dmg  
  
```bash
appdmg ./Installers/dmg_creator/config.json ./Installers/dmg_creator/spark_chat.dmg
```

## TODO

- [ ] Chat History Local Storage
- [ ] Custom Actions
- [ ] One Step Mode
