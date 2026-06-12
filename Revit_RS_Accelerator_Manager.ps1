<#
.SYNOPSIS
    Терминальный менеджер Revit Server Accelerator для разных версий Revit.

.DESCRIPTION
    Скрипт добавляет, изменяет, показывает и удаляет пользовательские переменные окружения:
    RSACCELERATOR2018, RSACCELERATOR2019, ... RSACCELERATOR2026

    После изменения настроек Revit нужно перезапустить.

.NOTES
    Запуск:
    powershell.exe -ExecutionPolicy Bypass -File .\Revit_RS_Accelerator_Manager.ps1
#>

$ErrorActionPreference = 'Stop'

# Список поддерживаемых версий. При необходимости добавьте сюда новые годы.
$Script:RevitVersions = 2018..2026

function Write-Header {
    Clear-Host
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host "        Revit Server Accelerator - PowerShell Manager" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor DarkCyan
    Write-Host ""
}

function Pause-Menu {
    Write-Host ""
    Read-Host "Нажмите Enter, чтобы вернуться в меню" | Out-Null
}

function Get-AcceleratorVariableName {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Version
    )
    return "RSACCELERATOR$Version"
}

function Get-AcceleratorValue {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Version
    )

    $name = Get-AcceleratorVariableName -Version $Version
    return [Environment]::GetEnvironmentVariable($name, 'User')
}

function Set-AcceleratorValue {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Version,

        [Parameter(Mandatory = $true)]
        [string]$Address
    )

    $name = Get-AcceleratorVariableName -Version $Version
    [Environment]::SetEnvironmentVariable($name, $Address, 'User')
}

function Remove-AcceleratorValue {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Version
    )

    $name = Get-AcceleratorVariableName -Version $Version
    [Environment]::SetEnvironmentVariable($name, $null, 'User')
}

function Update-EnvironmentBroadcast {
    # Сообщаем Windows, что переменные окружения изменились.
    # Это помогает новым процессам увидеть изменения без выхода из системы.
    try {
        $signature = @'
using System;
using System.Runtime.InteropServices;

public static class EnvironmentNotifier
{
    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd,
        uint Msg,
        UIntPtr wParam,
        string lParam,
        uint fuFlags,
        uint uTimeout,
        out UIntPtr lpdwResult);
}
'@
        if (-not ('EnvironmentNotifier' -as [type])) {
            Add-Type -TypeDefinition $signature | Out-Null
        }

        $HWND_BROADCAST = [IntPtr]0xffff
        $WM_SETTINGCHANGE = 0x1A
        $SMTO_ABORTIFHUNG = 0x0002
        $result = [UIntPtr]::Zero

        [EnvironmentNotifier]::SendMessageTimeout(
            $HWND_BROADCAST,
            $WM_SETTINGCHANGE,
            [UIntPtr]::Zero,
            'Environment',
            $SMTO_ABORTIFHUNG,
            5000,
            [ref]$result
        ) | Out-Null
    }
    catch {
        Write-Host "Предупреждение: не удалось отправить системное уведомление об изменении переменных." -ForegroundColor Yellow
    }
}

function Test-AcceleratorAddress {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Address
    )

    # Разрешаем IP, DNS-имя, порт, дефисы, точки и подчёркивания.
    # Не делаем слишком строгую проверку, чтобы не мешать реальным внутренним адресам.
    return ($Address.Trim().Length -gt 0 -and $Address -match '^[a-zA-Z0-9._:-]+$')
}

function Read-AcceleratorAddress {
    while ($true) {
        Write-Host "Введите адрес акселератора" -ForegroundColor Cyan
        Write-Host "Пример: 192.168.88.21 или revit-accel.company.local" -ForegroundColor DarkGray
        $address = Read-Host "Адрес"
        $address = $address.Trim()

        if (Test-AcceleratorAddress -Address $address) {
            return $address
        }

        Write-Host "Адрес пустой или содержит странные символы. Попробуйте ещё раз." -ForegroundColor Yellow
        Write-Host ""
    }
}

function Show-Status {
    Write-Header
    Write-Host "Текущие настройки:" -ForegroundColor White
    Write-Host ""

    foreach ($version in $Script:RevitVersions) {
        $name = Get-AcceleratorVariableName -Version $version
        $value = Get-AcceleratorValue -Version $version

        if ([string]::IsNullOrWhiteSpace($value)) {
            Write-Host ("{0,-17} : не задано" -f $name) -ForegroundColor DarkGray
        }
        else {
            Write-Host ("{0,-17} : {1}" -f $name, $value) -ForegroundColor Green
        }
    }
}

function Select-RevitVersion {
    while ($true) {
        Write-Header
        Write-Host "Выберите версию Revit:" -ForegroundColor White
        Write-Host ""

        for ($i = 0; $i -lt $Script:RevitVersions.Count; $i++) {
            $version = $Script:RevitVersions[$i]
            $value = Get-AcceleratorValue -Version $version
            $status = if ([string]::IsNullOrWhiteSpace($value)) { "не задано" } else { $value }
            Write-Host ("  {0,2}. Revit {1}   [{2}]" -f ($i + 1), $version, $status)
        }

        Write-Host ""
        Write-Host "  0. Назад" -ForegroundColor DarkGray
        Write-Host ""

        $choice = Read-Host "Номер версии"

        if ($choice -eq '0') {
            return $null
        }

        $number = 0
        if ([int]::TryParse($choice, [ref]$number)) {
            if ($number -ge 1 -and $number -le $Script:RevitVersions.Count) {
                return [int]$Script:RevitVersions[$number - 1]
            }
        }

        Write-Host "Неверный выбор. Введите номер из списка." -ForegroundColor Yellow
        Start-Sleep -Milliseconds 900
    }
}

function Confirm-Action {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Question
    )

    $answer = Read-Host "$Question [Y/N]"
    return ($answer -match '^(y|yes|д|да)$')
}

function Set-OneVersion {
    $version = Select-RevitVersion
    if ($null -eq $version) { return }

    Write-Header
    Write-Host "Настройка Revit $version" -ForegroundColor White
    Write-Host ""
    $address = Read-AcceleratorAddress

    Set-AcceleratorValue -Version $version -Address $address
    Update-EnvironmentBroadcast

    Write-Host ""
    Write-Host "Готово: RSACCELERATOR$version = $address" -ForegroundColor Green
    Write-Host "Перезапустите Revit $version, чтобы настройка применилась." -ForegroundColor Yellow
    Pause-Menu
}

function Set-AllVersions {
    Write-Header
    Write-Host "Настройка акселератора для всех версий Revit" -ForegroundColor White
    Write-Host ""
    $address = Read-AcceleratorAddress

    Write-Host ""
    if (-not (Confirm-Action -Question "Задать адрес '$address' для всех версий $($Script:RevitVersions -join ', ')?")) {
        Write-Host "Отменено." -ForegroundColor Yellow
        Pause-Menu
        return
    }

    foreach ($version in $Script:RevitVersions) {
        Set-AcceleratorValue -Version $version -Address $address
    }

    Update-EnvironmentBroadcast

    Write-Host ""
    Write-Host "Готово: адрес задан для всех версий." -ForegroundColor Green
    Write-Host "Перезапустите Revit, чтобы настройка применилась." -ForegroundColor Yellow
    Pause-Menu
}

function Remove-OneVersion {
    $version = Select-RevitVersion
    if ($null -eq $version) { return }

    Write-Header
    Write-Host "Отключение акселератора для Revit $version" -ForegroundColor White
    Write-Host ""

    if (-not (Confirm-Action -Question "Удалить RSACCELERATOR$version?")) {
        Write-Host "Отменено." -ForegroundColor Yellow
        Pause-Menu
        return
    }

    Remove-AcceleratorValue -Version $version
    Update-EnvironmentBroadcast

    Write-Host ""
    Write-Host "Готово: акселератор для Revit $version отключён." -ForegroundColor Green
    Write-Host "Перезапустите Revit $version, чтобы настройка применилась." -ForegroundColor Yellow
    Pause-Menu
}

function Remove-AllVersions {
    Write-Header
    Write-Host "Отключение акселератора для всех версий Revit" -ForegroundColor White
    Write-Host ""

    if (-not (Confirm-Action -Question "Удалить RSACCELERATOR для всех версий?")) {
        Write-Host "Отменено." -ForegroundColor Yellow
        Pause-Menu
        return
    }

    foreach ($version in $Script:RevitVersions) {
        Remove-AcceleratorValue -Version $version
    }

    Update-EnvironmentBroadcast

    Write-Host ""
    Write-Host "Готово: акселератор отключён для всех версий." -ForegroundColor Green
    Write-Host "Перезапустите Revit, чтобы настройка применилась." -ForegroundColor Yellow
    Pause-Menu
}

function Main-Menu {
    while ($true) {
        Write-Header
        Write-Host "  1. Добавить / изменить акселератор для выбранной версии" -ForegroundColor White
        Write-Host "  2. Добавить / изменить акселератор для всех версий" -ForegroundColor White
        Write-Host "  3. Отключить акселератор для выбранной версии" -ForegroundColor White
        Write-Host "  4. Отключить акселератор для всех версий" -ForegroundColor White
        Write-Host "  5. Показать текущие настройки" -ForegroundColor White
        Write-Host "  0. Выход" -ForegroundColor DarkGray
        Write-Host ""

        $choice = Read-Host "Выберите действие"

        switch ($choice) {
            '1' { Set-OneVersion }
            '2' { Set-AllVersions }
            '3' { Remove-OneVersion }
            '4' { Remove-AllVersions }
            '5' { Show-Status; Pause-Menu }
            '0' { return }
            default {
                Write-Host "Неверный выбор. Попробуйте ещё раз." -ForegroundColor Yellow
                Start-Sleep -Milliseconds 900
            }
        }
    }
}

try {
    Main-Menu
}
catch {
    Write-Host ""
    Write-Host "Ошибка: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Скрипт остановлен." -ForegroundColor Red
    Pause-Menu
}
