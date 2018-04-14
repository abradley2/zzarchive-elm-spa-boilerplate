module Util exposing (..)

import Types exposing (TacoMsg(..))


tacoMsgPipeline ( tacoMsg, model, taco, tacoCmd ) handlers =
    case tacoMsg of
        TacoNoOp ->
            ( model, tacoCmd )

        _ ->
            List.foldr
                (\reducer ( model, commands ) -> reducer ( model, commands ))
                ( { model | taco = taco }, tacoCmd )
                (List.map
                    (\( msgMap, onTacoMsg, getter, setter ) ( model, commands ) ->
                        let
                            ( modelSlice, newCmd ) =
                                onTacoMsg tacoMsg ( getter model, model.taco )
                        in
                            ( setter model modelSlice, Cmd.batch [ (Cmd.map msgMap newCmd), commands ] )
                    )
                    handlers
                )


handleUpdate ( msgMap, handler, getter, setter ) =
    let
        ( newModelSlice, cmd ) =
            handler getter
    in
        ( setter newModelSlice, Cmd.map msgMap cmd )
