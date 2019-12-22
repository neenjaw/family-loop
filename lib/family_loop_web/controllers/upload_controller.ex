defmodule FamilyLoopWeb.UploadController do
  use FamilyLoopWeb, :controller

  alias FamilyLoop.Repo
  alias FamilyLoop.Documents
  alias FamilyLoop.Documents.Upload

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

  def asset(conn, %{"uuid" => uuid}) do
    upload = Repo.get_by(Upload, uuid: uuid)
    upload_path =
      Upload.uuid_path(upload.path, upload.uuid)
      |> Upload.localize_path()

    conn
    |> put_resp_content_type(upload.content_type)
    |> send_file(200, upload_path)
  end

  def thumbnail(conn, %{"uuid" => uuid}) do
    upload = Repo.get_by(Upload, uuid: uuid)
    |> IO.inspect(label: "46")

    cond do
      upload.thumbnail? ->
        thumb_path =
          Upload.thumbnail_path(upload.path, upload.uuid)
          |> Upload.localize_path()

        conn
        |> put_resp_content_type(upload.content_type)
        |> send_file(200, thumb_path)

      true ->
        conn
        |> put_status(:not_found)
        |> put_view(FamilyLoopWeb.ErrorView)
        |> render("404.html")
    end
  end
end
