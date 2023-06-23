defmodule Personalfin.Nordigen do
  @moduledoc false

  def get_bank do
    HTTPoison.get!(
      "https://ob.nordigen.com/api/v2/institutions/?country=cz",
      Authorization: "Bearer #{get_token()["access"]}",
      Accept: "application/json"
    )
    |> Map.get(:body)
    |> Jason.decode!()
    |> Enum.each(fn bank -> bank |> IO.puts() end)
  end

  def get_token do
    client =
      HTTPoison.post(
        "https://ob.nordigen.com/api/v2/token/new/",
        Jason.encode!(%{
          secret_id: System.get_env("NORDIGEN_ID"),
          secret_key: System.get_env("NORDIGEN_SECRET")
        }),
        "Content-type": "application/json"
      )

    case client do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> Jason.decode!(body)
      _ -> nil
    end
  end
end
