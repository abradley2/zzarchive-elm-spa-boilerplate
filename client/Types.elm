module Types exposing (..)

import Navigation exposing (Location)


type TacoMsg
    = TacoNoOp
    | OnlineStatusChanged
    | LandingRoute
    | AboutRoute
    | NotFoundRoute


type alias Flags =
    {}


type alias Taco =
    { flags : Flags
    , route : TacoMsg
    , location : Location
    , isOnline : Bool
    }
