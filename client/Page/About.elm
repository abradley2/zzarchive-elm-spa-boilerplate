module Page.About exposing (view, onMsg, onTacoMsg, initialModel, Msg, Model)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Types exposing (Taco, TacoMsg, TacoMsg(..))


type alias Model =
    { onlineStatusAltered : Bool }


initialModel : Model
initialModel =
    { onlineStatusAltered = False }


type Msg
    = NoOp


onTacoMsg : TacoMsg -> ( Model, Taco ) -> ( Model, Cmd Msg )
onTacoMsg tacoMsg ( model, taco ) =
    case tacoMsg of
        AboutRoute ->
            ( initialModel, Cmd.none )

        OnlineStatusChanged ->
            ( { model | onlineStatusAltered = True }, Cmd.none )

        _ ->
            ( model, Cmd.none )


onMsg : Msg -> ( Model, Taco ) -> ( Model, Cmd Msg )
onMsg msg ( model, taco ) =
    case msg of
        NoOp ->
            ( model, Cmd.none )


view : ( Model, Taco ) -> Html Msg
view ( model, taco ) =
    div []
        [ h3 [] [ text "just some other page" ]
        , a [ href "/", attribute "data-link" "/" ] [ text "I feel so broke up, I wanna go home" ]
        , if model.onlineStatusAltered then
            h3 [] [ text "online status has been altered since visiting this page" ]
          else
            span [] []
        ]
