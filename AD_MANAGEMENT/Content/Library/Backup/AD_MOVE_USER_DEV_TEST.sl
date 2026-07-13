namespace: Backup
flow:
  name: AD_MOVE_USER_DEV_TEST
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
    - TargetOU: 'OU=POC ITSM 01,DC=kenanga,DC=local'
    - OriginalUserDN:
        default: 'CN=ITSM Test User 2,OU=POC ITSM 01,DC=kenanga,DC=local'
        sensitive: false
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
            - filter: '(&(objectClass=person)(mail=itsm_testuser5@kenanga.com.my))'
            - propertyName: cn
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - moveUserResult: '${returnResult}'
          - getUserFullName: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Check_TargetOU
    - Check_TargetOU:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(|(&(objectClass=organizationalUnit)(distinguishedName='+ TargetOU + '))(&(objectClass=container)(distinguishedName='+ TargetOU + ')))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - moveUserResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Check_User_After_MoveUser
    - Check_User_After_MoveUser:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=Person)(distinguishedName=CN='+ getUserFullName +','+ TargetOU + '))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - moveUserResult: '${returnResult}'
          - getOUDN: "${cs_regex(returnResult,\"^CN=.*?(?<!\\\\\\\\),(.*)\")}"
        navigate:
          - failure: FAILURE
          - success: SUCCESS
  outputs:
    - OOResult: '${moveUserResult}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      Check_User:
        x: 520
        'y': 40
        navigate:
          4de7b081-4c2a-d4e2-d130-7f2828340f0b:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Check_TargetOU:
        x: 520
        'y': 200
        navigate:
          c78b861e-ef4e-8231-6823-e9ed196de6ca:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Check_User_After_MoveUser:
        x: 720
        'y': 360
        navigate:
          79be114d-9411-3811-b47c-43b9fdb5f62c:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
          9245a8f7-9d71-ff0f-0b8a-fde44a8c1b3a:
            targetId: bbb40bf1-c677-e76b-14a0-e50aa3c42f67
            port: success
    results:
      FAILURE:
        1be41d02-a4a7-513a-a73e-fc1ae38e2deb:
          x: 320
          'y': 280
      SUCCESS:
        bbb40bf1-c677-e76b-14a0-e50aa3c42f67:
          x: 920
          'y': 120
