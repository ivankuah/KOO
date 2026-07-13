namespace: Backup
flow:
  name: VALIDATE_USER
  inputs:
    - AD_Host: KIBBHQADC01.kenanga.local
    - AD_AdminUser: "kenanga\\svcitsmuat"
    - AD_AdminPass:
        default: 'RZqs55sy6uS92b0!'
        sensitive: true
    - EmailAddress: temp_itsm@kenanga.com.my
    - Password:
        default: Automation@123
        sensitive: true
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
          - createUserResult: "${returnResult + ' User Exist In AD'}"
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
      Check_User:
        x: 541.9027099609375
        'y': 186.48263549804688
        navigate:
          db62be13-3c34-b288-d5ec-2226d25cbe18:
            targetId: 155be301-aca3-f450-91a9-f10865e03b6b
            port: success
          9c18ac5c-b1a6-4728-4158-f91712d8303d:
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
