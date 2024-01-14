
# 工数を集計するためのロジック。
# 課題：Split, 

# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# chcp 932
# chcp 65001

$file_data = Get-Content -Encoding UTF8 C:\Programming\PowerShell\WorkingTime\working_time\input_sample.md

# 総時間
$totalTime = 0

# チャージ項目（チャージ項目名、時間）
$Works = [System.Collections.Generic.Dictionary[String, Int]]::new()

# チャージ項目詳細（チャージ項目名、チャージ項目詳細）
$WorksDetail = [System.Collections.Generic.Dictionary[String, String]]::new()

foreach ($row in $file_data)
{
  if ($row.StartsWith("## ")){

    ## 日付の行の処理 ##
    # How does powershell split consecutive strings. Not a single letter: https://stackoverflow.com/questions/76241804/how-does-powershell-split-consecutive-strings-not-a-single-letter
    $date = ($row.Split([string[]] "## ", 'None'))[1]

    # 日付をプリント
    Write-Host `n$date`n

    $totalTime = 0

  } elseif ($row.StartsWith("- ") -And !($row.Contains("休憩"))){    
    
    ## 工数の行の処理 ##
    # この行の工数計算
    $timeSlot = $row.Substring(2, 11) # 時間帯を取得
    $timeStart = ($timeSlot.Split([string[]] " ~ ", 'None'))[0]
    $timeEnd = ($timeSlot.Split([string[]] " ~ ", 'None'))[1]
    $dateTimeStart = [DateTime]::ParseExact($timeStart,"HHmm", $null)
    $dateTimeEnd = [DateTime]::ParseExact($timeEnd,"HHmm", $null)
    
    $timeLength = ($dateTimeEnd - $dateTimeStart)
    $totalTime = $totalTime + $timeLength.TotalMinutes

    # この行のチャージ項目判断（ex. LogieTool - 開発定例）
    $work = (($row.Split([string[]] ": ", 'None'))[1]).trim()

    if ($work.Contains("-")){

        # チャージ項目名（ex. LogieTool）
        $workName = ($work.Split([string[]] " - ", 'None'))[0]

        # チャージ項目詳細（ex. 開発定例）
        $workDetail = (($work.Split([string[]] " - ", 'None'))[1]).trim()
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
    if($WorksDetail.ContainsKey($workName)){
        if ($workDetail -ne ""){
            $WorksDetail[$workName] = $WorksDetail[$workName] + "、" + $workDetail
        }       
    }else{
        $WorksDetail.Add($workName, $workDetail)
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

    # あるチャージ項目、その総工数、占める割合をプリント
    Write-Host "$key : $value 分 : $timePercentage %"
}

Write-Host `n"Total percentage = " $totalPercentage`n

foreach($key in $WorksDetail.Keys)
{
    $value = $WorksDetail.$key

    # あるチャージ項目の詳細をプリント（ex. xx project: タスク登録、ブランチ整理）
    Write-Host "$($key): $value"
}
