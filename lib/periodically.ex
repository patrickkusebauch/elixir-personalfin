defmodule Personalfin.Periodically do
  @moduledoc false

  use GenServer
  alias Personalfin.Management
  alias Personalfin.Nordigen
  alias Personalfin.Transaction

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    update_accounts()
    update_transactions()

    schedule_update_accounts()
    schedule_update_transactions()

    {:ok, state}
  end

  def handle_info(:update_accounts, state) do
    update_accounts()
    schedule_update_accounts()
    {:noreply, state}
  end

  def handle_info(:update_transactions, state) do
    update_transactions()
    schedule_update_transactions()
    {:noreply, state}
  end

  defp schedule_update_accounts do
    Process.send_after(self(), :update_accounts, 12 * 60 * 60 * 1000)
  end

  defp schedule_update_transactions do
    Process.send_after(self(), :update_transactions, 12 * 60 * 60 * 1000)
  end

  defp update_transactions do
    token = Nordigen.get_token()

    account = Personalfin.Management.get_account_by_name("AirBank")

    response =
      HTTPoison.get!("https://ob.nordigen.com/api/v2/accounts/#{account.nordigen}/transactions/",
        Authorization: "Bearer #{token["access"]}",
        Accept: "application/json"
      )

    if response.status_code == 200 do
      Jason.decode!(response.body)["transactions"]["booked"]
      |> Enum.map(fn trans ->
        %Transaction{
          id: trans["entryReference"],
          amount: trans["transactionAmount"]["amount"] |> String.to_float(),
          date: trans["bookingDate"] |> Date.from_iso8601!(),
          notes:
            Map.get(trans, "additionalInformation", "Unknown") <>
              " - " <> Map.get(trans, "creditorName", Map.get(trans, "debtorName", "Unknown"))
        }
      end)
      |> Enum.each(fn trans -> trans |> Personalfin.Repo.insert(on_conflict: :nothing) end)
    end
  end

  defp update_accounts do
    for account <- Personalfin.Management.list_accounts() do
      update_account(account)
    end
  end

  defp update_account(account) when is_nil(account.nordigen), do: nil

  defp update_account(account) do
    token = Nordigen.get_token()
    nordigen_id = account.nordigen

    response =
      HTTPoison.get("https://ob.nordigen.com/api/v2/accounts/#{nordigen_id}/balances/",
        Authorization: "Bearer #{token["access"]}",
        Accept: "application/json"
      )

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        balance =
          Jason.decode!(body)["balances"]
          |> Enum.filter(fn bal -> bal["balanceAmount"]["currency"] == account.currency end)
          |> List.first()
          |> Map.get("balanceAmount")
          |> Map.get("amount")

        Management.update_account(account, %{last_access: DateTime.utc_now(), balance: balance})

      {:ok, %HTTPoison.Response{status_code: 401, body: body}} ->
        IO.puts(account.name)
        Jason.decode!(body)["detail"] |> IO.puts()

      {:ok, %HTTPoison.Response{status_code: 400, body: body}} ->
        IO.puts(account.name)
        Jason.decode!(body)["detail"] |> IO.puts()

      _ ->
        IO.puts(account.name)
        IO.inspect(response)
    end
  end
end
