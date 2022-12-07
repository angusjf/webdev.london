module Countdown exposing (main, propsDecoder)

import Browser
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
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
        |> Result.withDefault { to = millisToPosix 0, from = millisToPosix 0 }


propsDecoder : Json.Decode.Decoder Props
propsDecoder =
    Json.Decode.map2 Props
        (Json.Decode.field "to" decodeTimestamp)
        (Json.Decode.field "from" decodeTimestamp)


decodeTimestamp : Json.Decode.Decoder Posix
decodeTimestamp =
    Json.Decode.map millisToPosix <| Json.Decode.int


break : Int -> List Int -> List Int
break n buckets =
    case buckets of
        [] ->
            []

        bucket :: more ->
            let
                catch =
                    floor <| toFloat n / toFloat bucket
            in
            catch :: break (n - (catch * bucket)) more


accumulate : List number -> List number
accumulate l =
    case l of
        x :: xs ->
            x :: List.map ((*) x) (accumulate xs)

        [] ->
            []


segments : List ( String, number )
segments =
    [ ( "s", 1000 ), ( "m", 60 ), ( "h", 60 ), ( "days", 24 ), ( "weeks", 7 ) ]


view : Props -> Html msg
view { from, to } =
    segments
        |> List.map Tuple.second
        |> accumulate
        |> List.reverse
        |> break (abs (posixToMillis to) - posixToMillis from)
        |> List.map2
            (\label n ->
                [ span
                    [ class "number" ]
                    [ n
                        |> String.fromInt
                        |> String.padLeft 2 '0'
                        |> text
                    ]
                , text label
                ]
            )
            (segments
                |> List.reverse
                |> List.map Tuple.first
            )
        |> List.concat
        |> div [ class "countdown" ]


update : Posix -> Props -> ( Props, Cmd Posix )
update now model =
    ( { model | from = now }, Cmd.none )


subscriptions : Props -> Sub Posix
subscriptions _ =
    Time.every 1000 identity


main : Program Value Props Posix
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
