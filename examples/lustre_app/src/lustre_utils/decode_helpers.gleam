// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

//// Shared decode helpers for lustre_utils modules.

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/result

pub fn decode_errors_to_string(errors: List(decode.DecodeError)) -> String {
  case errors {
    [e, ..] -> decode_error_to_string(e)
    [] -> "Unknown error"
  }
}

pub fn decode_error_to_string(e: decode.DecodeError) -> String {
  "Decode error: expected " <> e.expected <> ", found " <> e.found
}

pub fn get_string_field(value: Dynamic, field: String) -> Result(String, String) {
  value
  |> decode.run(decode.field(field, decode.string, decode.success))
  |> result.map_error(decode_errors_to_string)
}

pub fn get_float_field(value: Dynamic, field: String) -> Result(Float, String) {
  value
  |> decode.run(decode.field(field, decode.float, decode.success))
  |> result.map_error(decode_errors_to_string)
}
