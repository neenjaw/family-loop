defmodule FamilyLoop.Repo.Migrations.AddThumbContentType do
  use Ecto.Migration

  def change do
    alter table(:uploads) do
      add :thumb_content_type, :string
    end
  end
end
