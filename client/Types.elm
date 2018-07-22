module Types exposing (..)


type alias Flags =
    {}


type Route
    = AboutRoute
    | LandingRoute
    | NotFoundRoute


type alias Taco =
    { flags : Flags
    , route : Route
    , href : String
    , isOnline : Bool
    }
