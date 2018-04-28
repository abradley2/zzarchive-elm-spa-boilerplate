module Types exposing (..)


type TacoMsg
    = TacoNoOp
    | OnlineStatusChanged
    | LandingRoute
    | AboutRoute
    | NotFoundRoute


type alias Flags =
    { apiUrl : String
    , env : String
    }


type alias Taco =
    { flags : Flags
    , route : TacoMsg
    , href : String
    , isOnline : Bool
    }


type alias HelloResponse =
    { message : String }
