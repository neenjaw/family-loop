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
        put_flash(conn, :info, "file uploaded correctly")
        redirect(conn, to: Routes.upload_path(conn, :index))

      {:error, reason} ->
        put_flash(conn, :error, "error uploading file #{inspect(reason)}")
        render(conn, "new.html")
    end
  end

  def index(conn, _params) do
    uploads = Documents.list_uploads()
    render(conn, "index.html", uploads: uploads)
  end
end
