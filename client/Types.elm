module Types exposing (..)


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
    , href : String
    , isOnline : Bool
    }
