port module Main exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Navigation exposing (programWithFlags, Location)
import UrlParser exposing (..)
import Util exposing (handleUpdate, handleTacoUpdate)
import Types exposing (Flags, Taco, TacoMsg, TacoMsg(..))
import Page.Landing as Landing
import Page.About as About


type alias Model =
    { taco : Taco
    , landing : Landing.Model
    , about : About.Model
    }


type Msg
    = OnLocationChange Location
    | Navigate ( String, Bool )
    | OnlineStatusChange Bool
    | LandingMsg Landing.Msg
    | AboutMsg About.Msg


port navigate : (( String, Bool ) -> msg) -> Sub msg


port onlineStatus : (Bool -> msg) -> Sub msg


subscriptions model =
    Sub.batch
        [ navigate Navigate
        , onlineStatus OnlineStatusChange
        ]


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    ( { taco =
            { route = parseLocation location
            , flags = flags
            , isOnline = True
            }
      , landing = Landing.initialModel
      , about = About.initialModel
      }
    , Cmd.none
    )


matchers : Parser (TacoMsg -> a) a
matchers =
    oneOf
        [ UrlParser.map LandingRoute (UrlParser.top)
        ]


parseLocation : Location -> TacoMsg
parseLocation location =
    case (parsePath matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


updateTaco : Msg -> Taco -> ( Taco, TacoMsg, Cmd Msg )
updateTaco msg taco =
    case msg of
        OnlineStatusChange isOnline ->
            ( { taco | isOnline = isOnline }, OnlineStatusChanged, Cmd.none )

        OnLocationChange location ->
            let
                route =
                    parseLocation location
            in
                ( { taco | route = route }
                , route
                , Cmd.none
                )

        Navigate ( newUrl, replaceState ) ->
            if replaceState then
                ( taco, TacoNoOp, Navigation.modifyUrl newUrl )
            else
                ( taco, TacoNoOp, Navigation.newUrl newUrl )

        _ ->
            ( taco, TacoNoOp, Cmd.none )


handleTacoMsg tacoMsg model taco tacoCmd =
    case tacoMsg of
        TacoNoOp ->
            ( model, Cmd.none )

        _ ->
            ( model, tacoCmd )
                |> handleTacoUpdate
                    ( LandingMsg
                    , Landing.onTacoMsg tacoMsg
                    , ( model.landing, model.taco )
                    , (\model landing -> { model | landing = landing })
                    )
                |> handleTacoUpdate
                    ( AboutMsg
                    , About.onTacoMsg tacoMsg
                    , ( model.about, model.taco )
                    , (\model about -> { model | about = about })
                    )


handleMsg msg model commands =
    case msg of
        -- repeat pattern for all onMsg handlers
        LandingMsg landingMsg ->
            handleUpdate
                ( LandingMsg
                , Landing.onMsg landingMsg
                , ( model.landing, model.taco )
                , (\landing -> { model | landing = landing })
                )

        AboutMsg aboutMsg ->
            handleUpdate
                ( AboutMsg
                , About.onMsg aboutMsg
                , ( model.about, model.taco )
                , (\about -> { model | about = about })
                )

        _ ->
            ( model, commands )


view : Model -> Html Msg
view model =
    div []
        [ case model.taco.route of
            LandingRoute ->
                Html.Styled.map LandingMsg (Landing.view ( model.landing, model.taco ))

            AboutRoute ->
                Html.Styled.map AboutMsg (About.view ( model.about, model.taco ))

            _ ->
                div [] [ text "not found" ]
        ]


main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , update =
            (\msg oldModel ->
                let
                    -- update the taco
                    ( newTaco, tacoMsg, tacoCmd ) =
                        updateTaco msg oldModel.taco

                    -- send out any tacoMsg to any page handlers
                    ( model, commands ) =
                        handleTacoMsg tacoMsg oldModel newTaco tacoCmd

                    ( newModel, pageCmd ) =
                        handleMsg msg model commands
                in
                    -- then handle the msg normall
                    ( newModel, Cmd.batch [ pageCmd, commands ] )
            )
        , subscriptions = subscriptions
        , view = view >> toUnstyled
        }
