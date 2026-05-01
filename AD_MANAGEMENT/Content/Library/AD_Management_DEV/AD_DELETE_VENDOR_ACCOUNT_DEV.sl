namespace: AD_Management_DEV
flow:
  name: AD_DELETE_VENDOR_ACCOUNT_DEV
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
    - UserFullName: ITSM Test User
    - OU: OU=POC ITSM 02
  workflow:
    - Check_User:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(cn=' + UserFullName + '))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - failure: FAILURE
          - success: Delete_User
    - Delete_User:
        do_external:
          646a39ed-121c-4738-aa36-59e0c34936c6:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userFullName: '${UserFullName}'
        publish:
          - deleteUserResult: '${returnResult}'
        navigate:
          - success: Check_User_After_Deleted
          - failure: FAILURE
    - Check_User_After_Deleted:
        do_external:
          6f9d9ce8-c6c2-40ea-a5f9-66bdef9c27ad:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - filter: "${'(&(objectClass=person)(cn=' + UserFullName + '))'}"
            - propertyName: distinguishedName
            - DN: 'DC=kenanga,DC=local'
            - port: '636'
        publish:
          - deleteUserResult: "${cs_replace(returnResult,\"LDAP object doesn't exist\",\"User Deleted Successfully\")}"
        navigate:
          - failure: SUCCESS
          - success: FAILURE
  outputs:
    - OOResult: '${deleteUserResult}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Check_User:
        x: 640
        'y': 40
        navigate:
          9cda27ab-c97e-7110-408b-e44ca79377dc:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Delete_User:
        x: 640
        'y': 200
        navigate:
          847caf97-03b8-d9d1-3783-701eebbf9c46:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Check_User_After_Deleted:
        x: 640
        'y': 360
        navigate:
          74ffca38-431e-c121-73a6-901cb4876c6f:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: success
          9479e5df-42d3-904c-4bec-cb7048f65405:
            targetId: 38c3689d-505e-ed63-6031-b37dec84be1b
            port: failure
    results:
      SUCCESS:
        38c3689d-505e-ed63-6031-b37dec84be1b:
          x: 840
          'y': 160
      FAILURE:
        48ea08fe-77dc-b9d4-b74c-9c2dfec02c46:
          x: 400
          'y': 280
