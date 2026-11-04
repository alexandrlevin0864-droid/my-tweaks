# Cydia Tweak Repo

Репозиторий твиков для jailbreak (iOS).

## Твики

| Твик | Описание |
|------|----------|
| [NSC16](NSC16/) | Настольные часы при зарядке iPhone в горизонтальной ориентации (iOS 16) |

## Установка

Сборка через [Theos](https://theos.dev):

```bash
cd NSC16
make package
```

Готовый `.deb` появится в `packages/` — установи через Sileo/Zebra или `dpkg`.