defmodule FamilyLoop.Documents.Upload do
  use Ecto.Schema
  import Ecto.Changeset

  schema "uploads" do
    field :uuid, :string
    field :content_type, :string
    field :filename, :string
    field :file_extension, :string
    field :hash, :string
    field :size, :integer
    field :path, :string
    field :thumbnail?, :boolean, source: :has_thumb

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:uuid, :filename, :file_extension, :size, :content_type, :hash, :path, :thumbnail?])
    |> validate_required([:uuid, :filename, :file_extension, :size, :content_type, :hash, :path])

    |> validate_number(:size, greater_than: 0) # No empty files
    |> validate_length(:hash, is: 64)
    |> unique_constraint(:uuid)
  end

  def sha256(chunks_enum) do
    chunks_enum
    |> Enum.reduce(
      :crypto.hash_init(:sha256),
      &(:crypto.hash_update(&2, &1))
    )
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  def upload_directory() do
    Application.get_env(:family_loop, :uploads_directory)
  end

  def get_date_path() do
    date = Date.utc_today()

    "#{date.year}/#{date.month}/#{date.day}"
  end

  def uuid_path(path, uuid) do
    [path, uuid]
    |> Path.join()
  end

  def thumbnail_path(path, uuid) do
    [path, "#{uuid}-thumb"]
    |> Path.join()
  end

  def localize_path(path) do
    [upload_directory(), path]
    |> Path.join()
  end

  def mogrify_thumbnail(src_path, dest_path) do
    try do
      src_path
      |> Mogrify.open()
      |> Mogrify.resize_to_limit("100x100")
      |> Mogrify.save(path: dest_path)
    rescue
      File.Error -> {:error, :invalid_src_path}
      error -> {:error, error}
    else
      _image -> {:ok, dest_path}
    end
  end

  def create_thumbnail(%__MODULE__{
    content_type: "image/" <> _image_type
  } = upload) do
    original_path = uuid_path(upload.path, upload.uuid) |> localize_path()
    thumb_path = thumbnail_path(upload.path, upload.uuid) |> localize_path()
    {:ok, _} = mogrify_thumbnail(original_path, thumb_path)

    changeset(upload, %{thumbnail?: true})
  end

  def create_thumbail(%__MODULE__{} = upload) do
    changeset(upload, %{})
  end
end
