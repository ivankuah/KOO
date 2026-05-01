namespace: AD_Management_DEV
flow:
  name: AD_CREATE_USER_DEV
  inputs:
    - AD_Host:
        default: KIBBHQADC01.kenanga.local
        required: false
    - AD_AdminUser:
        default: "kenanga\\ivtsvc"
        required: false
    - AD_AdminPass:
        default: 'KIBB$#@!qwer4321'
        required: false
        sensitive: true
    - UserFullName:
        default: ITSM Test User
        sensitive: false
    - Username: itsm_testuser
    - Password: Welcome123..
    - EmailAddress: temp_testuser@kenanga.com.my
    - JobTitle: System Engineer
    - Company: KIBB
    - Department
    - Manager
    - FirstName
    - LastName
    - OU
    - PowershellHost: 172.21.5.157
    - Street
    - City
    - State
    - PostalCode
    - Country
  workflow:
    - Check_User:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(mail=' + EmailAddress + '))'}"
            - propertyName: cn
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - checkUserExistResult: '${returnResult}'
          - createUserResult: '${returnResult}'
        navigate:
          - failure: String_Comparator
          - success: SUCCESS
    - String_Comparator:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Contains
            - toMatch: '${UserFullName}'
            - matchTo: ','
            - ignoreCase: 'true'
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Search_and_Replace
          - failure: Create_User
    - Search_and_Replace:
        do_external:
          6a537995-25a9-4af6-b09d-efc1db705929:
            - input: '${UserFullName}'
            - replace: ','
            - replaceWith: "\\,"
        publish:
          - createUserResult: '${result}'
          - getEditedUserFullNameResult: '${result}'
        navigate:
          - success: Create_User_After_Replaced
          - failure: FAILURE
    - Create_User_After_Replaced:
        do_external:
          0b7086df-fca5-4841-83f6-934e8d3106f5:
            - host: '${AD_Host}'
            - OU: '${OU}'
            - userFullName: '${getEditedUserFullNameResult}'
            - userPassword:
                value: '${Password}'
                sensitive: true
            - sAMAccountName: '${Username}'
            - altuser: '${AD_AdminUser}'
            - altpass:
                value: '${AD_AdminPass}'
                sensitive: true
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Set_User_Account_After_Replaced
          - failure: FAILURE
    - Set_User_Account_After_Replaced:
        do_external:
          b02dcd0f-f6b0-410f-b47a-ee56129311bf:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userCommonName: '${getEditedUserFullNameResult}'
            - logonName: '${EmailAddress}'
            - sAMAccountName: '${Username}'
            - mustChangePassword:
                value: 'true'
                sensitive: true
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Set_User_General_Information_After_Replaced
          - failure: FAILURE
    - Set_User_General_Information_After_Replaced:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'try { Set-ADUser -Identity ' + Username +' -GivenName \"'+ FirstName + '\" -Surname \"' + LastName + '\" -DisplayName \"' + UserFullName + '\" -EmailAddress \"' + EmailAddress + '\" -ErrorAction Stop; Write-Host \"Update successful\" } catch { Write-Host \"Update failed: $($_.Exception.Message)\" }'}"
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Set_User_Organization_After_Replaced
          - failure: FAILURE
    - Check_User_After_User_Created:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(mail=' + EmailAddress + '))'}"
            - propertyName: cn
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - getCreatedUserResult: '${returnResult}'
          - createUserResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: String_Comparator_1
    - Create_User:
        do_external:
          0b7086df-fca5-4841-83f6-934e8d3106f5:
            - host: '${AD_Host}'
            - OU: '${OU}'
            - userFullName: '${UserFullName}'
            - userPassword:
                value: '${Password}'
                sensitive: true
            - sAMAccountName: '${Username}'
            - altuser: '${AD_AdminUser}'
            - altpass:
                value: '${AD_AdminPass}'
                sensitive: true
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Set_User_Account
          - failure: FAILURE
    - Set_User_Organization_After_Replaced:
        do_external:
          feb192e7-f3b2-4be5-8b4a-4064a14e77b7:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userCommonName: '${getEditedUserFullNameResult}'
            - title: '${JobTitle}'
            - department: '${Department}'
            - company: '${Company}'
            - managerDN: '${Manager}'
        publish:
          - createIserResult: returnResult
        navigate:
          - success: Set_User_Address_After_Replaced
          - failure: FAILURE
    - Set_User_Account:
        do_external:
          b02dcd0f-f6b0-410f-b47a-ee56129311bf:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userCommonName: '${UserFullName}'
            - logonName: '${EmailAddress}'
            - sAMAccountName: '${Username}'
            - mustChangePassword:
                value: 'true'
                sensitive: true
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Set_User_General_Information
          - failure: FAILURE
    - Set_User_General_Information:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - URI: '${AD_AdminUser}'
            - shellURI: '${AD_AdminPass}'
            - port: '5985'
            - script: "${'try { Set-ADUser -Identity ' + Username +' -GivenName \"'+ FirstName + '\" -Surname \"' + LastName + '\" -DisplayName \"' + UserFullName + '\" -EmailAddress \"' + EmailAddress + '\" -ErrorAction Stop; Write-Host \"Update successful\" } catch { Write-Host \"Update failed: $($_.Exception.Message)\" }'}"
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Set_User_Organization
          - failure: FAILURE
    - Set_User_Organization:
        do_external:
          feb192e7-f3b2-4be5-8b4a-4064a14e77b7:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userCommonName: '${UserFullName}'
            - title: '${JobTitle}'
            - department: '${Department}'
            - company: '${Company}'
            - managerDN: '${Manager}'
        publish:
          - createIserResult: returnResult
        navigate:
          - success: Set_User_Address
          - failure: FAILURE
    - String_Comparator_1:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${getCreatedUserResult}'
            - matchTo: '${UserFullName}'
            - ignoreCase: 'true'
        publish:
          - createUserResult: '${cs_replace(returnResult, "Matches", "User Created Successfully")}'
          - getErrorResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: Search_and_Replace_1
    - Search_and_Replace_1:
        do_external:
          6a537995-25a9-4af6-b09d-efc1db705929:
            - input: '${getErrorResult}'
            - replace: '${getErrorResult}'
            - replaceWith: User Create Failed
        publish:
          - createUserResult: '${result}'
        navigate:
          - success: FAILURE
          - failure: on_failure
    - Set_User_Address_After_Replaced:
        do_external:
          d9e2ab0a-d6e0-4565-84dc-bf584c587f49:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userCommonName: '${getEditedUserFullNameResult}'
            - street: '${Street}'
            - city: '${City}'
            - stateOrProvince: '${State}'
            - zipOrPostalCode: '${PostalCode}'
            - countryOrRegion: '${Country}'
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Set_User_ProxyAddress_After_Replaced
          - failure: FAILURE
    - Set_User_Address:
        do_external:
          d9e2ab0a-d6e0-4565-84dc-bf584c587f49:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userCommonName: '${UserFullName}'
            - street: '${Street}'
            - city: '${City}'
            - stateOrProvince: '${State}'
            - zipOrPostalCode: '${PostalCode}'
            - countryOrRegion: '${Country}'
        navigate:
          - success: Set_User_ProxyAddress
          - failure: FAILURE
    - Set_User_ProxyAddress_After_Replaced:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'try { Set-ADUser -Identity '+ Username +' -Add @{proxyAddresses=@(\"smtp:'+ Username +'@kenanga.mail.onmicrosoft.com\",\"smtp:'+ Username +'@kenanga.local\",\"SMTP:'+ EmailAddress +'\")} -ErrorAction Stop; Write-Host \"ProxyAddresses Successful Added\" } catch { Write-Host \"ProxyAddresses Failed Added\"; Write-Host \"Error: $($_.Exception.Message)\" }'}"
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Check_User_After_User_Created
          - failure: FAILURE
    - Set_User_ProxyAddress:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - URI: '${AD_AdminUser}'
            - shellURI: '${AD_AdminPass}'
            - port: '5985'
            - script: "${'try { Set-ADUser -Identity '+ Username +' -Add @{proxyAddresses=@(\"smtp:'+ Username +'@kenanga.mail.onmicrosoft.com\",\"smtp:'+ Username +'@kenanga.local\",\"SMTP:'+ EmailAddress +'\")} -ErrorAction Stop; Write-Host \"ProxyAddresses Successful Added\" } catch { Write-Host \"ProxyAddresses Failed Added\"; Write-Host \"Error: $($_.Exception.Message)\" }'}"
        publish:
          - createUserResult: '${returnResult}'
        navigate:
          - success: Check_User_After_User_Created
          - failure: FAILURE
  outputs:
    - OOResult: '${createUserResult}'
    - UserPassword: '${Password}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Check_User:
        x: 760
        'y': 100
        navigate:
          7aac776d-43e7-f31d-f407-6142656dcaf1:
            targetId: 3dd2ebe2-73c5-c308-0169-fcfd9b2fc9e0
            port: success
      String_Comparator:
        x: 640
        'y': 160
      Create_User_After_Replaced:
        x: 480
        'y': 440
        navigate:
          1ccff3e6-9e66-b27c-172b-1d5eeb3d5564:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Search_and_Replace_1:
        x: 1160
        'y': 760
        navigate:
          7ed1d79b-94a3-dcc3-0573-d808f6436d8b:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: success
      Set_User_Organization_After_Replaced:
        x: 480
        'y': 920
        navigate:
          157f4712-44cb-bf97-5cb4-f4912404f541:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_Organization:
        x: 960
        'y': 760
        navigate:
          2e7e110e-871f-4a68-86d7-cdfc8d77585c:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Create_User:
        x: 960
        'y': 280
        navigate:
          9a0c8848-5f2d-17b4-0d4f-03d2af5f8ce7:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Check_User_After_User_Created:
        x: 960
        'y': 1320
        navigate:
          1a3ee6d8-d851-98fd-d732-4be37e509d63:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_General_Information_After_Replaced:
        x: 480
        'y': 760
        navigate:
          5839e5eb-d5d4-c148-fd12-beb956c8f335:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Search_and_Replace:
        x: 480
        'y': 280
        navigate:
          a405f500-899c-1cc0-8f10-698fecf7e327:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_ProxyAddress_After_Replaced:
        x: 480
        'y': 1320
        navigate:
          7e72582e-c7ec-7b86-ee27-48dc70645f58:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_Address_After_Replaced:
        x: 480
        'y': 1120
        navigate:
          04002faa-fe90-6010-19d5-caa9eb9b8f4f:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      String_Comparator_1:
        x: 1160
        'y': 920
        navigate:
          4babc8b5-2fb9-5882-c4e9-6119e8565221:
            targetId: 3dd2ebe2-73c5-c308-0169-fcfd9b2fc9e0
            port: success
      Set_User_Account:
        x: 960
        'y': 440
        navigate:
          505b9355-8694-a6ff-3205-e5b7571b15c1:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_Account_After_Replaced:
        x: 480
        'y': 600
        navigate:
          98757167-bd13-c87b-cf09-cb0c233f7c77:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_Address:
        x: 960
        'y': 920
        navigate:
          f91dd5ba-91fa-c0a6-275d-7c7e2a8cd1d2:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_ProxyAddress:
        x: 960
        'y': 1080
        navigate:
          09dbd1e6-c813-56e1-aaec-0496dd83f1fc:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
      Set_User_General_Information:
        x: 960
        'y': 600
        navigate:
          479b65ab-5bac-cef0-8f82-d8f05d6a212c:
            targetId: 1bb10cc8-5c27-9232-b101-5c93ac8c0b5b
            port: failure
    results:
      SUCCESS:
        3dd2ebe2-73c5-c308-0169-fcfd9b2fc9e0:
          x: 1360
          'y': 440
      FAILURE:
        1bb10cc8-5c27-9232-b101-5c93ac8c0b5b:
          x: 680
          'y': 520
