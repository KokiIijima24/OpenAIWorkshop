## 目次

- Subscriptionの用意
    - 用意したSubscriotionに権限を割りてる


## Subscitpion の用意

### Subscriptionに権限の割り当て



MEID情報取得

```
PS C:\Users\koiijima> Get-AzADUser -Mail koki.iijima@jbs.com

DisplayName  Id                                   Mail                UserPrincipalName
-----------  --                                   ----                -----------------
Iijima, Koki a530a839-d6f6-44bf-a1bd-0bb58573b6a8 koki.iijima@jbs.com koiijima@jbs.com
```

上記のIDがObject IDになる。



Subscription単位でRoleを割り当てる

```
PS C:\Users\koiijima> New-AzRoleAssignment -ObjectId 'a530a839-d6f6-44bf-a1bd-0bb58573b6a8' `
>> -RoleDefinitionName 'Cognitive Services OpenAI Contributor' `
>> -Scope /subscriptions/4a638e79-e52d-4f0e-ba58-e6cc63b85ee3
```



