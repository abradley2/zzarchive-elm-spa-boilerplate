port module Main exposing (..)

import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (..)
import Navigation exposing (programWithFlags, Location, newUrl, modifyUrl)
import UrlParser exposing (..)
import Types exposing (Flags, Route, Route(..), Taco)
import Page.Landing as Landing
import Page.About as About


type Page
    = Landing Landing.Model
    | About About.Model
    | NotFound (Maybe Bool)


type alias Model =
    { taco : Taco
    , page : Page
    }


type Msg
    = NoOp Never
    | Navigate ( String, Bool )
    | OnLocationChange Location
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
            { route = locationToRoute location
            , href = "@init"
            , flags = flags
            , isOnline = True
            }
      , page = NotFound Nothing
      }
    , Navigation.modifyUrl location.pathname
    )


view : Model -> Html Msg
view model =
    div []
        [ case ( model.page, model.taco.route ) of
            ( Landing landing, LandingRoute ) ->
                Html.Styled.map LandingMsg (Landing.view ( landing, model.taco ))

            ( About about, AboutRoute ) ->
                Html.Styled.map AboutMsg (About.view ( about, model.taco ))

            ( _, _ ) ->
                div [] [ text "not found" ]
        ]


locationToRoute : Location -> Route
locationToRoute location =
    let
        matchers =
            oneOf <|
                [ UrlParser.map LandingRoute (UrlParser.top)
                , UrlParser.map AboutRoute (UrlParser.s "about")
                ]
    in
        case (parsePath matchers location) of
            Just route ->
                route

            Nothing ->
                NotFoundRoute


setRoute : Model -> Route -> Model
setRoute model route =
    let
        taco =
            model.taco

        updatedTaco =
            { taco | route = route }
    in
        { model | taco = updatedTaco }


mapPage ( msgMap, cmdMap ) ( page, msg ) =
    ( msgMap page, Cmd.map cmdMap msg )


loadPage : Model -> ( Model, Cmd Msg )
loadPage model =
    let
        ( page, cmd ) =
            case model.taco.route of
                LandingRoute ->
                    mapPage ( Landing, LandingMsg ) <| Landing.load model.taco

                AboutRoute ->
                    mapPage ( About, AboutMsg ) <| About.load model.taco

                NotFoundRoute ->
                    mapPage ( NotFound, NoOp ) <| ( Nothing, Cmd.none )
    in
        ( { model | page = page }, cmd )


updatePage : Msg -> Model -> ( Page, Cmd Msg )
updatePage msg model =
    case ( msg, model.page ) of
        ( LandingMsg landingMsg, Landing landing ) ->
            mapPage ( Landing, LandingMsg ) <| Landing.onMsg landingMsg ( landing, model.taco )

        ( AboutMsg aboutMsg, About about ) ->
            mapPage ( About, AboutMsg ) <| About.onMsg aboutMsg ( about, model.taco )

        _ ->
            ( model.page, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    {- handle all other (session) messages -}
    case msg of
        OnLocationChange location ->
            (locationToRoute >> setRoute model >> loadPage) (location)

        Navigate ( href, replaceState ) ->
            ( model
            , if replaceState then
                modifyUrl href
              else
                newUrl href
            )

        _ ->
            let
                ( page, cmd ) =
                    updatePage msg model
            in
                ( { model | page = page }, cmd )


main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> toUnstyled
        }
