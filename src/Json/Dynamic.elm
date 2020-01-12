module Json.Dynamic exposing
    ( Dynamic, dynamic, decoder, equals
    , at, index, filter, find
    , resolve, resolveAt
    )

{-| Process dynamic JSON structures with simple utility functions


# Convenience

@docs Dynamic, dynamic, decoder, equals


# Nested structures

@docs at, index, filter, find


# Resolving values

@docs resolve, resolveAt

-}

import Json.Decode as Decode exposing (Decoder, Value)
import List.Extra


{-| Convenience alias for a dynamic JSON value
-}
type alias Dynamic a =
    Result Decode.Error a


{-| Lift value to a dynamic value
-}
dynamic : a -> Dynamic a
dynamic =
    Ok


{-| Decoder alias. You can use `Decode.value` directly instead.
-}
decoder : Decoder Value
decoder =
    Decode.value


{-| Access a nested JSON value by field name path
-}
at : List String -> Dynamic Value -> Dynamic Value
at path =
    Decode.at path Decode.value
        |> Decode.decodeValue
        |> Result.andThen


{-| Access a nested JSON value by array index
-}
index : Int -> Dynamic Value -> Dynamic Value
index i =
    Decode.index i Decode.value
        |> Decode.decodeValue
        |> Result.andThen


{-| Filters the list of JSON values by the given predicate
-}
filter : (Dynamic Value -> Bool) -> Dynamic Value -> List (Dynamic Value)
filter pred =
    (Decode.list decoder |> Decode.decodeValue |> Result.andThen)
        >> Result.map (List.map dynamic >> List.filter pred)
        >> Result.withDefault []


{-| Finds a matching value from list of JSON values by the given predicate
-}
find : (Dynamic Value -> Bool) -> Dynamic Value -> Maybe (Dynamic Value)
find pred =
    (Decode.list decoder |> Decode.decodeValue |> Result.andThen)
        >> Result.map (List.map dynamic >> List.Extra.find pred)
        >> Result.withDefault Nothing


{-| Convenience function for comparing a dynamic value to a value
-}
equals : a -> Dynamic a -> Bool
equals =
    Ok >> (==)


{-| Resolve the dynamic JSON value to a `Result Decode.Error a`, using the given `Decoder a` to decode it.
-}
resolve :
    Decoder a
    -> Dynamic Value
    -> Dynamic a
resolve =
    Decode.decodeValue >> Result.andThen


{-| Resolve nested dynamic JSON value by field name path to a `Result Decode.Error a`, using the given `Decoder a` to decode it.
-}
resolveAt :
    List String
    -> Decoder a
    -> Dynamic Value
    -> Dynamic a
resolveAt path d =
    at path
        >> resolve d
