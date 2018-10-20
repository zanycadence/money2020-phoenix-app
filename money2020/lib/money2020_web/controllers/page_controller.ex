defmodule Money2020Web.PageController do
  use Money2020Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
