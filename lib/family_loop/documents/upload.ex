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

    timestamps()
  end

  @doc false
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:uuid, :filename, :file_extension, :size, :content_type, :hash, :path])
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

  def local_dir(date) do
    [upload_directory(), date]
    |> Path.join()
  end
end
