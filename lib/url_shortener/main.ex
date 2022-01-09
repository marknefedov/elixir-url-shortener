defmodule UrlShortener.Router do
  require Logger
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)
  plug(:dispatch)

  get "/r/:redir" do
    Logger.info("Requested redir " <> redir)

    case Mongo.find_one(:mongo, "redirect_rules", %{"from_url" => redir}) do
      nil ->
        send_resp(conn, 404, "404 Redirect not found")

      doc ->
        Logger.info("Doc #{inspect(doc)}")

        Mongo.insert_one(:mongo, "redirects", %{
          "from" => redir,
          "end_url" => doc["end_url"],
          "ip" => conn.remote_ip |> :inet.ntoa() |> to_string(),
          "headers" => conn.req_headers
        })

        conn
        |> resp(301, "")
        |> put_resp_header("location", doc["end_url"])
        |> send_resp
    end
  end

  post "/api/create_url" do
    {status, body} =
      case conn.body_params do
        %{"end_url" => end_url} -> create_redirect_url(end_url, 7)
        _ -> {422, malformed_structure()}
      end

    send_resp(conn, status, body)
  end

  get _ do
    send_resp(conn, 404, "404 Not found")
  end

  defp malformed_structure do
    Jason.encode!(%{error: "Unknown playoad schema"})
  end

  @spec create_redirect_url(String.t(), integer) :: {integer(), String.t()}
  defp create_redirect_url(end_url, new_url_lenght) do
    redirect_rules_collection_name = "redirect_rules"

    rand_string =
      :crypto.strong_rand_bytes(new_url_lenght)
      |> Base.encode64()
      |> binary_part(0, new_url_lenght)

    if Mongo.find_one(:mongo, redirect_rules_collection_name, %{"from_url" => rand_string}) != nil do
      create_redirect_url(end_url, new_url_lenght)
    end

    case Mongo.insert_one(:mongo, redirect_rules_collection_name, %{
           "end_url" => end_url,
           "from_url" => rand_string
         }) do
      {:ok, _} ->
        Logger.info("Created url from " <> end_url <> " to " <> rand_string)

        {200,
         Jason.encode!(%{
           "redirect_url" => Application.fetch_env!(:url_shortener, :base_url) <> rand_string
         })}

      {:error, error} ->
        Logger.error("Error occured: " <> error.message)
        {500, "Internal server error"}
    end
  end
end
