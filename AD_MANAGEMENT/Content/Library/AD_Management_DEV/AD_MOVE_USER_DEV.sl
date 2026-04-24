namespace: AD_Management_DEV
flow:
  name: AD_MOVE_USER_DEV
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
    - TargetOU: 'OU=POC ITSM 02,DC=kenanga,DC=local'
    - OriginalUserDN:
        default: 'CN=ITSM Test User,OU=POC ITSM 01,DC=kenanga,DC=local'
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
            - filter: "${'(&(objectClass=person)(distinguishedName=' + OriginalUserDN + '))'}"
            - propertyName: cn
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - moveUserResult: '${returnResult}'
          - getUserFullName: "${cs_regex(returnResult, \"^CN=([^,\\\\\\\\]*(?:\\\\\\\\,[^,\\\\\\\\]*)*)\")}"
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
            - propertyName: cn
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - moveUserResult: '${returnResult}'
          - getUserFullName: "${cs_regex(returnResult, \"^CN=([^,\\\\\\\\]*(?:\\\\\\\\,[^,\\\\\\\\]*)*)\")}"
        navigate:
          - failure: FAILURE
          - success: Start_Powershell_Session
    - Move_User:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - runspaceID: '${runspaceID}'
            - script: "${'try { Move-ADObject -Identity \"'+ OriginalUserDN + '\" -TargetPath \"'+ TargetOU +'\" -ErrorAction Stop; Write-Output \"SUCCESS: User moved successfully\"} catch { Write-Output \"FAILED: $($_.Exception.Message)\"}'}"
        publish:
          - moveUserResult: '${returnResult}'
        navigate:
          - success: Check_User_After_MoveUser
          - failure: FAILURE
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
          - success: String_Comparator
    - String_Comparator:
        do_external:
          f1dafb35-6463-4a1b-8f87-8aa748497bed:
            - matchType: Exact Match
            - toMatch: '${TargetOU}'
            - matchTo: '${getOUDN}'
            - ignoreCase: 'true'
        publish:
          - moveUserResult: '${cs_replace(returnResult,"Matches","Move Successfully")}'
          - checkMoveUserResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: Search_and_Replace
    - Search_and_Replace:
        do_external:
          6a537995-25a9-4af6-b09d-efc1db705929:
            - input: '${checkMoveUserResult}'
            - replace: '${checkMoveUserResult}'
            - replaceWith: Move Unsuccessfully
        publish:
          - moveUserResult: '${result}'
        navigate:
          - success: FAILURE
          - failure: FAILURE
    - Start_Powershell_Session:
        do_external:
          f0b2afd2-5733-47e4-80ba-7f2387cc66d5:
            - host: '${PowershellHost}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - port: '5985'
            - runspaceID: MoveUser
            - script: Start-Process powershell -Verb RunAs
        publish:
          - moveUserResult: '${returnResult}'
          - runspaceID
        navigate:
          - success: Move_User
          - failure: FAILURE
  outputs:
    - OOResult: '${resetPasswordResult}'
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
      Move_User:
        x: 520
        'y': 480
        navigate:
          f201d57a-3b49-e442-15fb-20e1bb1bd30f:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Check_User_After_MoveUser:
        x: 720
        'y': 360
        navigate:
          79be114d-9411-3811-b47c-43b9fdb5f62c:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      String_Comparator:
        x: 720
        'y': 200
        navigate:
          b1b149ef-cd48-4b3a-f295-e1cd881c0b5d:
            targetId: bbb40bf1-c677-e76b-14a0-e50aa3c42f67
            port: success
      Search_and_Replace:
        x: 720
        'y': 40
        navigate:
          1205f3aa-e0d0-18e5-0fab-ce57186c796b:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: success
          095d83f9-ffab-936c-5a11-4d03d8c80ae1:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
      Start_Powershell_Session:
        x: 520
        'y': 360
        navigate:
          d7391dbf-90aa-d548-b533-5768f45a2289:
            targetId: 1be41d02-a4a7-513a-a73e-fc1ae38e2deb
            port: failure
    results:
      FAILURE:
        1be41d02-a4a7-513a-a73e-fc1ae38e2deb:
          x: 320
          'y': 280
      SUCCESS:
        bbb40bf1-c677-e76b-14a0-e50aa3c42f67:
          x: 920
          'y': 120
