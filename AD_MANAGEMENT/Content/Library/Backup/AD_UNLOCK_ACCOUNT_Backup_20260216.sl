namespace: Backup
flow:
  name: AD_UNLOCK_ACCOUNT_Backup_20260216
  inputs:
    - AD_Host: KIBBHQADC01.kenanga.local
    - AD_AdminUser: "kenanga\\ivtsvc"
    - AD_AdminPass:
        default: 'KIBB$#@!qwer4321'
        sensitive: true
    - EmailAddress
  workflow:
    - Get_FullName:
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
          - fullNameResult: '${returnResult}'
          - unlockAccountResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Get_LoginName
    - Check_Account_Locked_Status:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'(Get-ADUser '+ loginNameResult +' -Properties LockedOut).LockedOut'}"
        publish:
          - unlockAccountResult: "${cs_replace(returnResult, \"\\r\\n\", \"\")}"
        navigate:
          - success: Compare_Account_Locked_Status
          - failure: FAILURE
    - Unlock_Account:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'Unlock-ADAccount -Identity '+ loginNameResult}"
        publish:
          - unlockAccountResult: '${returnResult}'
        navigate:
          - success: Check_Account_Locked_Status_After_Unlock
          - failure: FAILURE
    - Check_Account_Locked_Status_After_Unlock:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - script: "${'(Get-ADUser '+ loginNameResult +' -Properties LockedOut).LockedOut'}"
        publish:
          - unlockAccountResult: "${cs_replace(returnResult, \"\\r\\n\", \"\")}"
        navigate:
          - success: Compare_Account_Locked_Status_After_Unlock
          - failure: FAILURE
    - Is_User_Enabled:
        do_external:
          37c16732-1c50-4b63-b8b8-ca3e77868bee:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${dnResult}'
            - userFullName: '${fullNameResult}'
        publish:
          - unlockAccountResult: '${returnResult}'
        navigate:
          - success: Check_Account_Locked_Status
          - failure: FAILURE
    - Get_LoginName:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(mail=' + EmailAddress + '))'}"
            - propertyName: sAMAccountName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - loginNameResult: '${returnResult}'
          - unlockAccountResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Get_UserDN
    - Get_UserDN:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(mail=' + EmailAddress + '))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - dnResult: "${cs_regex(returnResult, \"(OU=[^,]*(?:\\\\\\\\.[^,]*)*(?:,OU=[^,]*(?:\\\\\\\\.[^,]*)*)*),DC=\")}"
          - unlockAccountResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Is_User_Enabled
    - Compare_Account_Locked_Status:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${unlockAccountResult}'
            - matchTo: 'False'
            - ignoreCase: 'false'
        publish:
          - unlockAccountResult: '${cs_replace(toMatch, "False", "Your account is currently unlocked.")}'
        navigate:
          - success: SUCCESS
          - failure: Unlock_Account
    - Compare_Account_Locked_Status_After_Unlock:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${unlockAccountResult}'
            - matchTo: 'False'
            - ignoreCase: 'false'
        publish:
          - unlockAccountResult: '${cs_replace(toMatch, "False", "Your account has been successfully unlocked.")}'
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
      Is_User_Enabled:
        x: 840
        'y': 120
        navigate:
          3b7fe7e2-4e13-dbed-85fb-f40bbbd21512:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Get_FullName:
        x: 280
        'y': 120
        navigate:
          80f69eee-8524-3dfd-f114-9cb1e6beef96:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Check_Account_Locked_Status_After_Unlock:
        x: 1200
        'y': 560
        navigate:
          47771cb6-c009-1af5-5a4a-69ecc335e9d1:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Compare_Account_Locked_Status_After_Unlock:
        x: 1200
        'y': 320
        navigate:
          679c8a75-5569-802b-5e13-f33e76a6a67b:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
          a23baa9b-5c0a-a073-38f3-28018a3352c8:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
      Get_LoginName:
        x: 480
        'y': 120
        navigate:
          4292f322-d1c3-56b8-389f-957157e7bdee:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Unlock_Account:
        x: 1040
        'y': 560
        navigate:
          3cfcbaa0-34ed-e677-74e0-3c8eb85f5016:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Compare_Account_Locked_Status:
        x: 840
        'y': 560
        navigate:
          ced1b1b2-8ba9-ce51-51bb-212c4ea41321:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
      Get_UserDN:
        x: 680
        'y': 120
        navigate:
          8d91523c-0228-26c4-13ad-35a7c905ce54:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Check_Account_Locked_Status:
        x: 840
        'y': 320
        navigate:
          50d680b1-74c6-6f42-e7e2-96c7abc47442:
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
