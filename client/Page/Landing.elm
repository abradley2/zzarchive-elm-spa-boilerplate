module Page.Landing exposing (initialModel, view, onMsg, onTacoMsg, Msg, Model)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Types exposing (Taco, TacoMsg, TacoMsg(..))


type alias Model =
    { message : String
    }


initialModel =
    { message = "beep boop" }


type Msg
    = NoOp
    | EditMessage String


onMsg : Msg -> ( Model, Taco ) -> ( Model, Cmd Msg )
onMsg msg ( model, taco ) =
    case msg of
        EditMessage newMessage ->
            ( { model | message = newMessage }, Cmd.none )

        _ ->
            ( model, Cmd.none )


onTacoMsg : TacoMsg -> ( Model, Taco ) -> ( Model, Cmd Msg )
onTacoMsg msg ( model, taco ) =
    case msg of
        LandingRoute ->
            ( initialModel, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : ( Model, Taco ) -> Html Msg
view ( model, taco ) =
    div []
        [ h3 [] [ text model.message ]
        , input [ type_ "text", value model.message, onInput EditMessage ] []
        ]
