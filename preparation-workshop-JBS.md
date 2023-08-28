## 目次

- Subscriptionの用意
    - 用意したSubscriotionに権限を割りてる


## Subscitpion の用意

### Subscriptionに権限の割り当て

まずはAzure ADへサインインする。

```
Connect-AzAccount
```

MEID情報取得

```powershell
PS C:\Users\koiijima> Get-AzADUser -Mail koki.iijima@jbs.com

DisplayName  Id                                   Mail                UserPrincipalName
-----------  --                                   ----                -----------------
Iijima, Koki a530a839-d6f6-44bf-a1bd-0bb58573b6a8 koki.iijima@jbs.com koiijima@jbs.com
```

上記のIDがObject IDになる。


Subscription単位でRoleを割り当てる

```powershell
PS C:\Users\koiijima> $aad_id =  (Get-AzADUser -Mail koki.iijima@jbs.com).id
PS C:\Users\koiijima> New-AzRoleAssignment -ObjectId $aad_id `
>> -RoleDefinitionName 'Cognitive Services OpenAI Contributor' `
>> -Scope /subscriptions/4a638e79-e52d-4f0e-ba58-e6cc63b85ee3
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
    -Scope /subscriptions/4a638e79-e52d-4f0e-ba58-e6cc63b85ee3
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