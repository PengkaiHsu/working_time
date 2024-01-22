
# 工数を集計するためのロジック

## If there are issues related to the execution policy and character code, please try the following ##
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# chcp 932
# chcp 65001


### 関数定義 ###############################################################################


# 日付をプリントするための関数。
function PrintDate([string]$DateRow) {
    
    # How does powershell split consecutive strings. Not a single letter: https://stackoverflow.com/questions/76241804/how-does-powershell-split-consecutive-strings-not-a-single-letter
    $date = ($row.Split([string[]] "## ", 'None'))[1]

    # 日付をプリント
    Write-Host `n$date`n
}

# 渡された作業の行の時間の長さを計算するための関数。
function GetTimeLengthThisRow([string]$TimeRow) {

    $timeSlot = $TimeRow.Substring(2, 11) # 時間帯を取得
    $timeStart = ($timeSlot.Split([string[]] " ~ ", 'None'))[0]
    $timeEnd = ($timeSlot.Split([string[]] " ~ ", 'None'))[1]
    $dateTimeStart = [DateTime]::ParseExact($timeStart,"HHmm", $null)
    $dateTimeEnd = [DateTime]::ParseExact($timeEnd,"HHmm", $null)
    
    return ($dateTimeEnd - $dateTimeStart)
}

# 渡された作業の行のチャージ項目名と詳細を取得するための関数。
function GetWorkNameAndDetailThisRow([string]$TimeRow) {

    $work = (($row.Split([string[]] ": ", 'None'))[1]).trim()

    if ($work.Contains("-")){

        # チャージ項目名（ex. A project）
        $workName = ($work.Split([string[]] " - ", 'None'))[0]

        # チャージ項目詳細（ex. 開発定例）
        $workDetail = (($work.Split([string[]] " - ", 'None'))[1]).trim()

        return ($workName, $workDetail)
    }else{

        # チャージ項目名（ex. A project）
        $workName = $work

        # チャージ項目詳細（なし）
        $workDetail = ""

        return ($workName, $workDetail)
    }
}

# チャージ項目とその工数をプリントするための関数。
function PrintWorkingTime([System.Collections.Generic.Dictionary[String, Int]]$Works) {
    
    Write-Host "【① Work title and it's total time】"

    $totalPercentage = 0
    foreach($key in $Works.Keys)
    {
        $value = $Works.$key
        $timePercentage = $value / $totalTime
        $totalPercentage += $timePercentage
        $timePercentage = $timePercentage * 100

        # あるチャージ項目、その総工数、占める割合をプリント
        Write-Host "$key : $value min : $timePercentage %"
    }

    Write-Host `n"Total time = " $totalTime
    Write-Host "[for double check]Total percentage = " $totalPercentage`n
}

# チャージ項目とその詳細をプリントするための関数。
function PrintWorkingDetail([System.Collections.Generic.Dictionary[String, String]]$WorksDetail) {
    
    Write-Host "【② Work title and it's detail】"

    foreach($key in $WorksDetail.Keys)
    {
        $value = $WorksDetail.$key

        # あるチャージ項目の詳細をプリント（ex. xx project: タスク登録、ブランチ整理）
        Write-Host "$($key): $value"
    }
}


### 以下はメイン処理 ###############################################################################


# file input
$file_data = Get-Content -Encoding UTF8 C:\Programming\PowerShell\WorkingTime\working_time\input_sample.md

# チャージ項目の配列（チャージ項目名 + 時間、例えば A project : 60 分）
$Works = [System.Collections.Generic.Dictionary[String, Int]]::new()
# チャージ項目詳細の配列（チャージ項目名 + チャージ項目詳細、例えば A project: 開発定例）
$WorksDetail = [System.Collections.Generic.Dictionary[String, String]]::new()
# 総工数
$totalTime = 0

foreach ($row in $file_data)
{
  if ($row.StartsWith("## ")){

    ## 日付の行の処理：日付をプリント ##
    PrintDate -DateRow $row

  } elseif ($row.StartsWith("- ") -And !($row.Contains("休憩"))){    
    
    ## 工数の行の処理：この行の工数を計算 ##
    $timeLength = GetTimeLengthThisRow -TimeRow $row
    
    # この行の工数を総工数に足す。
    $totalTime = $totalTime + $timeLength.TotalMinutes

    # この行のチャージ項目名と詳細をGet（ex. A project - 開発定例）
    $workNameAndDetail = GetWorkNameAndDetailThisRow -TimeRow $row
    $workName = $workNameAndDetail[0]
    $workDetail = $workNameAndDetail[1]
    
    # チャージ項目名ごとの総工数を計算してチャージ項目の配列へ格納
    if($Works.ContainsKey($workName)){
        $Works[$workName] += $timeLength.TotalMinutes
    }else{
        $Works.Add($workName, $timeLength.TotalMinutes)
    }

    # チャージ項目詳細を重複なしでチャージ項目詳細の配列へ格納
    # About Contains: https://itsakura.com/powershell-contains
    if($WorksDetail.ContainsKey($workName)){
        if ($workDetail -ne "" -And !($WorksDetail[$workName].Contains($workDetail)) -And !($workDetail.Contains($WorksDetail[$workName]))){
            $WorksDetail[$workName] = $WorksDetail[$workName] + "、" + $workDetail
        }       
    }else{
        $WorksDetail.Add($workName, $workDetail)
    }
  } 
}

# ① チャージ項目（とその工数）をプリントする。
# ex. B project : 300 分 : 62.5 %
PrintWorkingTime -Works $Works

# ② チャージ項目とその詳細をプリントする。
# ex. B project: 画面実装
PrintWorkingDetail -WorksDetail $WorksDetail
