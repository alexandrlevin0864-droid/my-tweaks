# MY Tweaks — Sileo/Cydia репозиторий

Репозиторий твиков для jailbreak (iOS). Добавь в Sileo/Cydia:

```
https://alexandrlevin0864-droid.github.io/my-tweaks/
```

## Твики

| Твик | Описание |
|------|----------|
| [NSC16](NSC16/) | Настольные часы при зарядке iPhone в горизонтальной ориентации (iOS 16) |

## Сборка пакета

Через [Theos](https://theos.dev):

```bash
cd NSC16
make package DEBUG=0
```

Готовый `.deb` появится в `NSC16/packages/` — скопируй его в `debs/` и перегенерируй индексы репозитория (см. ниже).

## Обновление репозитория

После добавления/изменения пакетов в `debs/`:

```bash
dpkg-scanpackages -m . > Packages
gzip -kf Packages; bzip2 -kf Packages; xz -kf Packages
# перегенерируй Release (контрольные суммы)
git add -A && git commit -m "..." && git push
```