namespace: AD_Management_DEV
flow:
  name: AD_DELETE_USER_DEV
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
    - UserFullName
    - OU
    - PowershellHost: 172.21.5.157
  workflow:
    - Check_User:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(distinguishedName=CN=' + UserFullName + ','+ OU +',DC=kenanga.local))'}"
            - propertyName: cn
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - deleteUserResult: '${returnResult}'
          - getUserDN: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: String_Comparator
    - Check_User_After_Deleted:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(distinguishedName=CN=r_' + UserFullName + ',CN=Resigned Staff,CN=Users,DC=kenanga,DC=local))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - deleteUserResult: '${returnResult}'
          - getUserDNResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: String_Comparator_1
    - Rename_User_Display_Name_After_Replaced:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'try { Set-ADUser -Identity \"'+ Username +'\" -DisplayName \"r_'+ getUserFullName +'\" -ErrorAction Stop; Write-Host \"Update successful\" } catch { Write-Host \"Update failed: $($_.Exception.Message)\" }'}"
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Rename_User_Common_Name_After_Replaced
          - failure: FAILURE
    - String_Comparator:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Contains
            - toMatch: '${UserFullName}'
            - matchTo: "\\,"
            - ignoreCase: 'true'
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Search_and_Replace
          - failure: Rename_User_Display_Name
    - Search_and_Replace:
        do_external:
          6a537995-25a9-4af6-b09d-efc1db705929:
            - input: '${getUserFullNameResult}'
            - replace: "\\,"
            - replaceWith: ','
        publish:
          - deleteUserResult: '${result}'
          - getUserFullName: '${result}'
        navigate:
          - success: Rename_User_Display_Name_After_Replaced
          - failure: FAILURE
    - Rename_User_Common_Name_After_Replaced:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'try { Rename-ADObject -Identity \"CN='+ UserFullName +','+OU+',DC=kenanga,DC=local\" -NewName \"r_'+ UserFullName +'\" -ErrorAction Stop; Write-Host \"Update successful\" } catch { Write-Host \"Update failed: $($_.Exception.Message)\" }'}"
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Move_User
          - failure: FAILURE
    - Move_User:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'try { Move-ADObject -Identity \"CN=r_'+ UserFullName +','+ OU +',DC=kenanga,DC=local\" -TargetPath \"CN=Resigned Staff,CN=Users,DC=kenanga,DC=local\" -ErrorAction Stop; Write-Output \"SUCCESS: User moved successfully\"} catch { Write-Output \"FAILED: $($_.Exception.Message)\"}'}"
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Check_User_After_Deleted
          - failure: FAILURE
    - Rename_User_Display_Name:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'try { Set-ADUser -Identity \"'+ Username +'\" -DisplayName \"r_'+ UserFullName +'\" -ErrorAction Stop; Write-Host \"Update successful\" } catch { Write-Host \"Update failed: $($_.Exception.Message)\" }'}"
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Rename_User_Display_Name_After_Replaced_1
          - failure: FAILURE
    - Rename_User_Display_Name_After_Replaced_1:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'try { Set-ADUser -Identity \"'+ Username +'\" -DisplayName \"r_'+ getUserFullName +'\" -ErrorAction Stop; Write-Host \"Update successful\" } catch { Write-Host \"Update failed: $($_.Exception.Message)\" }'}"
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Move_User
          - failure: FAILURE
    - String_Comparator_1:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Contain
            - toMatch: '${getUserDNResult}'
            - matchTo: r_
            - ignoreCase: 'true'
        publish:
          - returnResult: '${cs_replace(returnResult, "Do Not Matches", "Renamed Unsuccessfully")}'
        navigate:
          - success: String_Comparator_1_1
          - failure: FAILURE
    - String_Comparator_1_1:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Contain
            - toMatch: '${getUserDNResult}'
            - matchTo: Resigned
            - ignoreCase: 'true'
        publish:
          - returnResult: '${cs_replace(returnResult, "Do Not Matches", "Moved User Unsuccessfully")}'
          - getCompareResult: '${returnResult}'
        navigate:
          - success: Search_and_Replace_1
          - failure: FAILURE
    - Search_and_Replace_1:
        do_external:
          6a537995-25a9-4af6-b09d-efc1db705929:
            - input: '${getCompareResult}'
            - replace: '${getCompareResult}'
            - replaceWith: Succesful Rename and Move User
        publish:
          - deleteUserResult: '${result}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  outputs:
    - OOResult: '${deleteUserResult}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Check_User:
        x: 560
        'y': 0
        navigate:
          9cda27ab-c97e-7110-408b-e44ca79377dc:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      String_Comparator:
        x: 560
        'y': 160
      Rename_User_Common_Name_After_Replaced:
        x: 360
        'y': 520
        navigate:
          5bbec862-9214-3e1f-42de-7836042b85aa:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Search_and_Replace_1:
        x: 1000
        'y': 160
        navigate:
          120296f1-8bef-21df-1516-a0760e7fe8e5:
            targetId: 38c3689d-505e-ed63-6031-b37dec84be1b
            port: success
          cb2bc76a-7d46-9fcf-19b4-da5a8ec9de8e:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      String_Comparator_1_1:
        x: 1000
        'y': 280
        navigate:
          5d89d936-1589-a423-6275-0f0555d1e05d:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Rename_User_Display_Name_After_Replaced_1:
        x: 720
        'y': 400
        navigate:
          cc361fac-06ed-9796-1931-8546bdeb0e56:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Search_and_Replace:
        x: 360
        'y': 200
        navigate:
          688f9aec-d23b-2a6c-1573-25ef9db03d6b:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      String_Comparator_1:
        x: 840
        'y': 400
        navigate:
          8da4ae16-8706-c522-a95c-41cb7888867c:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Rename_User_Display_Name_After_Replaced:
        x: 360
        'y': 360
        navigate:
          12c28b7c-7f63-6255-543c-7215c8cfba1e:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Move_User:
        x: 560
        'y': 600
        navigate:
          8b56004b-e0b3-b6bb-455c-34d8788b2a13:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Check_User_After_Deleted:
        x: 840
        'y': 600
        navigate:
          bd739770-d6b4-a572-68cd-f96d1a9c1168:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Rename_User_Display_Name:
        x: 720
        'y': 240
        navigate:
          fe312246-73e1-bd8e-6834-e13827f4b74a:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
    results:
      SUCCESS:
        38c3689d-505e-ed63-6031-b37dec84be1b:
          x: 1000
          'y': 40
      FAILURE:
        48ea08fe-77dc-b9d4-b74c-9c2dfec02c46:
          x: 560
          'y': 280
