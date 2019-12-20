defmodule FamilyLoop.Documents.Size do
  @units ~w(B KiB MiB GiB TiB PiB EiB ZiB YiB)

  def humanize(size) do
    exp = :math.log(size) / :math.log(1024) |> trunc
    result = size / :math.pow(1024, exp)
    result =
      case exp do
        e when e in [0, 1] -> result
        _ -> result |> Float.round(2)
      end

    unit = @units |> Enum.at(exp)

    "#{result} #{unit}"
  end
end
