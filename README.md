# Zabbix-Power-Pack

## Проблематика
В гибридной инфраструктуре на 100+ хостов под защитой KSC
нет штатного способа мониторинга актуальности баз в Zabbix.
Администратор безопасности вынужден заходить в консоль KSC вручную.

## Решение
PowerShell-скрипт + Zabbix Active Agent + Template.

Скрипт извлекает дату последнего обновления баз из реестра KSC,
вычисляет разницу в днях и возвращает JSON в Zabbix Trapper.

## Состав репозитория
- `Check-KSC-Databases.ps1` — основной скрипт
- `zbx_export_kaspersky_bases.yaml` — шаблон Zabbix 6.4
- `screenshots/` — примеры алертов и графиков

## Требования
- Windows Server 2012 R2+
- PowerShell 5.1+
- Kaspersky Security Center 12+
- Zabbix Agent 2 (Active)
- Права локального администратора на хосте с KSC

## Установка

### 1. Настройка агента
Добавьте в `zabbix_agent2.conf`:

### 2. Импорт шаблона
Zabbix → Configuration → Templates → Import → `zbx_export_kaspersky_bases.yaml`

### 3. Привязка к хосту
Привяжите шаблон к хосту, где установлен KSC.

## Адаптация под вашу среду
- Проверьте путь к реестру: `regedit` → `HKEY_LOCAL_MACHINE\SOFTWARE\...`
- При необходимости измените пороговые значения дней в скрипте
