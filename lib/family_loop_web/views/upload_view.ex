defmodule FamilyLoopWeb.UploadView do
  use FamilyLoopWeb, :view

  def render("scripts.html", _assigns) do
    ~s{<script>
       const dropArea = document.getElementById('upload__drop-area');
       dropArea ? App.init('upload__drop-area') : null;
       </script>}
    |> raw
  end
end
