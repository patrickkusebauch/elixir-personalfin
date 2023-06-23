defmodule PersonalfinWeb.Management.AccountController do
  use PersonalfinWeb, :controller

  alias Personalfin.Management
  alias Personalfin.Management.Account
  alias Personalfin.Rates

  def index(conn, _params) do
    accounts = Management.list_accounts()

    total = Rates.account_total(accounts)

    render(conn, "index.html", accounts: accounts, total: total)
  end

  def new(conn, _params) do
    changeset = Management.change_account(%Account{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"account" => account_params}) do
    case Management.create_account(account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account created successfully.")
        |> redirect(to: Routes.management_account_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    account = Management.get_account!(id)
    changeset = Management.change_account(account)
    render(conn, "edit.html", account: account, changeset: changeset)
  end

  def update(conn, %{"id" => id, "account" => account_params}) do
    account = Management.get_account!(id)

    case Management.update_account(account, account_params) do
      {:ok, account} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: Routes.management_account_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", account: account, changeset: changeset)
    end
  end

  def connect(conn, %{"bank" => bank}) do
    institution_id =
      case bank do
        "AirBank" -> System.get_env("AIRBANK_ID", "AIRBANK_AIRACZPP")
        "Revolut" -> System.get_env("REVOLUT_ID", "REVOLUT_REVOGB21")
        "UniCredit" -> System.get_env("UNICREDIT_ID", "UNICREDIT_BACXCZPP")
      end

    requisitions =
      HTTPoison.post(
        "https://ob.nordigen.com/api/v2/requisitions/",
        Jason.encode!(%{
          redirect: "http://localhost:4000/management/accounts/connected",
          institution_id: institution_id
        }),
        "Content-type": "application/json",
        Authorization: "Bearer #{get_token(conn)["access"]}",
        Accept: "application/json"
      )

    case requisitions do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        requisition = Jason.decode!(body)

        conn
        |> redirect(external: requisition["link"])

      _ ->
        conn
        |> put_flash(:info, "Failed to create requisition")
        |> redirect(to: Routes.management_account_path(conn, :index))
    end
  end

  def connected(conn, %{"ref" => ref}) do
    token = get_token(conn)

    accounts =
      HTTPoison.get("https://ob.nordigen.com/api/v2/requisitions/#{ref}/",
        Authorization: "Bearer #{token["access"]}",
        Accept: "application/json"
      )

    accounts =
      case accounts do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Jason.decode!(body)["accounts"]

        _ ->
          conn
          |> put_flash(:info, "Failed to get account listing")
          |> redirect(to: Routes.management_account_path(conn, :index))
      end

    for account_id <- accounts do
      response =
        HTTPoison.get!("https://ob.nordigen.com/api/v2/accounts/#{account_id}/details/",
          Authorization: "Bearer #{token["access"]}",
          Accept: "application/json"
        )

      body = Jason.decode!(response.body)["account"]
      account = Management.get_account_by_iban_and_currency(body["iban"], body["currency"])

      if account do
        case Management.update_account(account, %{nordigen: account_id}) do
          {:ok, _account} ->
            conn |> put_flash(:info, "Account #{body["iban"]} connected successfully.")

          {:error, %Ecto.Changeset{} = _changeset} ->
            conn |> put_flash(:info, "Account #{body["iban"]} failed to connect")
        end
      end
    end

    conn
    |> redirect(to: Routes.management_account_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    account = Management.get_account!(id)
    {:ok, _account} = Management.delete_account(account)

    conn
    |> put_flash(:info, "Account deleted successfully.")
    |> redirect(to: Routes.management_account_path(conn, :index))
  end

  defp get_token(conn) do
    token = Personalfin.Nordigen.get_token()

    case token do
      nil ->
        conn
        |> put_flash(:info, "Failed to get token")
        |> redirect(to: Routes.management_account_path(conn, :index))

      _ ->
        token
    end
  end
end
