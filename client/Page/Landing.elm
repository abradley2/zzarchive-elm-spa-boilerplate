module Page.Landing exposing (view, load, onMsg, Msg, Model)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Types exposing (Taco)


type alias Model =
    { message : String
    }


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


load : Taco -> ( Model, Cmd Msg )
load taco =
    ( { message = "beep boop" }, Cmd.none )


view : ( Model, Taco ) -> Html Msg
view ( model, taco ) =
    div []
        [ h3 [] [ text model.message ]
        , input [ type_ "text", value model.message, onInput EditMessage ] []
        , div []
            [ a [ href "/about", attribute "data-link" "" ] [ text "about page" ]
            ]
        , h3 []
            [ text <|
                if taco.isOnline then
                    "You are online"
                else
                    "You are offline"
            ]
        ]
