# Elm SPA Boilerplate

This architecture is inspired by [elm-taco](https://github.com/ohanhi/elm-taco)
and I've kept the name taco here because
I find it way more fun than "session".

Since I consider "session" to be app-wide state that is shared everywhere though,
I've folded the current route of the app into that- what could be more fitting?

Another diversion is the message pattern. In [elm-taco](https://github.com/ohanhi/elm-taco)
to update the taco you send out special update-taco messages. Here the taco/session
can alter with any message. All messages flow through this update phase and it
may update as seen fit. Conversely this update phase can send messages out to page
updates to let them know an app-level event has occoured. This is where storing the
route data in the taco makes sense- one such message is a route change. So each
page can know when it's being loaded

Let's check out the landing page

```
module Page.Landing exposing (view, onMsg, onTacoMsg)

onMsg : Msg -> ( Model, Taco ) -> ( Model, Cmd Msg )
onMsg msg ( model, taco ) =
    case msg of
        EditMessage newMessage ->
            ( { model | message = newMessage }, Cmd.none )

onTacoMsg : TacoMsg -> ( Model, Taco ) -> ( Model, Cmd Msg )
onTacoMsg msg ( model, taco ) =
    case msg of
        LandingRoute ->
            ( initialModel, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : ( Model, Taco ) -> Html Msg
view ( model, taco ) =
    div []
        [ h3 [] [ text model.message ]
        , input [ type_ "text", value model.message, onInput EditMessage ] []
        ]
```

Each page exposes two update methods with similar signatures, `onMsg` and `onTacoMsg`

In this example, when the landing pages sees that the `TacoMsg` is `LandingRoute` it knows
to reset it's state. In the excellent [elm-spa-example](https://github.com/rtfeldman/elm-spa-example)
this is handled at a higher level, where `pageState` is a piece on the model with a union type
that is whatever page is currently loaded. The reason I opted out of this is I wanted to make it
easy for pages to persist their state if they needed to. For example, if the user is offline.

Let's take a gander at what sending out a `TacoMsg` to the rest of our app looks like:

```
updateTaco : Msg -> Taco -> ( Taco, TacoMsg, Cmd Msg )
updateTaco msg taco =
    case msg of
        OnlineStatusChange isOnline ->
            ( { taco | isOnline = isOnline }, OnlineStatusChanged, Cmd.none )

        OnLocationChange location ->
            let
                route =
                    parseLocation location
            in
                ( { taco | route = route }
                , route
                , Cmd.none
                )
```

So when any message is sent out, `updateTaco` gets it. No matter what message. Whether they are
top-level app messages or sub messages. The two here are top level. When online status is changed
(if our user loses connection or re-connects) we store this in the taco as it's relevant to the
entire app, and we send out a similarly named `TacoMsg` to all our page updaters as they may be
interested in it.

The same applies for `OnLocationChange`. Not only is `route` stored as a piece of state, but it's also
a message, one that can be sent out to pages.

With both these combined a page can say _"Hey, I'm being mounted, I should discard my previous state and
maybe ask the server for the latest"_. But if it's offline it can decide to not discard it's state, show what it has cached,
and let the user know they are offline and they are simply being displayed what was last there as it's
infinitely more pleasant than just getting a blank white screen. 
