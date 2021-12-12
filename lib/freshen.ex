defmodule Freshen do
  alias HTTPoison.Response
  @moduledoc """
  Library to scrape a RottenTomatoes page for the Critic's and Audience's Score.
  """

  @score_data_expression ~r/\<script\ id=\"score-details-json\"\ type=\"application\/json\">(.*)<\/script>/
  @meta_data_expression ~r/movieDetails\s=\s(.*);/
  # @date_parse_expression ~r/([A-Za-z]{3})\s(\d+),\s(\d{4})/
  @year_parse_expression ~r/^(\d*),/
  @month_name_list ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  @url_prefix "https://www.rottentomatoes.com/m"

  @spec setup :: :ignore | {:error, any} | {:ok, pid}
  def setup do
    HTTPoison.start
  end

  @doc """
  Print JSON output for a film title's stats.

  ## Examples

      iex> Freshen.get_stats("Army of Darkness")
      {:ok, "{\"audience_score\":\"87\",\"critics_score\":\"73\",\"movie_title\":\"Army of Darkness\",
      \"release_date\":\"Feb 19, 1993\"}"}

  """
  def get_stats(title_input) do
    title_id = title_input
    |> String.downcase
    |> String.replace(~r/\s/, "_")

    IO.puts("Getting title #{title_id}")

    HTTPoison.get("#{@url_prefix}/#{title_id}")
    |> handle_response(title_input)
  end

  defp handle_response({:error, err = %HTTPoison.Error{}}, title_input) do
    {:error, "Unable to get info for #{title_input}\nReason: #{err.reason}"}
  end

  defp handle_response({:ok, %Response{body: body}}, title_input) do
    score_data_json = decode_capture(title_input, Regex.run(@score_data_expression, body))
    meta_data_json = decode_capture(title_input, Regex.run(@meta_data_expression, body))

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
