port module Main exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Navigation exposing (programWithFlags, Location)
import UrlParser exposing (..)
import Util exposing (tacoMsgPipeline, handleUpdate)
import Types exposing (Flags, Taco, TacoMsg, TacoMsg(..))
import Page.Landing as Landing


type alias Model =
    { taco : Taco
    , landing : Landing.Model
    }


type Msg
    = OnLocationChange Location
    | Navigate ( String, Bool )
    | OnlineStatusChange Bool
    | LandingMsg Landing.Msg


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


updateTaco msg taco =
    case msg of
        OnLocationChange location ->
            ( { taco | route = parseLocation location }
            , parseLocation location
            , Cmd.none
            )

        Navigate ( newUrl, replaceState ) ->
            if replaceState then
                ( taco, TacoNoOp, Navigation.modifyUrl newUrl )
            else
                ( taco, TacoNoOp, Navigation.newUrl newUrl )

        OnlineStatusChange isOnline ->
            ( { taco | isOnline = isOnline }, OnlineStatusChanged, Cmd.none )

        _ ->
            ( taco, TacoNoOp, Cmd.none )


handleTacoMsg tacoMsg model taco tacoCmd =
    tacoMsgPipeline ( tacoMsg, model, taco, tacoCmd )
        -- repeat pattern for all onTacoMsg handlers
        [ ( LandingMsg
          , Landing.onTacoMsg
          , (\model -> model.landing)
          , (\model landing -> { model | landing = landing })
          )
        ]


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

        _ ->
            ( model, commands )


view : Model -> Html Msg
view model =
    div []
        [ case model.taco.route of
            LandingRoute ->
                Html.Styled.map LandingMsg (Landing.view ( model.landing, model.taco ))

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
