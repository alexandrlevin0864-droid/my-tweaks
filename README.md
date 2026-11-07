# MY Tweaks — Sileo/Cydia репозиторий

<p align="center">
  <img src="repo-cover.jpg" alt="MY Tweaks" width="200">
</p>

Репозиторий твиков для jailbreak (iOS). Добавь в Sileo/Cydia:

```
https://alexandrlevin0864-droid.github.io/my-tweaks/
```

Репозиторий подписан GPG-ключом. Публичный ключ: [`gpg-key.asc`](gpg-key.asc).

Отпечаток: `ED46 2A3A FA2B A16F 24E4  5C20 5A61 5F0E 26E3 13D5`

Пакеты собраны для **rootless** (Dopamine / palera1n) — `iphoneos-arm64`, и для **rootful** — `iphoneos-arm`.

## Твики

| Твик | Описание |
|------|----------|
| [NSC16](NSC16/) | Настольные часы при зарядке iPhone в горизонтальной ориентации (iOS 16) |

## Сборка пакета

Через [Theos](https://theos.dev):

```bash
cd NSC16
make package DEBUG=0 THEOS_PACKAGE_SCHEME=rootless
```

Готовый `.deb` появится в `NSC16/packages/` — скопируй его в `debs/` и перегенерируй индексы репозитория (см. ниже).

## Обновление репозитория

После добавления/изменения пакетов в `debs/`:

```bash
dpkg-scanpackages -m . > Packages
gzip -kf Packages; bzip2 -kf Packages; xz -kf Packages
# перегенерируй Release (контрольные суммы) и подпиши его
gpg --batch --yes --detach-sign -o Release.gpg Release
gpg --batch --yes --clearsign -o InRelease Release
git add -A && git commit -m "..." && git push
```