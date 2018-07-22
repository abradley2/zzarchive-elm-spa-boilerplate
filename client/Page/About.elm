module Page.About exposing (view, load, onMsg, Msg, Model)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Types exposing (Taco)


type alias Model =
    {}


type Msg
    = NoOp


onMsg : Msg -> ( Model, Taco ) -> ( Model, Cmd Msg )
onMsg msg ( model, taco ) =
    case msg of
        NoOp ->
            ( model, Cmd.none )


load : Taco -> ( Model, Cmd Msg )
load taco =
    ( {}, Cmd.none )


view : ( Model, Taco ) -> Html Msg
view ( model, taco ) =
    div []
        [ h3 [] [ text "just some other page" ]
        , a [ href "/", attribute "data-link" "" ] [ text "I feel so broke up, I wanna go home" ]
        ]
