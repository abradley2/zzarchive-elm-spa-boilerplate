module Request.Hello exposing (..)

import Http
import Json.Decode as Decode exposing (..)
import Types exposing (HelloResponse)


getMessage apiUrl =
    Http.request
        { method = "GET"
        , headers =
            []
        , url = apiUrl ++ "/hello"
        , body = Http.emptyBody
        , expect =
            Http.expectJson <|
                Decode.map HelloResponse
                    (Decode.field "message" Decode.string)
        , timeout = Nothing
        , withCredentials = False
        }
