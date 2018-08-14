defmodule NotabilityCodec do
  alias NotabilityCodec.Decode

  @moduledoc """
  Documentation for NotabilityCodec.
  """

  @doc """
  Hello world.

  ## Examples

      iex> NotabilityCodec.hello
      :world

  """
  def hello do
    :world
  end

  def decode(filename) do
    with {:ok, zip_handle} <- Decode.open_note(filename),
         {:ok, files} <- Decode.get_files(zip_handle),
         {_filename, binary_plist} <-
           Enum.find(files, fn {filename, _binary} ->
             to_string(filename) |> String.contains?("Session.plist")
           end),
         do: Decode.read_session(binary_plist)
  end
end
