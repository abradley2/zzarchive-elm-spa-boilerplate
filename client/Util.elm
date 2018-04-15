module Util exposing (..)

import Types exposing (TacoMsg(..))


handleUpdate ( msgMap, handler, getter, setter ) =
    let
        ( newModelSlice, cmd ) =
            handler getter
    in
        ( setter newModelSlice, Cmd.map msgMap cmd )


handleTacoUpdate ( msgMap, handler, getter, setter ) ( model, cmds ) =
    let
        ( newModelSlice, cmd ) =
            handler getter
    in
        ( setter model newModelSlice, Cmd.batch [ cmds, Cmd.map msgMap cmd ] )
