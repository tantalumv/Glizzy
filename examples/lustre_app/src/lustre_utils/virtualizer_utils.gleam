import gleam/int
import gleam/list
import lustre/attribute.{attribute}
import lustre/element.{type Element, text}
import ui/virtualizer

pub fn generate_virtualizer_items(count: Int) -> List(Element(msg)) {
  // Generate list from 1 to count
  let items =
    int.range(from: 1, to: count + 1, with: [], run: fn(acc, i) {
      [i, ..acc]
    })
    |> list.reverse
  list.map(items, fn(i) {
    let padded = case i {
      n if n < 10 -> "00" <> int.to_string(i)
      n if n < 100 -> "0" <> int.to_string(i)
      _ -> int.to_string(i)
    }
    virtualizer.item([attribute("data-testid", "vitem-" <> padded)], [
      text("Item " <> padded),
    ])
  })
}
