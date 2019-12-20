defmodule FamilyLoopWeb.UploadController do
  use FamilyLoopWeb, :controller

  alias FamilyLoop.Documents

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"upload" => %Plug.Upload{} = upload}) do
    IO.inspect(upload, label: "UPLOAD")

    case Documents.create_upload_from_plug_upload(upload) do
      {:ok, _upload} ->
        conn
        |> put_flash(:info, "file uploaded correctly") |> IO.inspect(label: "15")
        |> redirect(to: Routes.upload_path(conn, :index))

      {:error, reason} ->
        conn
        |> put_flash(:error, "error uploading file #{inspect(reason)}")
        |> render("new.html")
    end
  end

  def index(conn, _params) do
    uploads = Documents.list_uploads()
    render(conn, "index.html", uploads: uploads)
  end
end
