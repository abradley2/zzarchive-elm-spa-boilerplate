module Types exposing (..)


type TacoMsg
    = TacoNoOp
    | OnlineStatusChanged
    | LandingRoute
    | NotFoundRoute


type alias Flags =
    {}


type alias Taco =
    { flags : Flags
    , route : TacoMsg
    , isOnline : Bool
    }
