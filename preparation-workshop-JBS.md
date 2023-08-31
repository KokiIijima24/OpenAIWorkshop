ワークショップ参加者へのAzure Resourceへの権限を付与する方法を記載しました。

## 目次

- Subscriptionの用意
- Subscriotionに権限を割りてる

## Subscitpion の用意

社内のOneNoteを参照。
EAポータルから払い出しを実施する。

### Subscriptionに権限の割り当て

まずはAzure ADへサインインする。

```
Connect-AzAccount
```

MEID情報取得

```powershell
PS C:\Users\koiijima> Get-AzADUser -Mail <mail address>

DisplayName  Id                                   Mail                UserPrincipalName
-----------  --                                   ----                -----------------
<name>      <id>                               <mail address>      <AAD account name>
```

上記のIDがObject IDになる。


Subscription単位でRoleを割り当てる

```powershell
PS C:\Users\koiijima> $aad_id =  (Get-AzADUser -Mail <mail address>).id
PS C:\Users\koiijima> New-AzRoleAssignment -ObjectId $aad_id `
>> -RoleDefinitionName 'Cognitive Services OpenAI Contributor' `
>> -Scope /subscriptions/<Subscription id>
```

メールアドレスを入力すると、そのアドレスにOpen AIに対するロールを割り当てる関数を以下のように定義しました。

```powershell
Function Add-RoleToOpenAIResource {
    param (
        [Parameter(Mandatory=$true)]
        [string]$mail
    )
    echo "Add Role to ${mail}"
    $aad_id = (Get-AzADUser -UserPrincipalName "${mail}").id

    New-AzRoleAssignment -ObjectId $aad_id `
    -RoleDefinitionName 'Cognitive Services OpenAI Contributor' `
    -Scope /subscriptions/<Subscription id>
}
```


Excelのメールアドレスを読み取って、ループをしながらAzureリソースに対するロールを割り当てていくスクリプトは以下となります。


```powershell
$path = pwd

# Load the Excel COM object
$excel = New-Object -ComObject Excel.Application

# Open the Excel workbook
$workbook = $excel.Workbooks.Open("${path}\workshop_attendee.xlsx")

# Select the specific worksheet
$worksheet = $workbook.Worksheets.Item(1)

# Get the used range of the worksheet
$range = $worksheet.UsedRange

# Define the variables to store the data
$data = @()

# Loop through each row in the range, skipping the header row
for ($row = 2; $row -le $range.Rows.Count; $row++) {
    # Create an object to store the data for each row
    $rowObject = [PSCustomObject]@{
        Email = $worksheet.Cells.Item($row, 4).Value2
        # Add more columns as needed
    }

    # Add the row data to the array
    $data += $rowObject
    echo $rowObject
    Add-RoleToOpenAIResource -mail $rowObject.Email
}

# Close the workbook without saving changes
$workbook.Close($false)

# Quit Excel
$excel.Quit()

# Output the data
$data
```
