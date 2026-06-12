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

## Запуск напрямую из GitHub

Откройте PowerShell и выполните:

```powershell
irm https://raw.githubusercontent.com/Viend1211/Revit_RS_Accelerator_Manager/main/Revit_RS_Accelerator_Manager.ps1 | iex
```

или

```powershell
Invoke-RestMethod `
    https://raw.githubusercontent.com/Viend1211/Revit_RS_Accelerator_Manager/main/Revit_RS_Accelerator_Manager.ps1 | Invoke-Expression
```

## Скачать и запустить

```powershell
$Script = "$env:TEMP\Revit_RS_Accelerator_Manager.ps1"

Invoke-WebRequest `
    -Uri "https://raw.githubusercontent.com/Viend1211/Revit_RS_Accelerator_Manager/main/Revit_RS_Accelerator_Manager.ps1" `
    -OutFile $Script

powershell.exe -ExecutionPolicy Bypass -File $Script
```

## Однострочный запуск

```powershell
$F="$env:TEMP\Revit_RS_Accelerator_Manager.ps1";iwr "https://raw.githubusercontent.com/Viend1211/Revit_RS_Accelerator_Manager/main/Revit_RS_Accelerator_Manager.ps1" -OutFile $F;powershell -ExecutionPolicy Bypass -File $F
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
