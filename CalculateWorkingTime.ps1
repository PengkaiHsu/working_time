
# 工数を集計するためのロジック。
# 課題：Split, 

# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# chcp 932
# chcp 65001

$file_data = Get-Content -Encoding UTF8 C:\Programming\PowerShell\WorkingTime\working_time\input_sample.md

# 総時間
$totalTime = 0

# チャージ項目
$Works = [System.Collections.Generic.Dictionary[String, PSObject]]::new()

# チャージ項目詳細
$WorksDetail = [System.Collections.Generic.Dictionary[String, String]]::new()

foreach ($row in $file_data)
{
  if ($row.StartsWith("## ")){    
    ## 日付の行の処理 ##

    $date = ($row.Split("## ") | select -First 1 -Last 1)[1]
    Write-Host $date
    Write-Host ""
    
    $totalTime = 0  

  } elseif ($row.StartsWith("- ") -And !($row.Contains("休憩"))){    
    ## 工数の行の処理 ##
    
    # この行の工数計算
    $timeSlot = $row.Substring(2, 11) # 時間帯を取得
    $strStart = ($timeSlot.Split(" ~ ") | select -First 1 -Last 1)[0]
    $strEnd = ($timeSlot.Split(" ~ ") | select -First 1 -Last 1)[1]
    $dateTimeStart = [DateTime]::ParseExact($strStart,"HHmm", $null)
    $dateTimeEnd = [DateTime]::ParseExact($strEnd,"HHmm", $null)
    
    $timeLength = ($dateTimeEnd - $dateTimeStart)
    $totalTime = $totalTime + $timeLength.TotalMinutes

    # この行のチャージ項目判断（ex. LogieTool - 開発定例）
    $work = (($row.Split(":") | select -First 1 -Last 1)[1]).trim()

    if ($work.Contains("-")){

        # チャージ項目名（ex. LogieTool）
        $workName = (($work.Split(" - ") | select -First 1 -Last 1)[0])

        # チャージ項目詳細（ex. 開発定例）
        $workDetail = (($work.Split("-") | select -First 1 -Last 1)[1]).trim()
    }else{

        # チャージ項目名（ex. LogieTool）
        $workName = $work

        # チャージ項目詳細（なし）
        $workDetail = ""
    }
    
    # チャージ項目名ごとの総工数を計算して格納
    if($Works.ContainsKey($workName)){
        $Works[$workName] += $timeLength.TotalMinutes
    }else{
        $Works.Add($workName, $timeLength.TotalMinutes)
    }

    # チャージ項目詳細を重複なしで格納
    if($WorksDetail.ContainsKey($workDetail)){
    }else{
        $WorksDetail.Add($workDetail, $workName)
    }
  } 
}

$totalPercentage = 0
foreach($key in $Works.Keys)
{
    $value = $Works.$key
    $timePercentage = $value / $totalTime
    $totalPercentage += $timePercentage
    $timePercentage = $timePercentage * 100
    Write-Host "$key : $value 分 : $timePercentage %"
}

Write-Host ""
Write-Host "Total percentage = " $totalPercentage
Write-Host ""

foreach($key in $WorksDetail.Keys)
{
    $value = $WorksDetail.$key
    Write-Host "$($value): $key"
}
