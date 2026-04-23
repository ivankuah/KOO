namespace: Backup
flow:
  name: VALIDATE_USER
  inputs:
    - AD_Host: KIBBHQADC01.kenanga.local
    - AD_AdminUser: "kenanga\\svcitsmuat"
    - AD_AdminPass:
        default: 'RZqs55sy6uS92b0!'
        sensitive: true
    - EmailAddress
    - Password:
        default: Automation@123
        sensitive: true
  workflow:
    - Get_UserDN:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(samAccountName=' + EmailAddress + '))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - dnResult: "${cs_regex(returnResult, \"^CN=[^,\\\\\\\\]*(?:\\\\\\\\.[^,\\\\\\\\]*)*,((?:(?:CN|OU)=[^,\\\\\\\\]*(?:\\\\\\\\.[^,\\\\\\\\]*)*)(?:,(?:CN|OU)=[^,\\\\\\\\]*(?:\\\\\\\\.[^,\\\\\\\\]*)*)*)?,DC=\")}"
          - unlockAccountResult: '${returnResult}'
          - cnResult: "${cs_regex(returnResult,\"(?<=CN=)(?:\\\\\\\\.|[^,])+\")}"
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
            - userFullName: '${cnResult}'
        publish:
          - returnResult
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
      Get_UserDN:
        x: 400
        'y': 200
        navigate:
          a78099c7-9dd9-0fb6-11f2-188ac45420dc:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Is_User_Enabled:
        x: 560
        'y': 200
        navigate:
          22583587-4b12-4d9f-fd67-9c3f8cd18977:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
          c8f51a18-4b59-ece1-5042-394795a79fdc:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
    results:
      SUCCESS:
        155be301-aca3-f450-91a9-f10865e03b6b:
          x: 680
          'y': 440
      FAILURE:
        1be41d02-a4a7-513a-a73e-fc1ae38e2deb:
          x: 440
          'y': 440
