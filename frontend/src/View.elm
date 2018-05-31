module View exposing (..)

import Model exposing (..)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, defaultValue, href, placeholder, target, type_, value, src, colspan)
import Html.Events exposing (onClick, onInput, onWithOptions)
import Components exposing (..)
import Utils exposing (..)
import Json.Decode as JD
import Update exposing (nodeTypeTxt, nodeAddressLink, nodeAddress)


notification : Notification -> Html Msg
notification notification =
    let
        ( txt, messageClass ) =
            case notification.notification of
                Success str ->
                    ( str, "is-success" )

                Warning str ->
                    ( str, "is-warning" )

                Error str ->
                    ( str, "is-danger" )
    in
        div [ class ("notification on " ++ messageClass) ]
            [ button
                [ class "delete"
                , onClick (DeleteNotification notification.id)
                ]
                []
            , text txt
            ]


notificationsView : Model -> Html Msg
notificationsView model =
    div [ class "toast" ] (model.notifications |> List.map notification)


nodeModal : Model -> Html Msg
nodeModal model =
    let
        modalClass =
            if model.showNode then
                "modal is-active"
            else
                "modal"

        node =
            model.nodeForm

        ( submitButton, cancelButton ) =
            ( (Just ( "Submit", SubmitNode ))
            , (Just ( "Cancel", (ToggleNodeModal Nothing) ))
            )

        title =
            if node.isNew then
                "Create a New Node"
            else
                "Editing Node"
    in
        modalCard model.isLoading
            title
            (ToggleNodeModal Nothing)
            [ form []
                [ fieldInput
                    model.isLoading
                    "Account"
                    node.account
                    "cypherglass1"
                    "user"
                    UpdateNodeFormAccount
                    (not node.isNew)
                , fieldInput
                    model.isLoading
                    "IP"
                    node.ip
                    "127.0.0.1"
                    "server"
                    UpdateNodeFormIp
                    False
                , fieldInput
                    model.isLoading
                    "Port"
                    (toString node.addrPort)
                    "8888"
                    "lock"
                    UpdateNodeFormPort
                    False
                , selectInput
                    model.isLoading
                    [ ( "BP", "BP - Block Producer" )
                    , ( "FN", "FN - Full Node" )
                    , ( "EBP", "EBP - External Block Producer" )
                    ]
                    "Node Type"
                    (nodeTypeTxt node.nodeType)
                    "globe"
                    UpdateNodeFormType
                ]
            ]
            submitButton
            cancelButton


adminLoginModal : Model -> Html Msg
adminLoginModal model =
    let
        modalClass =
            if model.showAdminLogin then
                "modal is-active"
            else
                "modal"

        ( submitButton, cancelButton ) =
            ( (Just ( "Submit", SubmitAdminLogin ))
            , (Just ( "Cancel", ToggleAdminLoginModal ))
            )
    in
        modalCard model.isLoading
            "System Admin Login"
            (ToggleNodeModal Nothing)
            [ form
                [ onWithOptions "submit"
                    { preventDefault = True, stopPropagation = False }
                    (JD.succeed SubmitAdminLogin)
                ]
                [ passwordInput
                    model.isLoading
                    "System Admin Password"
                    model.adminPassword
                    "password"
                    "lock"
                    UpdateAdminLoginPassword
                    False
                ]
            ]
            submitButton
            cancelButton


helpModal : Model -> Html Msg
helpModal model =
    let
        modalClass =
            if model.showHelp then
                "modal is-active"
            else
                "modal"
    in
        modalCard model.isLoading
            "Cypherglass WINDSHIELD - Help/About"
            ToggleHelp
            [ div [ class "content" ]
                [ p [] [ text "Cypherglass WINDSHIELD is a smart tracker of all your nodes: active block producers, full nodes and also external nodes of the EOS chain." ]
                , h3 [] [ text "Nodes Types:" ]
                , ul []
                    [ li []
                        [ b [] [ text "BlockProducer: " ]
                        , text "This is your main EOS Block Producer, you will set this one as the principal node. It's used to query the head block number and as comparison base to other nodes, also you want to keep track of the voting rank of this BP Node account (WINDSHIELD automatically alert you)."
                        ]
                    , li []
                        [ b [] [ text "FullNode: " ]
                        , text "These are your full nodes that you usually publish to the world. WINDSHIELD automatically check if it's healthy and synced to your principal block producer node."
                        ]
                    , li []
                        [ b [] [ text "ExternalNode: " ]
                        , text "These are external Key Nodes that WINDSHIELD keep track for you to see if your BlockProducer is aligned to them or if it's being forked somehow. You need to always update WINDSHIELD with the top 21 block producers public nodes - WINDSHIELD alerts you in case new producers went up to the voting rank."
                        ]
                    ]
                ]
            ]
            Nothing
            Nothing


topMenu : Model -> Html Msg
topMenu model =
    let
        ( welcomeMsg, logButton ) =
            if not (String.isEmpty model.user.token) then
                ( text ("Welcome, " ++ model.user.userName)
                , a
                    [ class "navbar-item help-button"
                    , onClick Logout
                    ]
                    [ span [ class "navbar-item icon is-small" ]
                        [ i [ class "fa fa-2x fa-unlock has-text-danger" ] [] ]
                    ]
                )
            else
                ( text ""
                , a
                    [ class "navbar-item help-button"
                    , onClick ToggleAdminLoginModal
                    ]
                    [ span [ class "navbar-item icon is-small" ]
                        [ i [ class "fa fa-2x fa-lock has-text-primary" ] [] ]
                    ]
                )

        ( isActiveMonitorClass, isActiveAlertsClass, isActiveSettingsClass ) =
            case model.content of
                Home ->
                    ( "is-active", "", "" )

                Alerts ->
                    ( "", "is-active", "" )

                SettingsView ->
                    ( "", "", "is-active" )

        helpButton =
            a
                [ class "navbar-item help-button"
                , onClick ToggleHelp
                ]
                [ span [ class "navbar-item icon is-small" ]
                    [ i [ class "fa fa-2x fa-question-circle has-text-info" ] [] ]
                ]

        monitorButton =
            a [ class ("navbar-item " ++ isActiveMonitorClass), onClick (SetContent Home) ]
                [ icon "dashboard" False False
                , text "Dashboard"
                ]

        alertsButton =
            a [ class ("navbar-item " ++ isActiveAlertsClass), onClick (SetContent Alerts) ]
                [ icon "bell" False False
                , text "Alerts"
                ]

        settingsButton =
            a [ class ("navbar-item " ++ isActiveSettingsClass), onClick (SetContent SettingsView) ]
                [ icon "cog" False False
                , text "Settings"
                ]

        soundIcon =
            "fa fa-2x "
                ++ if model.isMuted then
                    "fa-volume-off has-text-danger"
                   else
                    "fa-volume-up has-text-success"

        soundButton =
            a
                [ class "navbar-item"
                , onClick ToggleSound
                ]
                [ span [ class "navbar-item icon is-small" ]
                    [ i [ class soundIcon ] [] ]
                ]

        content =
            [ p [ class "navbar-item" ] [ loadingIcon model.isLoading ]
            , monitorButton
            , alertsButton
            , settingsButton
            , soundButton
            , helpButton
            , logButton
            ]

        monitorStatus =
            model.monitorState.status

        monitorConnectionStatus =
            if
                model.monitorConnected
                    && (monitorStatus == Active || monitorStatus == Syncing)
            then
                p [ class "has-text-success" ] [ text "Online" ]
            else if model.monitorConnected && monitorStatus == InitialMonitor then
                p [ class "has-text-warning" ] [ text "Pending Initialization" ]
            else
                p [ class "has-text-danger" ] [ text "OFFLINE" ]

        currentProducer =
            case model.currentProducer of
                Just acc ->
                    acc

                Nothing ->
                    "--"
    in
        nav
            [ attribute "aria-label" "main navigation"
            , class "navbar topcg"
            , attribute "role" "navigation"
            ]
            [ div [ class "navbar-brand logo" ]
                [ img [ src "/logo_horizontal.svg" ] []
                , span [] [ text "WINDSHIELD" ]
                , div [ class "monitor-stats" ]
                    [ monitorConnectionStatus
                    , p [] [ text ("Last Synched Block: " ++ (toString model.monitorState.lastBlockNum)) ]
                    , p [ class "has-text-warning" ]
                        [ text "Current Producer: "
                        , b [] [ text currentProducer ]
                        ]
                    ]
                ]
            , div [ class "navbar-menu" ]
                [ div [ class "navbar-end" ]
                    content
                ]
            ]


mainContent : Model -> Html Msg
mainContent model =
    let
        defaultContent content =
            section [ class "section" ]
                [ div [ class "container" ]
                    [ content
                    ]
                ]
    in
        case model.content of
            Home ->
                defaultContent (monitorContent model)

            Alerts ->
                defaultContent (alertsContent model)

            SettingsView ->
                defaultContent (settingsContent model)


alertsContent : Model -> Html Msg
alertsContent model =
    let
        alertRow insideModel alert =
            tr []
                [ td [] [ text alert.alertType ]
                , td [] [ text (calcTimeDiff alert.createdAt insideModel.currentTime) ]
                , td [] [ text alert.description ]
                ]

        alertsRows =
            if List.length model.alerts > 0 then
                model.alerts
                    |> List.take 30
                    |> List.map (\a -> alertRow model a)
            else
                [ tr []
                    [ td [ colspan 3 ] [ text "Yayyy! No alerts!" ]
                    ]
                ]
    in
        div [ class "content" ]
            [ h2 [] [ text "Most Recent Alerts" ]
            , table [ class "table is-striped is-hoverable is-fullwidth" ]
                [ thead []
                    (tr []
                        [ th [] [ text "Type" ]
                        , th [] [ text "When" ]
                        , th [] [ text "Description" ]
                        ]
                        :: alertsRows
                    )
                ]
            ]


monitorContent : Model -> Html Msg
monitorContent model =
    let
        addNodeButton =
            if not (String.isEmpty model.user.token) then
                [ a
                    [ class "button is-success"
                    , onClick (ToggleNodeModal (Just newNode))
                    ]
                    [ text "Add Node" ]
                ]
            else
                [ text "" ]
    in
        div [ class "content" ]
            [ titleMenu
                "Nodes Dashboard"
                addNodeButton
            , nodesList model

            -- , h2 [] [ text "Producers Stats" ]
            -- , producersList model
            ]


nodesList : Model -> Html Msg
nodesList model =
    let
        nodes =
            model.nodes

        nodesRows =
            if List.length nodes > 0 then
                nodes |> List.map (\n -> nodeRow model n)
            else
                [ tr []
                    [ td
                        [ colspan 9
                        , class "has-text-centered"
                        ]
                        [ text "Nodes not loaded" ]
                    ]
                ]
    in
        table [ class "table is-striped is-hoverable is-fullwidth" ]
            [ thead []
                (tr []
                    [ th [] [ text "" ]
                    , th [] [ text "Account" ]
                    , th [] [ text "Address" ]
                    , th [] [ text "Type" ]
                    , th [] [ text "Last Prd Block" ]
                    , th [] [ text "Last Prd At" ]
                    , th [] [ text "Votes" ]
                    , th [] [ text "Status" ]
                    , th [] [ text "Head Block" ]
                    ]
                    :: nodesRows
                )
            ]


nodeRow : Model -> Node -> Html Msg
nodeRow model node =
    let
        ( iconName, className, pingTxt ) =
            case node.status of
                Online ->
                    ( "circle"
                    , "has-text-success"
                    , ("[" ++ (toString node.pingMs) ++ "ms]")
                    )

                UnsynchedBlocks ->
                    ( "circle"
                    , "has-text-warning"
                    , ("[Unsync]")
                    )

                Offline ->
                    ( "power-off", "has-text-danger", "" )

                Initial ->
                    ( "clock-o", "", "" )

        status =
            span [ class className ]
                [ (icon iconName False False)
                , small [] [ text pingTxt ]
                ]

        currentProducer =
            Maybe.withDefault "-" model.currentProducer

        producerClass =
            if currentProducer == node.account then
                "producer-row"
            else
                ""

        nodeTagger txt nodeClass =
            span [ class ("tag " ++ nodeClass) ] [ text txt ]

        ( lastPrdAt, lastPrdBlock, votePercentage, nodeTag ) =
            case node.nodeType of
                BlockProducer ->
                    ( calcTimeDiff node.lastProducedBlockAt model.currentTime
                    , toString node.lastProducedBlock
                    , formatPercentage node.votePercentage
                    , nodeTagger "BlockPrd" "is-success"
                    )

                FullNode ->
                    ( "--", "--", "--", nodeTagger "FullNode" "is-info" )

                ExternalBlockProducer ->
                    ( "--"
                    , "--"
                    , formatPercentage node.votePercentage
                    , nodeTagger "External" "is-light"
                    )
    in
        tr [ class producerClass ]
            [ td []
                [ a [ onClick (ToggleNodeModal (Just node)) ]
                    [ icon "pencil" False False
                    ]
                ]
            , td []
                [ text node.account
                ]
            , td []
                [ a
                    [ href (nodeAddressLink node)
                    , target "_blank"
                    ]
                    [ text (nodeAddress node) ]
                ]
            , td [] [ nodeTag ]
            , td [] [ text lastPrdBlock ]
            , td [] [ text lastPrdAt ]
            , td [] [ text votePercentage ]
            , td [] [ status ]
            , td [] [ text (toString node.headBlockNum) ]
            ]


settingsContent : Model -> Html Msg
settingsContent model =
    let
        settings =
            model.settingsForm

        ( editButton, footer ) =
            if model.editSettingsForm then
                ( [ text "" ], formFooter SubmitSettings ToggleSettingsForm )
            else if not (String.isEmpty model.user.token) then
                ( [ a [ class "button is-info", onClick ToggleSettingsForm ] [ text "Edit Settings" ] ], text "" )
            else
                ( [ text "" ], text "" )
    in
        div [ class "content" ]
            [ titleMenu
                "Settings"
                editButton
            , form []
                [ fieldInput
                    model.isLoading
                    "Principal Node Account"
                    settings.principalNode
                    "cypherglass1"
                    "server"
                    UpdateSettingsFormPrincipalNode
                    (not model.editSettingsForm)
                , div [ class "columns" ]
                    [ div [ class "column" ]
                        [ fieldInput
                            model.isLoading
                            "Monitor Loop Interval (ms)"
                            (toString settings.monitorLoopInterval)
                            "500"
                            "clock-o"
                            UpdateSettingsFormMonitorLoopInterval
                            (not model.editSettingsForm)
                        ]
                    , div [ class "column" ]
                        [ fieldInput
                            model.isLoading
                            "Node Loop Interval (ms)"
                            (toString settings.nodeLoopInterval)
                            "500"
                            "clock-o"
                            UpdateSettingsFormNodeLoopInterval
                            (not model.editSettingsForm)
                        ]
                    , div [ class "column" ]
                        [ fieldInput
                            model.isLoading
                            "Calculate Votes Loop Interval (secs)"
                            (toString settings.calcVotesIntervalSecs)
                            "300"
                            "clock-o"
                            UpdateSettingsFormCalcVotesIntervalSecs
                            (not model.editSettingsForm)
                        ]
                    ]
                , div [ class "columns" ]
                    [ div [ class "column" ]
                        [ fieldInput
                            model.isLoading
                            "Same Error Alert Interval (minutes)"
                            (toString settings.sameAlertIntervalMins)
                            "500"
                            "clock-o"
                            UpdateSettingsFormSameAlertIntervalMins
                            (not model.editSettingsForm)
                        ]
                    , div [ class "column" ]
                        [ fieldInput
                            model.isLoading
                            "Block Production Idle Seconds to emit an Alert"
                            (toString settings.bpToleranceTimeSecs)
                            "180"
                            "bell"
                            UpdateSettingsFormBpToleranceTimeSecs
                            (not model.editSettingsForm)
                        ]
                    , div [ class "column" ]
                        [ fieldInput
                            model.isLoading
                            "Unsynched Blocks to emit an Alert"
                            (toString settings.unsynchedBlocksToAlert)
                            "20"
                            "bell"
                            UpdateSettingsFormUnsynchedBlocksToAlert
                            (not model.editSettingsForm)
                        ]
                    , div [ class "column" ]
                        [ fieldInput
                            model.isLoading
                            "Failed Pings to emit an Alert"
                            (toString settings.failedPingsToAlert)
                            "20"
                            "bell"
                            UpdateSettingsFormFailedPingsToAlert
                            (not model.editSettingsForm)
                        ]
                    ]
                , footer
                ]
            ]


pageFooter : Html Msg
pageFooter =
    footer [ class "footer" ]
        [ div [ class "container" ]
            [ div [ class "content has-text-centered" ]
                [ p []
                    [ strong []
                        [ text "Cypherglass WINDSHIELD" ]
                    , text " "
                    , a [ href "https://github.com/leordev/eos-node-monitor" ]
                        [ text "GitHub" ]
                    , text " - One more Special Tool, built with love, from  "
                    , a [ href "http://cypherglass.com" ]
                        [ text "Cypherglass.com" ]
                    , text "."
                    ]
                ]
            ]
        ]


view : Model -> Html Msg
view model =
    let
        modal =
            if model.showHelp then
                helpModal model
            else if model.showNode then
                nodeModal model
            else if model.showAdminLogin then
                adminLoginModal model
            else
                text ""
    in
        div []
            [ topMenu model
            , notificationsView model
            , mainContent model
            , pageFooter
            , modal
            ]