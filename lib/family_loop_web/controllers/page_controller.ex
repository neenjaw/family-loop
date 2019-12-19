defmodule FamilyLoopWeb.PageController do
  use FamilyLoopWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
