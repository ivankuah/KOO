namespace: AD_Management_DEV
flow:
  name: AD_ENABLE_USER_DEV
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
          - enableUserResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: Enable_User
    - Enable_User:
        do_external:
          16a531df-401a-4c9e-a57d-6c4ec929bac1:
            - host: '${AD_Host}'
            - username: '${AD_AdminUser}'
            - password:
                value: '${AD_AdminPass}'
                sensitive: true
            - OU: '${OU}'
            - userFullName: '${UserFullName}'
        publish:
          - enableUserResult: '${returnResult}'
        navigate:
          - success: Is_User_Enabled_Validation
          - failure: FAILURE
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
          - enableUserResult: '${returnResult}'
        navigate:
          - success: SUCCESS
          - failure: FAILURE
  outputs:
    - OOResult: '${enableUserResult}'
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
          5a18e936-9d7d-8115-b027-c873fc4759d8:
            targetId: 38c3689d-505e-ed63-6031-b37dec84be1b
            port: success
      Enable_User:
        x: 600
        'y': 240
        navigate:
          5487c035-8fd7-78e1-08a1-38e8a8e6a6c1:
            targetId: 48ea08fe-77dc-b9d4-b74c-9c2dfec02c46
            port: failure
      Is_User_Enabled_Validation:
        x: 760
        'y': 360
        navigate:
          63719de0-d0d3-96e6-3ad2-9aec0cf9ab18:
            targetId: 38c3689d-505e-ed63-6031-b37dec84be1b
            port: success
          5f657b19-3714-c683-dd47-b227f2333c39:
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
