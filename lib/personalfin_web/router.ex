defmodule PersonalfinWeb.Router do
  use PersonalfinWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PersonalfinWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PersonalfinWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/compare", PersonalfinWeb.Compare, as: :compare do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/expenses", PersonalfinWeb.Expense, as: :expense do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/management", PersonalfinWeb.Management, as: :management do
    pipe_through :browser

    get "/", PageController, :index
    get "/accounts/connect/:bank", AccountController, :connect
    get "/accounts/connected", AccountController, :connected
    resources "/accounts", AccountController, except: [:show]
    resources "/investments", InvestmentController, except: [:show]
    resources "/stocks", StockController, except: [:show]
    get "/transactions", TransactionController, :index
    post "/transactions/update_categories", TransactionController, :update_categories
    post "/transactions/update_transactions", TransactionController, :update_transactions
  end

  scope "/projection", PersonalfinWeb.Projection, as: :projection do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PersonalfinWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PersonalfinWeb.Telemetry
    end
  end
end
