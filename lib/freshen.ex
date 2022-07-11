defmodule Freshen do
  alias HTTPoison.Response
  @moduledoc """
  Library to scrape a RottenTomatoes page for the Critic's and Audience's Score.
  """

  @score_data_expression ~r/\<script\ id=\"score-details-json\"\ type=\"application\/json\">(.*)<\/script>/
  @meta_data_expression ~r/movieDetails\s=\s(.*);/
  # @date_parse_expression ~r/([A-Za-z]{3})\s(\d+),\s(\d{4})/
  @year_parse_expression ~r/^(\d*),/
  @url_prefix "https://www.rottentomatoes.com"

  @spec setup :: :ignore | {:error, any} | {:ok, pid}
  def setup do
    HTTPoison.start
  end

  @doc """
  Print JSON output for a film title's stats.

  ## Examples

      iex> Freshen.get_stats("/m/army_of_darkness")
      {:ok, "{\"audience_score\":\"87\",\"critics_score\":\"73\",\"movie_title\":\"Army of Darkness\",
      \"release_date\":\"Feb 19, 1993\"}"}

  """
  def get_stats(path) do
    IO.puts("Getting title #{path}")

    HTTPoison.get("#{@url_prefix}#{path}")
    |> handle_response(path)
  end

  defp handle_response({:error, err = %HTTPoison.Error{}}, path) do
    {:error, "Unable to get info for #{path}\nReason: #{err.reason}"}
  end

  defp handle_response({:ok, %Response{body: body}}, path) do
    score_data_json = decode_capture(path, Regex.run(@score_data_expression, body))
    meta_data_json = decode_capture(path, Regex.run(@meta_data_expression, body))

    info = Map.get(score_data_json, "scoreboard")
           |> Map.get("info")
    year = decode_capture(nil, Regex.run(@year_parse_expression, info))

    movie_title = Map.get(meta_data_json, "title")
    critics_score = Map.get(score_data_json, "scoreboard")
                    |> Map.get("tomatometerScore")
    audience_score = Map.get(score_data_json, "scoreboard")
                     |> Map.get("audienceScore")

    json_output = %{release_year: year, movie_title: movie_title,
                    critics_score: critics_score, audience_score: audience_score}
                  |> Jason.encode!()

    {:ok, json_output}
  end

  defp decode_capture(title, regex_capture_enum) when regex_capture_enum == nil do
    {:error, "No such title '#{title}'."}
  end

  defp decode_capture(_title, regex_capture_enum) do
    regex_capture_enum
    |> Enum.take(-1)
    |> Jason.decode!()
  end
end
