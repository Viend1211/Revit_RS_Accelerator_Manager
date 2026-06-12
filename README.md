# Revit RS Accelerator Manager

PowerShell-скрипт для управления переменными окружения **Revit Server Accelerator** для разных версий Autodesk Revit.

Скрипт позволяет через терминальное меню:

* добавить адрес Revit Server Accelerator для выбранной версии Revit;
* добавить один адрес сразу для всех поддерживаемых версий;
* отключить Accelerator для выбранной версии;
* отключить Accelerator сразу для всех версий;
* посмотреть текущие значения переменных.

Поддерживаемые версии в текущем скрипте: **Revit 2018–2026**.

## Запуск

1. Скачайте файл:

```text
Revit_RS_Accelerator_Manager.ps1
```

2. Откройте PowerShell в папке со скриптом.

3. Запустите команду:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Revit_RS_Accelerator_Manager.ps1
```

## Быстрый запуск из PowerShell

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Revit_RS_Accelerator_Manager.ps1
```

## Что изменяет скрипт

Скрипт управляет пользовательскими переменными окружения Windows:

```text
RSACCELERATOR2018
RSACCELERATOR2019
RSACCELERATOR2020
RSACCELERATOR2021
RSACCELERATOR2022
RSACCELERATOR2023
RSACCELERATOR2024
RSACCELERATOR2025
RSACCELERATOR2026
```

Пример значения:

```text
192.168.88.21
```

После изменения настроек необходимо перезапустить Revit.

## Пример использования

1. Запустите скрипт.
2. Выберите действие в меню.
3. Выберите версию Revit или пункт для всех версий.
4. Введите адрес Accelerator, например:

```text
192.168.88.21
```

5. Перезапустите Revit.

## Требования

* Windows
* PowerShell
* Autodesk Revit с поддержкой Revit Server Accelerator

## Примечание

Скрипт изменяет переменные окружения текущего пользователя.
Для применения изменений в уже запущенном Revit требуется перезапуск программы.

## Автор

Viend1211
