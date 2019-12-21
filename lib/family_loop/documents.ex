defmodule FamilyLoop.Documents do
  import Ecto.Query, warn: false

  alias FamilyLoop.Repo
  alias FamilyLoop.Documents.Upload

  def create_upload_from_plug_upload(%Plug.Upload{
    filename: filename,
    path: tmp_path,
    content_type: content_type
  }) do
    hash =
      File.stream!(tmp_path, [], 2048)
      |> Upload.sha256()

    uuid =
      UUID.uuid4()

    Repo.transaction fn ->
      with {:ok, %File.Stat{size: size}} <- File.stat(tmp_path),
        extname <- Path.extname(filename),
        datepath <- Upload.get_date_path(),
        local_datepath <- Upload.localize_path(datepath),
        path <- Upload.uuid_path(datepath, uuid),
        local_path <- Upload.localize_path(path),

        :ok <- File.mkdir_p(local_datepath),

        :ok <- File.cp(
          tmp_path,
          local_path
        ),

        {:ok, upload} <-
          %Upload{}
          |> Upload.changeset(%{
            uuid: uuid,
            filename: filename,
            file_extension: extname,
            content_type: content_type,
            hash: hash,
            size: size,
            path: datepath
          })
          |> Repo.insert(),

        {:ok, upload} <-
          upload
          |> Upload.create_thumbnail()
          |> Repo.update()
      do
        {:ok, upload}
      else
        {:error, _} = error -> error
      end
    end
  end

  def list_uploads() do
    Repo.all(Upload)
  end
end
