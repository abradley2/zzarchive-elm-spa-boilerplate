module Page.Landing exposing (initialModel, view, onMsg, onTacoMsg, Msg, Model)

import Http
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Types exposing (Taco, TacoMsg, TacoMsg(..), HelloResponse)
import Request.Hello exposing (..)


type alias Model =
    { message : String
    }


initialModel =
    { message = "beep boop" }


type Msg
    = NoOp
    | EditMessage String
    | HelloResult (Result Http.Error HelloResponse)


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
            ( initialModel, Http.send HelloResult (getMessage taco.flags.apiUrl) )

        _ ->
            ( model, Cmd.none )


view : ( Model, Taco ) -> Html Msg
view ( model, taco ) =
    div []
        [ h3 [] [ text model.message ]
        , input [ type_ "text", value model.message, onInput EditMessage ] []
        , div []
            [ a [ href "/about", attribute "data-link" "/about" ] [ text "about page" ]
            ]
        ]
