defmodule Personalfin.Etoro do
  @moduledoc false

  use Hound.Helpers

  def current_value do
    username = "patrick.kusebauch@gmail.com"
    password = System.get_env("ETORO_PASSWORD")
    url = "https://www.etoro.com/login"

    Hound.start_session
    navigate_to url
    IO.inspect page_source()
    Hound.end_session
  end

end
