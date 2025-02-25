# defmodule ShaderApiWeb.ShaderController do
#   use ShaderApiWeb, :controller

#   alias Req

#   @api_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
#   @api_key "AIzaSyByF2E_4jEvoza7EnZEXag-TdwUg8uQd0I" # Load API key from environment variable

#   def generate(conn, %{"prompt" => prompt}) do
#     request_body = %{
#       "contents" => [
#         %{"parts" => [%{"text" => "Generate a valid WebGL GLSL shader:\n\n" <> prompt}]}
#       ]
#     }

#     headers = [
#       {"Content-Type", "application/json"},
#       {"Authorization", "Bearer #{@api_key}"}
#     ]

#     full_url = "#{@api_url}?key=#{@api_key}"

#     case Req.post(full_url, json: request_body, headers: headers) do
#       {:ok, %Req.Response{body: %{"candidates" => [%{"content" => %{"parts" => [%{"text" => shader_code}]}}]}}} ->
#         json(conn, %{shader: shader_code})

#       {:error, reason} ->
#         conn
#         |> put_status(:internal_server_error)
#         |> json(%{error: "Failed to generate shader: #{inspect(reason)}"})
#     end
#   end
# end
defmodule ShaderApiWeb.ShaderController do
  use ShaderApiWeb, :controller

  alias Req

  @api_url "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"
  @api_key System.get_env("GEMINI_API_KEY") # Load API key from env variable

  def generate(conn, %{"prompt" => prompt}) do
    request_body = %{
      "contents" => [
        %{"parts" => [%{"text" => "Generate a valid WebGL GLSL shader:\n\n" <> prompt}]}
      ]
    }

    full_url = "#{@api_url}?key=#{@api_key}"

    case Req.post(full_url, json: request_body) do
      {:ok, %Req.Response{status: 200, body: %{"candidates" => [%{"content" => %{"parts" => [%{"text" => shader_code}]}}]}}} ->
        json(conn, %{shader: shader_code})

      {:ok, %Req.Response{status: 401, body: error_body}} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid credentials", details: error_body})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to generate shader", reason: inspect(reason)})
    end
  end
end
