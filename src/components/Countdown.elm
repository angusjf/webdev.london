module Countdown exposing (main, propsDecoder)

import Browser
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, id)
import Json.Decode exposing (Value)
import Task
import Time exposing (Posix, millisToPosix, posixToMillis)


type alias Props =
    { to : Posix
    , from : Posix
    }


init : Value -> ( Props, Cmd Posix )
init flags =
    ( decodeFlags flags, Task.perform identity Time.now )


decodeFlags : Value -> Props
decodeFlags value =
    value
        |> Json.Decode.decodeValue propsDecoder
        |> Result.withDefault { to = millisToPosix 10000, from = millisToPosix 0 }


propsDecoder : Json.Decode.Decoder Props
propsDecoder =
    Json.Decode.map2 Props
        (Json.Decode.field "to" (Json.Decode.map millisToPosix <| Json.Decode.int))
        (Json.Decode.field "from" (Json.Decode.map millisToPosix <| Json.Decode.int))


mod : Float -> Int -> Float
mod x y =
    toFloat <| modBy y (floor x)


between : Posix -> Posix -> { w : Float, d : Float, h : Float, m : Float, s : Float }
between from to =
    let
        msrMs =
            toFloat <| abs (posixToMillis to) - posixToMillis from

        msrSeconds =
            msrMs - mod msrMs 1000

        s =
            mod msrSeconds (1000 * 60) / 1000

        msrMins =
            msrSeconds - s * 1000

        m =
            mod msrMins (1000 * 60 * 60) / (1000 * 60)

        msrHours =
            msrMins - m * 1000 * 60

        h =
            mod msrHours (1000 * 60 * 60 * 24) / (1000 * 60 * 60)

        msrDays =
            msrHours - h * 1000 * 60 * 60

        d =
            mod msrDays (1000 * 60 * 60 * 24 * 7) / (1000 * 60 * 60 * 24)

        msrWeeks =
            msrDays - d * 1000 * 60 * 60 * 24

        w =
            msrWeeks / (1000 * 60 * 60 * 24 * 7)
    in
    { w = w, d = d, h = h, m = m, s = s }


view : Props -> Html msg
view { from, to } =
    let
        { w, d, h, m, s } =
            between from to

        fmt =
            floor >> String.fromInt >> String.padLeft 2 '0' >> text
    in
    div [ class "countdown" ]
        [ span [ id "w", class "number" ] [ fmt w ]
        , text "weeks"
        , span [ id "d", class "number" ] [ fmt d ]
        , text "days"
        , span [ id "h", class "number" ] [ fmt h ]
        , text "h"
        , span [ id "m", class "number" ] [ fmt m ]
        , text "m"
        , span [ id "s", class "number" ] [ fmt s ]
        , text "s"
        ]


update : Posix -> Props -> ( Props, Cmd Posix )
update now model =
    ( { model | from = now }, Cmd.none )


subscriptions : Props -> Sub Posix
subscriptions _ =
    Time.every 1000 identity


main : Program Value Props Posix
main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }
