# Working Time Summary

Convert the working time timetable to percentages and calculate the total time for each project in a single day.

- Input File Sample: input_sample.md
- Sorce Code: CalculateWorkingTime.ps1
- Batch file for drag-and-drop execution: RunScript.bat

## How to use it
1. Write your work schedule to an .md file (referring to the input_sample.md for guidance).

#### Using the .bat file

2. Drag your .md file onto the RunScript.bat.

#### Executing the PowerShell directly

2. Open the source code file (CalculateWorkingTime.ps1) using the PowerShell ISE or some other IDEs.
   If you are using macOS, please check https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.4
   
3. Update the path for $file_data.
4. Execute 'Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process' in the command line.
5. Execute the whole code.

## Input file
### 1. Format
```
## {yyyy/mm/dd}

- {HHmm} ~ {HHmm}: {Work Title1} - {Work Detail1}
- {HHmm} ~ {HHmm}: {Work Title2} - {Work Detail2}
- {HHmm} ~ {HHmm}: {Work Title3} - {Work Detail3}
```
### 2. Sample
```
## 2023/5/18

- 0900 ~ 0930: 雑務 - パソコン起動、Todo 確認
- 0930 ~ 1000: 部門会議 - チーム定例
- 1000 ~ 1030: A project - Jira 登録、ブランチ整理等
- 1030 ~ 1100: A project - 開発定例
- 1100 ~ 1200: B project - 結果画面実装
- 1200 ~ 1300: 昼休憩
- 1300 ~ 1700: B project - 結果画面実装、画面設計
- 1700 ~ 1730: C project - Aさんと会議
- 1730 ~ 1800: 雑務 - メール確認、member chat
```
## Console output
### Sample
```
【1. Work title and it's total time】
雑務 : 60 min : 12.5 %
部門会議 : 30 min : 6.25 %
A project : 60 min : 12.5 %
B project : 300 min : 62.5 %
C project : 30 min : 6.25 %

Total time =  480
[for double check]Total percentage =  1

【2. Work title and it's detail】
雑務: パソコン起動、Todo 確認、メール確認、member chat
部門会議: チーム定例
A project: Jira 登録、ブランチ整理等、開発定例
B project: 結果画面実装
C project: Aさんと会議
```
Caution: Work titles containing "休憩," which means break, will not be considered as part of work hours.
