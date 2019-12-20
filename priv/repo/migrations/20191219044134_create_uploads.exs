defmodule FamilyLoop.Repo.Migrations.CreateUploads do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add :uuid, :string
      add :filename, :string
      add :file_extension, :string
      add :path, :string
      add :size, :bigint
      add :content_type, :string
      add :hash, :string, size: 64

      timestamps()
    end

    create index(:uploads, [:hash])
  end
end
