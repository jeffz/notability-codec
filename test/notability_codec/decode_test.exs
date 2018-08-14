defmodule NotabilityCodec.DecodeTest do
  use ExUnit.Case

  alias NotabilityCodec.Decode

  test "opens a .note file if it exists" do
    {:ok, zip_handle} = Decode.open_note("test/sample.note")
    assert is_pid(zip_handle)
  end

  test "returns an error a .note file doesn't exist" do
    {:error, reason} = Decode.open_note("test/foo.note")
    assert reason == :enoent
  end
end
