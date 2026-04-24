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
    - Get_FullName:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(sAMAccountName=' + EmailAddress + '))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - fullNameResult: '${returnResult}'
          - unlockAccountResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Get_LoginName
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
          - dnResult: "${cs_regex(returnResult, \"^CN=[^,\\\\\\\\]*(?:\\\\\\\\.[^,\\\\\\\\]*)*,((?:(?:CN|OU)=[^,\\\\\\\\]*(?:\\\\\\\\.[^,\\\\\\\\]*)*)(?:,(?:CN|OU)=[^,\\\\\\\\]*(?:\\\\\\\\.[^,\\\\\\\\]*)*)*)?,DC=\")}"
          - unlockAccountResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: SUCCESS
  outputs:
    - unlockAccountResult: '${unlockAccountResult}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Get_FullName:
        x: 280
        'y': 120
        navigate:
          80f69eee-8524-3dfd-f114-9cb1e6beef96:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Get_LoginName:
        x: 480
        'y': 120
        navigate:
          4292f322-d1c3-56b8-389f-957157e7bdee:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Get_UserDN:
        x: 680
        'y': 120
        navigate:
          8d91523c-0228-26c4-13ad-35a7c905ce54:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
          b3270698-4b8d-21e2-a21a-cd8056df2c3e:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
    results:
      SUCCESS:
        155be301-aca3-f450-91a9-f10865e03b6b:
          x: 1040
          'y': 200
      FAILURE:
        1be41d02-a4a7-513a-a73e-fc1ae38e2deb:
          x: 440
          'y': 440
