namespace: AD_Management_DEV
flow:
  name: AD_DISABLE_USER_DEV
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
    - OU: 'OU=Group Technology,OU=Kenanga Investment Bank'
  workflow:
    - Is_User_Enabled:
        do_external:
          37c16732-1c50-4b63-b8b8-ca3e77868bee:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userFullName: '${UserFullName}'
        publish:
          - disableUserResult: '${returnResult}'
        navigate:
          - success: Disable_User
          - failure: SUCCESS
    - Is_User_Enabled_Validation:
        do_external:
          37c16732-1c50-4b63-b8b8-ca3e77868bee:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userFullName: '${UserFullName}'
        publish:
          - disableUserResult: '${returnResult}'
        navigate:
          - success: FAILURE
          - failure: SUCCESS
    - Disable_User:
        do_external:
          16b48c60-404a-4bdc-9474-0d8f4bc830eb:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userFullName: '${UserFullName}'
        publish:
          - disableUserResult: '${returnResult}'
        navigate:
          - success: Is_User_Enabled_Validation
          - failure: FAILURE
  outputs:
    - OOResult: '${disableUserResult}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      Is_User_Enabled:
        x: 600
        'y': 80
        navigate:
          71568b87-661c-5751-c946-d84cc701cdf7:
            targetId: 38c3689d-505e-ed63-6031-b37dec84be1b
            port: failure
      Is_User_Enabled_Validation:
        x: 760
        'y': 360
        navigate:
          269ed4ce-9b7c-85b9-7a36-10b5c04ca3e2:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: success
          5362c34e-4267-818a-c38e-05e0539f4267:
            targetId: 38c3689d-505e-ed63-6031-b37dec84be1b
            port: failure
      Disable_User:
        x: 600
        'y': 240
        navigate:
          642bf927-a333-1064-a620-0ea19113afcb:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
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
