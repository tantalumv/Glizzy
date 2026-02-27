// MIT License
// Copyright (c) 2026 Koncreate
// See LICENSE for details

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type DecodeError}
import gleam/json
import gleam/result

// ============================================================================
// Types
// ============================================================================

pub type MoveEvent {
  MoveStart(x: Float, y: Float)
  Move(x: Float, y: Float, delta_x: Float, delta_y: Float)
  MoveEnd(x: Float, y: Float)
}

// ============================================================================
// JSON Decoding
// ============================================================================

pub fn decode_move_event(json_string: String) -> Result(MoveEvent, String) {
  // Parse JSON string to Dynamic
  let dynamic_value =
    json_string
    |> json.parse(using: decode.dynamic)
    |> result.map_error(json_decode_error_to_string)

  case dynamic_value {
    Error(msg) -> Error(msg)
    Ok(value) -> decode_move_event_from_dynamic(value)
  }
}

fn json_decode_error_to_string(e: json.DecodeError) -> String {
  case e {
    json.UnexpectedEndOfInput -> "Unexpected end of input"
    json.UnexpectedByte(s) -> "Unexpected byte: " <> s
    json.UnexpectedSequence(s) -> "Unexpected sequence: " <> s
    json.UnableToDecode(errors) -> "Unable to decode: " <> decode_errors_to_string(errors)
  }
}

fn decode_errors_to_string(errors: List(DecodeError)) -> String {
  case errors {
    [e, ..] -> decode_error_to_string(e)
    [] -> "Unknown error"
  }
}

fn decode_error_to_string(e: DecodeError) -> String {
  "Decode error: expected " <> e.expected <> ", found " <> e.found
}

fn decode_move_event_from_dynamic(value: Dynamic) -> Result(MoveEvent, String) {
  use type_val <- result.try(get_string_field(value, "type"))
  case type_val {
    "move_start" -> decode_move_start(value)
    "move" -> decode_move(value)
    "move_end" -> decode_move_end(value)
    t -> Error("Unknown move event type: " <> t)
  }
}

fn decode_move_start(value: Dynamic) -> Result(MoveEvent, String) {
  use x <- result.try(get_float_field(value, "x"))
  use y <- result.try(get_float_field(value, "y"))
  Ok(MoveStart(x, y))
}

fn decode_move(value: Dynamic) -> Result(MoveEvent, String) {
  use x <- result.try(get_float_field(value, "x"))
  use y <- result.try(get_float_field(value, "y"))
  use delta_x <- result.try(get_float_field(value, "deltaX"))
  use delta_y <- result.try(get_float_field(value, "deltaY"))
  Ok(Move(x, y, delta_x, delta_y))
}

fn decode_move_end(value: Dynamic) -> Result(MoveEvent, String) {
  use x <- result.try(get_float_field(value, "x"))
  use y <- result.try(get_float_field(value, "y"))
  Ok(MoveEnd(x, y))
}

fn get_float_field(value: Dynamic, field: String) -> Result(Float, String) {
  value
  |> decode.run(decode.field(field, decode.float, decode.success))
  |> result.map_error(decode_errors_to_string)
}

fn get_string_field(value: Dynamic, field: String) -> Result(String, String) {
  value
  |> decode.run(decode.field(field, decode.string, decode.success))
  |> result.map_error(decode_errors_to_string)
}
