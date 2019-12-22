defmodule FamilyLoop.Repo.Migrations.AddUuidIndex do
  use Ecto.Migration

  def change do
    create index(:uploads, [:uuid])
  end
end
