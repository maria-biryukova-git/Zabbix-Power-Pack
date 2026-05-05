<#
.SYNOPSIS
    Проверка даты выпуска антивирусных баз Kaspersky Security Center.
    Для Zabbix Active Agent Trapper.

.DESCRIPTION
    Скрипт получает дату последнего обновления баз из реестра KSC
    и возвращает JSON для Zabbix: статус базы и разницу в днях.
#>

# Путь к реестру KSC
$RegPath = "HKLM:\SOFTWARE\Wow6432Node\KasperskyLab\Components\34\107\106\0x00001f90\0x00005280\StatInfo"

# Ключи
$CurrentDbReleaseDate = "CurrentDbReleaseDate"

try {
    # Получаем дату из реестра
    $InstallTime = Get-ItemProperty -Path $RegPath -Name $CurrentDbReleaseDate -ErrorAction Stop
    $DbDateValue = $InstallTime.$CurrentDbReleaseDate

    # Преобразуем Unix Timestamp в DateTime (если нужно)
    try {
        $DbDate = [DateTime]::ParseExact($DbDateValue, "yyyy-MM-dd HH:mm:ss", $null)
    } catch {
        $DbDate = [DateTime]::Parse($DbDateValue)
    }

    # Разница в днях
    $DaysDiff = [math]::Round(((Get-Date) - $DbDate).TotalDays, 1)

    # Определяем статус
    if ($DaysDiff -le 1) {
        $Status = 0  # OK
        $StatusText = "Актуальны"
    } elseif ($DaysDiff -le 3) {
        $Status = 1  # Warning
        $StatusText = "Требуется обновление"
    } else {
        $Status = 2  # Critical
        $StatusText = "Устарели"
    }

} catch {
    $DaysDiff = -1
    $Status = 3  # Unknown
    $StatusText = "Ошибка получения данных из реестра"
}

# Вывод JSON для Zabbix Trapper
$Output = [PSCustomObject]@{
    hostname        = $env:COMPUTERNAME
    db_status       = $Status
    db_status_text  = $StatusText
    db_days_old     = $DaysDiff
    check_timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

$Output | ConvertTo-Json -Compress
