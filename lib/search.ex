defmodule Search do
  alias HTTPoison.Response

  @url_prefix "https://www.rottentomatoes.com/napi/search/?"

  @spec setup :: :ignore | {:error, any} | {:ok, pid}
  def setup do
    HTTPoison.start
  end

  def get_results(term) do
    encoded_term = %{"query" => term, "limit" => 25, "type" => "movie"} |> URI.encode_query

    HTTPoison.get("#{@url_prefix}#{encoded_term}")
    |> handle_response(term)
  end

  defp handle_response({:error, err = %HTTPoison.Error{}}, term) do
    {:error, "Unable to search for #{term}.\nReason: #{err.reason}"}
  end

  defp handle_response({:ok, %Response{body: body}}, _term) do
    Jason.decode!(body)
    |> Map.get("movies", %{})
    |> to_tuples
  end

  defp to_tuples(nil) do
    []
  end

  defp to_tuples(item_array) do
    item_array
    |> Enum.map(fn item -> {Map.get(item, "name"), Map.get(item, "url"), Map.get(item, "year")} end)
  end
end
