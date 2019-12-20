defmodule FamilyLoopWeb.Router do
  use FamilyLoopWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FamilyLoopWeb do
    pipe_through :browser

    resources "/uploads", UploadController, only: [:index, :new, :show, :create]
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", FamilyLoopWeb do
  #   pipe_through :api
  # end
end
