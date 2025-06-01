
# 工数を集計するためのロジック。

## If there are issues related to the execution policy and character code, please try the following ##
# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
# chcp 932
# chcp 65001

# file input
param([string]$filePath = $args[0])
if (-not $filePath) {
    Write-Host "Please drag and drop a file onto this script."
    exit
}
$file_data = Get-Content -Encoding UTF8 $filePath


### 以下は関数の定義 ###


# 日付をプリントするための関数。
function PrintDate([string]$DateRow) {
    
    # How does powershell split consecutive strings. Not a single letter: https://stackoverflow.com/questions/76241804/how-does-powershell-split-consecutive-strings-not-a-single-letter
    $date = ($row.Split([string[]] "## ", 'None'))[1]

    # 日付をプリント
    Write-Host `n$date`n
}

# 渡された作業の行の時間の長さを計算するための関数。
function GetTimeLengthThisRow([string]$TimeRow) {

    $timeSlot = $TimeRow.Substring(2, 11) # 時間帯を取得。
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
function PrintWorkingTime([Object[]]$groupedWorksInfo) {
    
    Write-Host "【1. Work title and it's total time】"

    # あるチャージ項目、その総工数、占める割合を計算する。
    $totalPercentage = 0
    $groupedWorksInfo | ForEach-Object {

        # あるチャージ項目の総工数を集計する。
        $time = 0
        $_.Group | ForEach-Object { 
            $time += $_.Item2
        }

        # 全体工数で占める割合を計算する。
        $timePercentage = $time / $totalTime
        $timePercentage = $timePercentage * 100
        $totalPercentage += $timePercentage
        
        # あるチャージ項目、その総工数、占める割合をプリント。
        Write-Host "$($_.Name) : $time min : $timePercentage %"
    }

    # 全体工数をプリント。
    Write-Host `n"Total time = " $totalTime
    Write-Host "[for double check]Total percentage = " $totalPercentage`n
}

# チャージ項目とその詳細をプリントするための関数。
function PrintWorkingDetail([Object[]]$groupedWorksInfo) {
    
    Write-Host "【2.Work title and it's detail】"

    # チャージ項目詳細を重複なしで並べる。
    # About Contains: https://itsakura.com/powershell-contains   
    $groupedWorksInfo | ForEach-Object {
        $workDetail = ""
        $_.Group | ForEach-Object {        
            if ($workDetail -ne "" -And !($workDetail.Contains($_.Item3)) -And !($_.Item3.Contains($workDetail))){
                $workDetail = $workDetail + "、" + $_.Item3
            } else {
                $workDetail = $_.Item3
            }
        }
        
        # あるチャージ項目の詳細をプリント（ex. xx project: タスク登録、ブランチ整理）。
        if ($workDetail -ne ""){
            Write-Host "$($_.Name) : $workDetail"
        } else {
            Write-Host "$($_.Name)"
        }        
    }
}


### 以下はメイン処理 ###


# 作業の情報を格納するリスト（チャージ項目名、時間、詳細説明。例えば A project, 60 min, 開発定例）
$WorksInfo = @()
# 総工数
$totalTime = 0

foreach ($row in $file_data)
{
  if ($row.StartsWith("## ")){

    ## １．日付の行の処理：日付をプリント ##
    PrintDate -DateRow $row

  } elseif ($row.StartsWith("- ") -And !($row.Contains("休憩"))){    
    
    ## ２．工数の行の処理：この行の工数を計算 ##
    $timeLength = GetTimeLengthThisRow -TimeRow $row   
    # この行の工数を総工数に足す。
    $totalTime = $totalTime + $timeLength.TotalMinutes

    # この行のチャージ項目名と詳細をGet（ex. A project, 開発定例）。
    $workNameAndDetail = GetWorkNameAndDetailThisRow -TimeRow $row

    # この行のチャージ項目名、時間、詳細説明をタプルとしてリストへ格納。
    $WorksInfo += [Tuple]::Create($workNameAndDetail[0], $timeLength.TotalMinutes, $workNameAndDetail[1])
  } 
}

# チャージ項目名、時間、詳細説明のリストを「チャージ項目名」でグループ分けする。
$groupedWorksInfo = $WorksInfo | Group-Object -Property {$_.Item1}

# ① チャージ項目（とその総工数）をプリントする。
# ex. B project : 300 分 : 62.5 %
PrintWorkingTime -groupedWorksInfo $groupedWorksInfo

# ② チャージ項目とその詳細説明をプリントする。
# ex. B project: 画面実装、画面設計
PrintWorkingDetail -groupedWorksInfo $groupedWorksInfo
