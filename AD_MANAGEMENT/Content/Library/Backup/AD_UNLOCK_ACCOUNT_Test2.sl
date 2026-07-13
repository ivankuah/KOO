namespace: Backup
flow:
  name: AD_UNLOCK_ACCOUNT_Test2
  inputs:
    - AD_Host: KIBBHQADC01.kenanga.local
    - AD_AdminUser: "kenanga\\ivtsvc"
    - AD_AdminPass:
        default: 'KIBB$#@!qwer4321'
        sensitive: true
    - EmailAddress: itsm_testuser
  workflow:
    - Rename_User_Display_Name:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: 172.21.5.157
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: 'try { Set-ADUser -Identity "itsm_testuser7 " -DisplayName "ITSM Test User 7" -ErrorAction Stop; Write-Host "Update successful" } catch { Write-Host "Update failed: $($_.Exception.Message)" }'
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Rename_User_Common_Name
          - failure: FAILURE
    - Rename_User_Common_Name:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: 172.21.5.157
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: 'try { Rename-ADObject -Identity "CN=r_ITSM Test User 7,OU=POC ITSM 02,DC=kenanga,DC=local" -NewName "ITSM Test User 7" -ErrorAction Stop; Write-Host "Update successful" } catch { Write-Host "Update failed: $($_.Exception.Message)" }'
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  outputs:
    - unlockAccountResult: '${unlockAccountResult}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Rename_User_Display_Name:
        x: 480
        'y': 200
        navigate:
          158073bc-c4c5-bb74-548d-1d44c2362e70:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Rename_User_Common_Name:
        x: 680
        'y': 200
        navigate:
          cf78224b-1644-55bb-9262-47a77d36aecd:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
          fefc82a6-b64d-ee83-d101-17b8c403e7d4:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
    results:
      SUCCESS:
        155be301-aca3-f450-91a9-f10865e03b6b:
          x: 1040
          'y': 200
      FAILURE:
        1be41d02-a4a7-513a-a73e-fc1ae38e2deb:
          x: 440
          'y': 440
