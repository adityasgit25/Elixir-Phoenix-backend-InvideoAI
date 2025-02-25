defmodule ShaderApiWeb.GeminiController do
  use ShaderApiWeb, :controller
  alias HTTPoison

  @api_key System.get_env("GEMINI_API_KEY")
  @gemini_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=#{@api_key}"

  def generate(conn, %{"text" => text}) do
    IO.inspect(@api_key, label: "GEMINI_API_KEY") # Debug statement

    body = %{
      "contents" => [%{"parts" => [%{"text" => "Give me <pre> tag to display the raw shader code being valid GLSL:\n\n" <> text}]}]
    }
    |> Jason.encode!()

    headers = [
      {"Content-Type", "application/json"}
    ]

    options = [timeout: 10_000, recv_timeout: 10_000] # Increase timeout to 10 seconds

    case HTTPoison.post(@gemini_url, body, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        json(conn, Jason.decode!(response_body))

      # {:ok, %HTTPoison.Response{status_code: status_code, body: error_body}} ->
      #   json(conn, %{error: "API request failed", status: status_code, details: error_body})

      # {:error, reason} ->
      #   json(conn, %{error: "Request error", details: reason})
      {:ok, %HTTPoison.Response{status_code: status_code, body: error_body}} ->
        json(conn, %{error: "API request failed", status: status_code, details: Jason.decode!(error_body)})

      {:error, %HTTPoison.Error{reason: reason}} ->
        json(conn, %{error: "Request error", details: inspect(reason)})
    end
  end
end
