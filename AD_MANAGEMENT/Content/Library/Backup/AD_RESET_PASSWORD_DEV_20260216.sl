namespace: Backup
flow:
  name: AD_RESET_PASSWORD_DEV_20260216
  inputs:
    - AD_Host: KIBBHQADC01.kenanga.local
    - AD_AdminUser: "kenanga\\svcitsmuat"
    - AD_AdminPass:
        default: 'RZqs55sy6uS92b0!'
        sensitive: true
    - RASIP:
        default: 172.21.5.157
        required: false
    - EmailAddress
    - NewPassword:
        sensitive: true
  workflow:
    - Get_FullName:
        do_external:
          69053705-6863-4561-a274-50adea4f1575:
            - host: '${AD_Host}'
            - DN: 'DC=kenanga,DC=local'
            - filter: "${'(&(objectClass=person)(mail='+EmailAddress+'))'}"
            - propertyName: cn
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '636'
            - useSSL: 'true'
            - trustAllRoots: 'true'
        publish:
          - fullNameResult: '${returnResult}'
          - resetPasswordResult: '${returnResult}'
        navigate:
          - success: Get_LoginName
          - failure: FAILURE
    - Get_LoginName:
        do_external:
          69053705-6863-4561-a274-50adea4f1575:
            - host: '${AD_Host}'
            - DN: 'DC=kenanga,DC=local'
            - filter: "${'(&(objectClass=person)(mail='+EmailAddress+'))'}"
            - propertyName: sAMAccountName
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '636'
            - useSSL: 'true'
            - trustAllRoots: 'true'
        publish:
          - loginNameResult: '${returnResult}'
          - resetPasswordResult: '${returnResult}'
        navigate:
          - success: Get_UserDN
          - failure: FAILURE
    - Get_UserDN:
        do_external:
          69053705-6863-4561-a274-50adea4f1575:
            - host: '${AD_Host}'
            - DN: 'DC=kenanga,DC=local'
            - filter: "${'(&(objectClass=person)(mail='+EmailAddress+'))'}"
            - propertyName: distinguishedName
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '636'
            - useSSL: 'true'
            - trustAllRoots: 'true'
        publish:
          - dnResult: '${cs_regex(returnResult, "OU=.*$")}'
          - resetPasswordResult: '${returnResult}'
          - userDNResult: '${returnResult}'
        navigate:
          - success: Is_User_Enabled
          - failure: FAILURE
    - Is_User_Enabled:
        do_external:
          04182cf5-9a10-4614-9642-9e204ba9fd8c:
            - host: '${AD_Host}'
            - OU: '${dnResult}'
            - userCommonName: '${fullNameResult}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - useSSL: 'true'
            - trustAllRoots: 'true'
        publish:
          - isUserEnabledResult: '${returnResult}'
          - resetPasswordResult: '${returnResult}'
        navigate:
          - success: Check_Account_Locked_Status
          - failure: FAILURE
    - Reset_Password:
        do_external:
          2a046469-b79b-47ff-960c-b62c31df37ad:
            - host: '${AD_Host}'
            - userDN: '${userDNResult}'
            - userPassword:
                value: '${NewPassword}'
                sensitive: true
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - useSSL: 'true'
            - trustAllRoots: 'true'
        publish:
          - resetPasswordResult: '${cs_replace(returnResult,"Password Changed","Your password has been successfully reset. You may now log in with your new password.")}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
    - Check_Account_Locked_Status:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${RASIP}'
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
    - Compare_Account_Locked_Status:
        do_external:
          67afd43a-09e6-4d62-8876-2339c1945360:
            - String1: '${unlockAccountResult}'
            - String2: 'False'
        publish:
          - resetPasswordResult: '${cs_replace(String1, "False", "Your account is currently unlocked.")}'
        navigate:
          - failure: Unlock_Account
          - same: Reset_Password
    - Unlock_Account:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${RASIP}'
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
            - host: '${RASIP}'
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
    - Compare_Account_Locked_Status_After_Unlock:
        do_external:
          67afd43a-09e6-4d62-8876-2339c1945360:
            - String1: '${unlockAccountResult}'
            - String2: 'False'
        publish:
          - resetPasswordResult: '${cs_replace(String1, "False", "Your account has been successfully unlocked.")}'
        navigate:
          - failure: FAILURE
          - same: Reset_Password
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
          1360fb52-ad28-24d2-63ce-7db5a8100043:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Get_FullName:
        x: 280
        'y': 120
        navigate:
          29852fdb-5e64-5f1d-0f69-152d2c9bd256:
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
          1749f280-8fc4-7b74-248c-a94fc554ee27:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Get_LoginName:
        x: 480
        'y': 120
        navigate:
          e183dc78-cb64-f797-828a-d4de7a7b8824:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Reset_Password:
        x: 1080
        'y': 520
        navigate:
          4b1abb0a-7026-5f10-ee80-226073d2afc9:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
          b6e64efa-e813-4389-18c3-568014988bfe:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
      Unlock_Account:
        x: 1360
        'y': 120
        navigate:
          cb78791f-816d-b1fa-f9e2-dcdff5cd86f1:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Compare_Account_Locked_Status:
        x: 1200
        'y': 120
      Get_UserDN:
        x: 680
        'y': 120
        navigate:
          3e02e427-02f5-b036-f798-9676e9a639e2:
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
