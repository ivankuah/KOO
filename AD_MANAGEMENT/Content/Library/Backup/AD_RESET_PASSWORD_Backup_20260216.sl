namespace: Backup
flow:
  name: AD_RESET_PASSWORD_Backup_20260216
  inputs:
    - AD_Host: KIBBHQADC01.kenanga.local
    - AD_AdminUser: "kenanga\\ivtsvc"
    - AD_AdminPass:
        default: 'KIBB$#@!qwer4321'
        sensitive: true
    - EmailAddress
    - NewPassword:
        sensitive: true
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
          - resetPasswordResult: '${returnResult}'
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
          - resetPasswordResult: "${cs_replace(returnResult, \"\\r\\n\", \"\")}"
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
          - resetPasswordResult: '${returnResult}'
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
          - resetPasswordResult: "${cs_replace(returnResult, \"\\r\\n\", \"\")}"
          - unlockAccountResult: "${cs_replace(returnResult, \"\\r\\n\", \"\")}"
        navigate:
          - success: Compare_Account_Locked_Status_After_Unlock
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
          - resetPasswordResult: '${returnResult}'
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
          - dnResult: "${cs_regex(returnResult, \"(OU=[^,]+(?:,OU=[^,]+)*)\\,DC=\")}"
          - resetPasswordResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Is_User_Enabled
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
          - resetPasswordResult: '${returnResult}'
          - isUserEnabledResult: '${returnResult}'
        navigate:
          - success: Check_Account_Locked_Status
          - failure: FAILURE
    - Compare_Account_Locked_Status:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${unlockAccountResult}'
            - matchTo: 'False'
            - ignoreCase: 'false'
        publish:
          - resetPasswordResult: '${cs_replace(toMatch, "False", "Your account is currently unlocked.")}'
        navigate:
          - success: Reset_Password
          - failure: Unlock_Account
    - Compare_Account_Locked_Status_After_Unlock:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${unlockAccountResult}'
            - matchTo: 'False'
            - ignoreCase: 'false'
        publish:
          - resetPasswordResult: '${cs_replace(toMatch, "False", "Your account has been successfully unlocked.")}'
        navigate:
          - success: Reset_Password
          - failure: FAILURE
    - Reset_Password:
        do_external:
          3950548b-3f1b-4baa-8a8d-95c2c98748b4:
            - host: '${AD_Host}'
            - sAMAccountName: '${loginNameResult}'
            - userPassword:
                value: '${NewPassword}'
                sensitive: true
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
        publish:
          - resetPasswordResult: '${cs_replace(returnResult,"Changed Password","Your password has been successfully reset. You may now log in with your new password.")}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  outputs:
    - resetPasswordResult: '${resetPasswordResult}'
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
          c2864f96-5db6-4701-1224-4cafb6ba383b:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Get_FullName:
        x: 280
        'y': 120
        navigate:
          995c345f-7bfc-a1f0-54ef-f16ea5e54f89:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Check_Account_Locked_Status_After_Unlock:
        x: 1520
        'y': 120
        navigate:
          074963cb-0932-8ec6-9821-451e1231e2c0:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Compare_Account_Locked_Status_After_Unlock:
        x: 1520
        'y': 320
        navigate:
          e21851bc-baec-c691-c947-14669be2a247:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Get_LoginName:
        x: 480
        'y': 120
        navigate:
          bf790c47-e54b-cfa7-7cb8-8dd830971638:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Reset_Password:
        x: 1200
        'y': 520
        navigate:
          d0c18f5b-9337-4183-7a89-7dbe1036d04e:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
          646a2563-2a2b-0d1c-10ba-7d98d922640f:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
      Unlock_Account:
        x: 1360
        'y': 120
        navigate:
          f582ed88-df61-28d3-1683-da84692511c7:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Compare_Account_Locked_Status:
        x: 1200
        'y': 120
      Get_UserDN:
        x: 640
        'y': 120
        navigate:
          4f7a1f7a-b2a8-e56d-7dad-c7d7cd6d9d4b:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Check_Account_Locked_Status:
        x: 1040
        'y': 120
        navigate:
          d83bfc12-d532-a2cb-3f12-831a7108acb2:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
    results:
      SUCCESS:
        155be301-aca3-f450-91a9-f10865e03b6b:
          x: 840
          'y': 560
      FAILURE:
        1be41d02-a4a7-513a-a73e-fc1ae38e2deb:
          x: 360
          'y': 360
